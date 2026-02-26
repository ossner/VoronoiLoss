import torch
import pytorch_lightning as pl
from monai.networks.nets import UNet
from monai.metrics import DiceMetric
from monai.transforms import (
    Compose,
    LoadImaged,
    EnsureChannelFirstd,
    DivisiblePadd,
    AsDiscrete,
    Activations,
    RandFlipd,
    NormalizeIntensityd,
    RandRotate90d,
    ScaleIntensityd,
    EnsureTyped,
    RandRotated,
    Zoomd,
    RandZoomd,
    RandGaussianNoised,
    RandGaussianSmoothd,
    HistogramNormalized,
    ThresholdIntensityd,
    Lambdad,
    ScaleIntensityRangePercentilesd,
    RandAdjustContrastd,
    CenterSpatialCropd,
    RandScaleIntensityd,
    RandShiftIntensityd,
    Rand2DElasticd,
    RandGaussianSharpend,
    RandBiasFieldd,
)
import os
import numpy as np
from VoronoiTransform import ComputeVoronoiMapsd, voronoi_map_from_binary_mask
from monai.data import decollate_batch, CacheDataset, DataLoader, list_data_collate, Dataset, GridPatchDataset, PatchIterd
from monai.utils import set_determinism
from util import get_data_dicts, _get_random_cmap
from skimage.measure import label
from stardist.matching import matching_dataset
import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
from LossWrapper import WeightedLossWrapper
from panoptica import Panoptica_Evaluator, Panoptica_Aggregator, Panoptica_Statistic
from WeightMapTransforms import ComputeWeightMapsd
matplotlib.use("Agg")  # non-interactive backend suitable for scripts


class PlateletSegmentationModel(pl.LightningModule):
    def __init__(self, data_dir, loss_dict, weight_map='none', lr=1e-3, batch_size=8, seed=0, task='alpha granule'):
        super().__init__()
        # 2D UNet: 1 input channel (grayscale), 1 output channel (binary)
        self.model = UNet(
            spatial_dims=2,
            in_channels=1,
            out_channels=1,
            channels=(16, 32, 64, 128, 256),
            strides=(2, 2, 2, 2),
            num_res_units=2,
        )
        self.loss_function = WeightedLossWrapper(
            loss_dict=loss_dict, weight_map=weight_map)
        self.weight_map = weight_map
        self.dice = DiceMetric(
            include_background=False,
            reduction="mean",
        )

        self.post_trans = Compose([
            Activations(sigmoid=True),
            AsDiscrete(threshold=0.5)
        ])

        self.evaluator = None

        self.lr = lr
        self.batch_size = batch_size
        self.task = task
        self.best_val_dice = 0.0
        self.best_val_epoch = 0
        self.validation_step_outputs = []
        self.validation_vis_samples = []
        self.test_instance_f1_scores = []
        self.seed = seed
        self.data_dir = data_dir
        self.save_hyperparameters(
            "lr", "batch_size", 'loss_dict', 'weight_map')

    def forward(self, x):
        return self.model(x)

    def prepare_data(self):
        set_determinism(seed=self.seed)

        train_files = get_data_dicts(self.data_dir, "train", self.task)
        val_files = get_data_dicts(self.data_dir, "val", self.task)
        test_files = get_data_dicts(self.data_dir, "test", self.task)

        # All keys for monai transforms that need to me spatially augmented together
        SPATIAL_KEYS = [
            "image", "label", "voronoi", "none", "iw", "v_size",
            "v_share", "v_mountains", "v_islands"
        ]
        # Only the label uses nearest neighbor; everything else (images, weight maps) uses bilinear
        MODES = ["bilinear", "nearest", "nearest"] + \
            ["bilinear"] * (len(SPATIAL_KEYS) - 3)

        # --- Stage 1: Map Generation (on the full 800x800 image) ---
        map_gen_transforms = Compose([
            LoadImaged(keys=['image', 'label']),
            EnsureChannelFirstd(keys=["image", "label"],
                                channel_dim="no_channel"),
            Lambdad(keys=["label"], func=lambda x: x / 255.0),
            ComputeVoronoiMapsd(keys=["label"]),
            EnsureChannelFirstd(keys=["voronoi"], channel_dim="no_channel"),
            ComputeWeightMapsd(
                keys=["label"], mountain_sigma_sc=2, island_sigma_sc=5),
            ScaleIntensityd(['image']),
            EnsureTyped(keys=SPATIAL_KEYS),
        ])

        train_transforms = Compose([
            # --- Geometric Augmentations ---
            RandFlipd(keys=SPATIAL_KEYS, prob=0.5, spatial_axis=0),
            RandFlipd(keys=SPATIAL_KEYS, prob=0.5, spatial_axis=1),
            RandRotate90d(keys=SPATIAL_KEYS, prob=0.5, max_k=3),
            RandRotated(
                keys=SPATIAL_KEYS,
                range_x=0.26,  # ±15 degrees
                prob=0.4,
                mode=MODES,
                padding_mode="zeros",
            ),
            RandZoomd(
                keys=SPATIAL_KEYS,
                min_zoom=0.9,
                max_zoom=1.1,
                prob=0.3,
                mode=MODES,
            ),
            RandGaussianSmoothd(keys=["image"], prob=0.3),
            RandGaussianNoised(keys=["image"], std=0.25, prob=0.3),
            RandScaleIntensityd(keys=["image"], factors=0.25, prob=0.3),
            RandShiftIntensityd(keys=["image"], offsets=0.25, prob=0.3),
        ])

        def create_tile_dataset(data_files, transform_after_tiling=None):
            all_patches = []

            # Process each 800x800 slice once
            base_ds = Dataset(data=data_files, transform=map_gen_transforms)

            print(f"Pre-processing {len(data_files)} slices into tiles...")
            for i in range(len(base_ds)):
                full_data = base_ds[i]

                patch_size = 288
                stride = 170

                for r in range(4):
                    for c in range(4):
                        y1, x1 = r * stride, c * stride
                        y2, x2 = y1 + patch_size, x1 + patch_size

                        patch_dict = {}
                        for key in SPATIAL_KEYS:
                            patch_dict[key] = full_data[key][...,
                                                             y1:y2, x1:x2].clone()

                        all_patches.append(patch_dict)

            return CacheDataset(
                data=all_patches,
                transform=transform_after_tiling,
                cache_rate=1.0
            )

        self.train_ds = create_tile_dataset(
            train_files, transform_after_tiling=train_transforms)
        self.val_ds = create_tile_dataset(
            val_files, transform_after_tiling=None)
        self.test_ds = create_tile_dataset(
            test_files, transform_after_tiling=None)

    def train_dataloader(self):
        return DataLoader(
            self.train_ds, batch_size=self.batch_size, num_workers=4, collate_fn=list_data_collate)

    def val_dataloader(self):
        return DataLoader(self.val_ds, batch_size=1, num_workers=4, collate_fn=list_data_collate)

    def test_dataloader(self):
        return DataLoader(self.test_ds, batch_size=1, num_workers=4, collate_fn=list_data_collate)

    def configure_optimizers(self):
        optimizer = torch.optim.Adam(self.parameters(), lr=self.lr)
        scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
            optimizer, mode="max", factor=0.5, patience=10
        )
        return {
            "optimizer": optimizer,
            "lr_scheduler": {
                "scheduler": scheduler,
                "monitor": "val_dice",
            },
        }

    def on_fit_start(self):
        total_params = sum(p.numel() for p in self.parameters())
        trainable_params = sum(p.numel()
                               for p in self.parameters() if p.requires_grad)

        tb = self.logger.experiment
        tb.add_scalar("model/total_params", total_params, 0)
        tb.add_scalar("model/trainable_params", trainable_params, 0)

        self._visualize_augmentations()

    def _visualize_augmentations(self, num_samples=4):
        """Log multiple augmented versions of the same samples to visualize augmentations"""
        fig, ax = plt.subplots(3, num_samples, figsize=(num_samples * 3, 10))
        data_iter = iter(self.train_ds)
        for i in range(num_samples):
            # Accessing the dataset directly triggers the PatchIter + Transform logic
            # Every call here will yield a different random augmentation
            sample = next(data_iter)

            img = sample["image"][0].detach().cpu()
            mask = sample["label"][0].detach().cpu()
            weight = sample[self.weight_map][0].detach().cpu()

            # Row 0: Image
            ax[0, i].imshow(img, cmap="gray")
            ax[0, i].set_title(f"Aug {i+1}")
            ax[0, i].axis("off")

            # Row 1: Label (Overlaid on Image for alignment check)
            ax[1, i].imshow(img, cmap="gray")
            ax[1, i].imshow(mask, cmap="jet", alpha=0.4)
            ax[1, i].set_title("Label Align")
            ax[1, i].axis("off")

            # Row 2: Weight Map (Mountains)
            ax[2, i].imshow(weight, cmap="viridis")
            ax[2, i].set_title("Weight Map")
            ax[2, i].axis("off")

        plt.tight_layout()
        if self.logger and hasattr(self.logger, "experiment"):
            self.logger.experiment.add_figure(
                "Augmentation_Samples", fig, self.global_step)
        print(
            f"✓ Logged a sample augmentation to TensorBoard")

    def training_step(self, batch, batch_idx):
        images = batch["image"]
        outputs = self.forward(images)

        loss = self.loss_function(outputs, batch)

        self.log("train_loss", loss, on_epoch=True,
                 on_step=False, prog_bar=True)
        return loss

    def on_train_epoch_end(self):
        optimizer = self.optimizers()
        lr = optimizer.param_groups[0]["lr"]
        self.log("lr", lr, prog_bar=True, on_epoch=True)

    def validation_step(self, batch, batch_idx):
        images = batch["image"]
        outputs = self(images)

        val_loss = self.loss_function(outputs, batch)

        preds_list = [self.post_trans(i) for i in decollate_batch(outputs)]
        labels_list = decollate_batch(batch["label"])

        self.dice(y_pred=preds_list, y=labels_list)

        self.log("val_loss", val_loss, on_epoch=True,
                 on_step=False, batch_size=images.shape[0])

        if self.current_epoch % 10 == 0 and len(self.validation_vis_samples) < 4:
            self.validation_vis_samples.append((batch, outputs))

        return val_loss

    def _visualize_val_samples(self, samples):
        # Ensure we don't try to plot more than we have in the batch
        n_rows = len(samples)
        n_cols = 3
        fig, ax = plt.subplots(n_rows, n_cols, figsize=(12, 4 * n_rows))

        # If n_rows is 1, ax is not a 2D array, so we reshape it
        if n_rows == 1:
            ax = np.expand_dims(ax, axis=0)

        for i in range(len(samples)):
            batch, outputs = samples[i]
            # 1. Prepare Tensors (Moving to CPU and stripping channel dim)
            img = batch['image'].detach().cpu().numpy().squeeze()
            gt_label = batch['label'].detach().cpu().numpy().squeeze()
            gt_voronoi = batch['voronoi'].detach().cpu().numpy().squeeze()
            weight_map = batch[self.weight_map].detach(
            ).cpu().numpy().squeeze()
            pred_mask = (outputs.detach().cpu().numpy().squeeze()
                         > 0.5).astype(np.float32)

            # --- Column 1: GT Labels + Voronoi ---
            ax[i, 0].imshow(img, cmap="gray")
            ax[i, 0].imshow(gt_label, alpha=0.4, cmap="Blues")
            ax[i, 0].imshow(gt_voronoi, alpha=0.4, cmap=_get_random_cmap(
                gt_voronoi.max()), interpolation='nearest')
            ax[i, 0].set_title(
                f"GT")
            ax[i, 0].axis('off')

            # --- Column 2: Pred Mask ---
            tp = (pred_mask == 1) & (gt_label == 1)
            fp = (pred_mask == 1) & (gt_label == 0)
            fn = (pred_mask == 0) & (gt_label == 1)
            overlay = np.zeros((pred_mask.shape[0], pred_mask.shape[1], 3))

            overlay[tp] = [0, 1, 0]
            overlay[fp] = [1, 0, 0]
            overlay[fn] = [0, 0, 1]
            ax[i, 1].imshow(img, cmap="gray")
            ax[i, 1].imshow(overlay, alpha=0.5)
            ax[i, 1].set_title(
                f"Green=TP | Red=FP | Blue=FN")
            ax[i, 1].axis('off')

            # --- Column 3: Weight Map ---
            im3 = ax[i, 2].imshow(weight_map, cmap="viridis")
            ax[i, 2].set_title(f"Weight Map: {self.weight_map}")
            plt.colorbar(im3, ax=ax[i, 2], fraction=0.046, pad=0.04)
            ax[i, 2].axis('off')

        plt.tight_layout()
        self.logger.experiment.add_figure("val_samples", fig, self.global_step)
        plt.close(fig)

    def on_validation_epoch_end(
            self):
        mean_dice = self.dice.aggregate().item()

        self.log("val_dice", mean_dice, prog_bar=True)

        self.dice.reset()

        if mean_dice > self.best_val_dice:
            self.best_val_dice = mean_dice
            self.best_val_epoch = self.current_epoch
        if self.validation_vis_samples:
            # Create one big plot using the accumulated samples
            self._visualize_val_samples(self.validation_vis_samples)
            self.validation_vis_samples.clear()

    def on_fit_end(self):
        print(
            f"Training completed. Best Dice Score: {self.best_val_dice:.4f} at Epoch: {self.best_val_epoch}")

        self.dice.reset()
        self.logger.log_hyperparams(
            params=dict(self.hparams),
            metrics={
                "best_val_dice": self.best_val_dice,
                "best_val_epoch": self.best_val_epoch,
            },
        )

    def on_test_start(self):
        self.evaluator = Panoptica_Evaluator.load_from_config(
            "src/twod/panoptica_config.yaml")
        self.aggregator = Panoptica_Aggregator(
            panoptica_evaluator=self.evaluator, output_file=f'{self.logger.log_dir}/eval.tsv')

    def test_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]

        logits = self(images)
        preds = self.post_trans(logits)

        image = images.cpu().numpy().squeeze()
        preds = preds.cpu().numpy().squeeze()
        labels = labels.cpu().numpy().squeeze()

        self.aggregator.evaluate(preds, labels, batch_idx)

        if True:
            # Compute masks
            tp = (preds == 1) & (labels == 1)
            fp = (preds == 1) & (labels == 0)
            fn = (preds == 0) & (labels == 1)
            # Create RGB overlay
            overlay = np.zeros((preds.shape[0], preds.shape[1], 3))
            
            overlay[tp] = [0, 1, 0]
            overlay[fp] = [1, 0, 0]
            overlay[fn] = [0, 0, 1]

            # Plot
            plt.figure(figsize=(6, 6))
            plt.imshow(image, cmap="gray")
            plt.imshow(overlay, alpha=0.5)
            plt.axis("off")
            plt.title("Green=TP | Red=FP | Blue=FN")
    #
            # Save
            save_dir = os.path.join(self.logger.log_dir, "test_visuals")
            os.makedirs(save_dir, exist_ok=True)
            save_path = os.path.join(save_dir, f"{batch_idx}.png")
    #
            plt.savefig(save_path, bbox_inches="tight", pad_inches=0)
            plt.close()

    def on_test_epoch_end(self):
        statistics_obj = Panoptica_Statistic.from_file(
            f'{self.logger.log_dir}/eval.tsv')
        summary = statistics_obj.get_summary_dict(
            include_across_group=False)['instance']
        metrics_to_log = {
            "test/dice":      summary['global_bin_dsc'].avg,
            "test/tp":        summary['tp'].avg,
            "test/fp":        summary['fp'].avg,
            "test/fn":        summary['fn'].avg,
            "test/precision": summary['prec'].avg,
            "test/recall":    summary['rec'].avg,
            "test/f1":    (2*summary['prec'].avg*summary['rec'].avg)/(summary['prec'].avg+summary['rec'].avg),
            "test/assd":      summary['sq_assd'].avg,
        }
        self.log_dict(metrics_to_log)

        # Optional: Print to console for immediate feedback
        print(f"\nTest Results for {self.task}_{self.hparams.weight_map}:")
        statistics_obj.print_summary(3, only_across_groups=False)
