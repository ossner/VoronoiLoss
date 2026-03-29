from monai.losses import DiceCELoss
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
    RandZoomd,
    RandGaussianNoised,
    RandGaussianSmoothd,
    Lambdad,
    RandScaleIntensityd,
    RandShiftIntensityd,
)
import os
import numpy as np
from tqdm import tqdm
from VoronoiTransform import ComputeVoronoiMapsd
from monai.data import decollate_batch, CacheDataset, DataLoader, list_data_collate, Dataset, PatchDataset
from monai.utils import set_determinism
from monai.optimizers import WarmupCosineSchedule, LinearLR
from util import get_data_dicts, _get_random_cmap, split_gt_by_volume, get_data_dicts_3d, create_random_patch_dataset
from sklearn.metrics import fbeta_score
import matplotlib
import matplotlib.pyplot as plt
import statistics
from LossWrapper import WeightedLossWrapper
from torchmetrics.classification import BinaryF1Score, BinaryPrecision, BinaryRecall, BinaryFBetaScore
from panoptica import Panoptica_Evaluator, Panoptica_Aggregator, Panoptica_Statistic
from WeightMapTransforms import ComputeWeightMapsd
from CCMetrics import CCDiceMetric
matplotlib.use("Agg")


class PlateletSegmentationModel(pl.LightningModule):
    def __init__(self, data_dir, loss_dict, weight_map='none', lr=1e-3, batch_size=8, seed=0, task='alpha granule'):
        super().__init__()
        set_determinism(seed=seed)
        # 2D UNet: 1 input channel (grayscale), 1 output channel (binary)
        self.model = UNet(
            spatial_dims=2,
            in_channels=1,
            out_channels=1,
            channels=(16, 32, 64, 128, 256),
            strides=(2, 2, 2, 2),
            num_res_units=2,
        )
        self.loss_function = WeightedLossWrapper(loss_dict=loss_dict)
        self.weight_map = weight_map
        self.dice = DiceMetric(
            include_background=False,
            reduction="mean",
        )
        self.cc_dice = CCDiceMetric(
            cc_reduction="patient",
            use_caching=False
        )
        self.f2 = BinaryFBetaScore(beta=2.0)
        self.recall = BinaryRecall()
        self.precision = BinaryPrecision()
        self.post_trans = Compose([
            Activations(sigmoid=True),
            AsDiscrete(threshold=0.5)
        ])

        self.evaluator = Panoptica_Evaluator.load_from_config(
            "src/twod/eval/panoptica_config.yaml")
        self.instance_f1 = []
        self.instance_recall = []
        self.lr = lr
        self.batch_size = batch_size
        self.task = task
        self.best_val_dice = 0.0
        self.best_val_epoch = 0
        self.validation_step_outputs = []
        self.validation_vis_samples = []
        self.test_instance_f1_scores = []
        self.data_dir = data_dir
        self.save_hyperparameters(
            "lr", "batch_size", 'loss_dict', 'weight_map')

    def forward(self, x):
        return self.model(x)

    def prepare_data(self):
        train_files = get_data_dicts(self.data_dir, "train", self.task)
        val_files = get_data_dicts(self.data_dir, "val", self.task)
        test_files = get_data_dicts(self.data_dir, "test", self.task)
        # All keys for monai transforms that need to me spatially augmented together
        SPATIAL_KEYS = [
            "image", "label", "voronoi", "weight_map", "instances"
        ]
        MODES = [
            "bilinear",  # image
            "nearest",   # label
            "nearest",   # voronoi
            "bilinear",  # weight_map
            "nearest",   # instances
        ]

        train_transforms = [
            RandFlipd(
                keys=SPATIAL_KEYS, prob=0.5, spatial_axis=0),
            RandFlipd(keys=SPATIAL_KEYS, prob=0.5, spatial_axis=1),
            RandRotate90d(keys=SPATIAL_KEYS, prob=0.5, max_k=3),
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
            EnsureTyped(keys=SPATIAL_KEYS),
        ]

        base_transforms = [
            LoadImaged(keys=['image', 'label']),
            EnsureChannelFirstd(keys=["image", "label"],
                                channel_dim="no_channel"),
            Lambdad(keys=["label"], func=lambda x: (x > 0).astype(x.dtype)),
            ComputeVoronoiMapsd(keys=["label"]),
            EnsureChannelFirstd(
                keys=["voronoi", "instances"], channel_dim="no_channel"),
            ComputeWeightMapsd(
                keys=["label"], concept=self.weight_map, mountain_sigma_sc=2, island_sigma_sc=5),
            ScaleIntensityd(['image']),
            EnsureTyped(keys=SPATIAL_KEYS),
        ]
        
        if self.data_dir.endswith('/platelet'):
            assert self.task in [
                "ag", 'cv'], f"Task {self.task} and dataset {self.data_dir} do not match"
            print('Creating platelet datasets from slices...')
            self.roi_size = (288, 288)
            self.volume_quartiles = [
                460, 881, 1426.5] if self.task == 'ag' else [160, 271, 451.75]
            self.train_ds = create_random_patch_dataset(
                train_files, SPATIAL_KEYS, base_transforms, train_transforms, self.roi_size, 25, cache_rate=1)
            self.val_ds = CacheDataset(
                data=val_files,
                transform=Compose([*base_transforms,]),
                cache_rate=1
            )
            self.test_ds = Dataset(
                data=test_files,
                transform=base_transforms,
            )
        elif self.data_dir.endswith('/mitolab'):
            assert self.task == "mit", f"Task {self.task} and dataset {self.data_dir} do not match"
            print('Creating mitolab datasets from images...')
            self.volume_quartiles = [536, 1229, 2394]
            self.train_ds = CacheDataset(
                data=train_files,
                transform=Compose([*base_transforms,
                                   *train_transforms]),
                cache_rate=0.4
            )
            self.val_ds = CacheDataset(
                data=val_files,
                transform=Compose([*base_transforms,]),
                cache_rate=0.4
            )
            self.test_ds = Dataset(
                data=test_files,
                transform=Compose([*base_transforms,]),
            )
        elif self.data_dir.endswith('/epfl'):
            assert self.task == "mit", f"Task {self.task} and dataset {self.data_dir} do not match"
            self.roi_size = (512, 512)
            self.volume_quartiles = [1393.25, 2265, 3737.5]
            print('Creating epfl dataset from slices...')
            self.train_ds = create_random_patch_dataset(
                train_files, SPATIAL_KEYS, base_transforms, train_transforms, self.roi_size, 16, cache_rate=0.25)
            self.val_ds = CacheDataset(
                data=val_files,
                transform=Compose([*base_transforms,]),
                cache_rate=0.25
            )
            self.test_ds = Dataset(
                data=test_files,
                transform=base_transforms,
            )
        else:
            raise NotImplementedError()

    def train_dataloader(self):
        return DataLoader(
            self.train_ds, batch_size=self.batch_size, num_workers=8, collate_fn=list_data_collate)

    def val_dataloader(self):
        return DataLoader(self.val_ds, batch_size=1, num_workers=8, collate_fn=list_data_collate)

    def test_dataloader(self):
        return DataLoader(self.test_ds, batch_size=1, num_workers=4)

    def configure_optimizers(self):
        optimizer = torch.optim.AdamW(
            self.parameters(),
            lr=self.lr,
        )

        scheduler = WarmupCosineSchedule(
            optimizer,
            t_total=self.trainer.max_epochs,
            warmup_steps=int(self.trainer.max_epochs * 0.05)
        )

        return {
            "optimizer": optimizer,
            "lr_scheduler": {
                "scheduler": scheduler,
                "interval": "epoch",
                "frequency": 1,
            },
        }

    def on_fit_start(self):
        total_params = sum(p.numel() for p in self.parameters())
        trainable_params = sum(p.numel()
                               for p in self.parameters() if p.requires_grad)

        tb = self.logger.experiment
        tb.add_scalar("model/total_params", total_params, 0)
        tb.add_scalar("model/trainable_params", trainable_params, 0)

        # self._visualize_augmentations()

    def _visualize_augmentations(self, num_samples=4):
        """Log multiple augmented versions of the same samples to visualize augmentations"""
        fig, ax = plt.subplots(3, num_samples, figsize=(num_samples * 3, 10))
        original_sample = self.train_ds.data[0]
        for i in range(num_samples):
            transformed = self.train_ds.transform(original_sample)

            img = transformed["image"][0].detach().cpu()
            mask = transformed["label"][0].detach().cpu()
            weight = transformed['weight_map'][0].detach().cpu()

            ax[0, i].imshow(img, cmap="gray")
            ax[0, i].set_title(f"Aug {i+1}")
            ax[0, i].axis("off")

            ax[1, i].imshow(img, cmap="gray")
            ax[1, i].imshow(mask, cmap="jet", alpha=0.4)
            ax[1, i].set_title("Label Align")
            ax[1, i].axis("off")

            ax[2, i].imshow(weight, cmap="viridis")
            ax[2, i].set_title("Weight Map")
            ax[2, i].axis("off")

        plt.tight_layout()
        if self.logger and hasattr(self.logger, "experiment"):
            self.logger.experiment.add_figure(
                "train/augmentation_samples", fig, self.global_step)
        print(
            f"✓ Logged a sample augmentation to TensorBoard")

    def training_step(self, batch, batch_idx):
        images = batch["image"]
        outputs = self.forward(images)

        loss = self.loss_function(outputs, batch)

        preds_list = [self.post_trans(i) for i in decollate_batch(outputs)]
        labels_list = decollate_batch(batch["label"])
        self.dice(y_pred=preds_list, y=labels_list)
        self.log("train/loss", loss, on_epoch=True,
                 on_step=False, prog_bar=True)
        self.log("train/dice", self.dice.aggregate(reduction='mean').item(),
                 on_step=False, on_epoch=True)
        self.log("train/lr", self.optimizers(
        ).param_groups[0]["lr"], on_step=False, on_epoch=True)
        return loss

    def validation_step(self, batch, batch_idx):
        images = batch["image"]
        outputs = self(images)
        preds = self.post_trans(outputs)

        self.dice(y_pred=preds, y=batch["label"])
        val_loss = self.loss_function(outputs, batch)
        self.log("val/loss", val_loss, on_epoch=True,
                 on_step=False, batch_size=images.shape[0])
        self.precision(preds, batch["label"])
        self.log("val/precision", self.precision, on_epoch=True)
        self.recall(preds, batch["label"])
        self.log("val/recall", self.recall, on_epoch=True)
        self.f2(preds, batch["label"])
        self.log("val/f2", self.f2, on_epoch=True)
        
        preds_np = preds.detach().cpu().numpy().squeeze()
        labels_np = batch['label'].detach().cpu().numpy().squeeze()
        if self.current_epoch > 10:  # Panoptica instance wise needs a while before it can be applied due to instability early
            panoptica_metrics = self.evaluator.evaluate(
                preds_np, labels_np, log_times=False, verbose=False)['instance']
            self.instance_f1.append(panoptica_metrics.rq)
            self.instance_recall.append(panoptica_metrics.rec)
        else:
            self.instance_f1.append(0.5)
            self.instance_recall.append(0.5)
        if preds_np.ndim == 2:
            preds_np = preds_np[None, ...]
            labels_np = labels_np[None, ...]

        B, C = 1, 2
        D, H, W = preds_np.shape

        y_hat = torch.zeros((B, C, D, H, W), dtype=torch.float32)
        y = torch.zeros((B, C, D, H, W), dtype=torch.float32)

        y_hat[0, 1] = torch.from_numpy(preds_np)
        y[0, 1] = torch.from_numpy(labels_np)

        y_hat[0, 0] = 1 - y_hat[0, 1]
        y[0, 0] = 1 - y[0, 1]
        self.cc_dice(y_pred=y_hat, y=y)

        if self.current_epoch % 10 == 0 and len(self.validation_vis_samples) < 4:
            self.validation_vis_samples.append((batch, outputs))
        return val_loss

    def on_validation_epoch_end(self):
        mean_dice = self.dice.aggregate(reduction='mean').item()
        self.log("val/instance_f1",
                 statistics.mean(self.instance_f1), prog_bar=False)
        self.log("val/instance_recall",
                 statistics.mean(self.instance_recall), prog_bar=False)
        self.log("val/ccdice",
                 self.cc_dice.cc_aggregate().mean().item(), on_epoch=True)
        self.instance_f1 = []
        self.log("val/dice", mean_dice, prog_bar=True)
        self.dice.reset()

        if mean_dice > self.best_val_dice:
            self.best_val_dice = mean_dice
            self.best_val_epoch = self.current_epoch
        if self.validation_vis_samples:
            self._visualize_val_samples(self.validation_vis_samples)
            self.validation_vis_samples.clear()

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
            weight_map = batch['weight_map'].detach(
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
        self.logger.experiment.add_figure("val/samples", fig, self.global_step)
        plt.close(fig)

    def on_fit_end(self):
        print(
            f"Training completed. Best Dice Score: {self.best_val_dice:.4f} at Epoch: {self.best_val_epoch}")
        self.logger.log_hyperparams(
            params=dict(self.hparams),
            metrics={
                "best_val_dice": self.best_val_dice,
                "best_val_epoch": self.best_val_epoch,
            },
        )

    def on_test_start(self):
        self.recall.reset()
        self.precision.reset()
        self.quartile_recalls = {
            "q0": [],
            "q1": [],
            "q2": [],
            "q3": []
        }
        self.aggregator = Panoptica_Aggregator(
            panoptica_evaluator=self.evaluator, output_file=f'{self.logger.log_dir}/eval.tsv')

    def test_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]

        outputs = self.forward(images)
        preds = self.post_trans(outputs)

        self.recall(preds, labels)
        self.precision(preds, labels)

        image = images.cpu().numpy().squeeze()
        preds = preds.cpu().numpy().squeeze()
        labels = labels.cpu().numpy().squeeze()

        self.aggregator.evaluate(preds, labels, batch_idx)
        gt_quartiles = split_gt_by_volume(labels, self.volume_quartiles)
        for i, gt_q in enumerate(gt_quartiles):
            if np.sum(gt_q) == 0:
                continue
            self.quartile_recalls[f"q{i}"].append(self.evaluator.evaluate(
                preds, gt_q, log_times=False, verbose=False)['instance'].rec)
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

            # Save
            save_dir = os.path.join(self.logger.log_dir, "test_visuals")
            os.makedirs(save_dir, exist_ok=True)
            save_path = os.path.join(save_dir, f"{batch_idx}.png")

            plt.savefig(save_path, bbox_inches="tight", pad_inches=0)
            plt.close()

    def on_test_epoch_end(self):
        precision = self.precision.compute()
        recall = self.recall.compute()

        statistics_obj = Panoptica_Statistic.from_file(
            f'{self.logger.log_dir}/eval.tsv')
        summary = statistics_obj.get_summary_dict(
            include_across_group=False)['instance']
        mean_quartile_recall = {}

        for q in self.quartile_recalls:
            values = self.quartile_recalls[q]
            if len(values) == 0:
                mean_quartile_recall[q] = 0
            else:
                mean_quartile_recall[q] = np.mean(values)

        metrics_to_log = {
            "test/global/dice":      summary['global_bin_dsc'].avg,
            "test/global/precision": precision,
            "test/global/recall":    recall,
            "test/instance/dice":      summary['sq_dsc'].avg,
            "test/instance/tp":        summary['tp'].avg,
            "test/instance/fp":        summary['fp'].avg,
            "test/instance/fn":        summary['fn'].avg,
            "test/instance/precision": summary['prec'].avg,
            "test/instance/recall_q0":    mean_quartile_recall['q0'],
            "test/instance/recall_q1":    mean_quartile_recall['q1'],
            "test/instance/recall_q2":    mean_quartile_recall['q2'],
            "test/instance/recall_q3":    mean_quartile_recall['q3'],
            "test/instance/recall":    summary['rec'].avg,
            "test/instance/f1":         summary['rq'].avg,
            "test/instance/assd":      summary['sq_assd'].avg,
            "test/instance/cedi":      summary['sq_cedi'].avg,
        }
        self.log_dict(metrics_to_log)

        print(f"\nTest Results for {self.task}_{self.hparams.weight_map}:")
        statistics_obj.print_summary(3, only_across_groups=False)


class BrainSegmentationModel(pl.LightningModule):
    def __init__(self, data_dir, loss_dict, weight_map='none', lr=1e-3, batch_size=8, seed=0, task='sbm'):
        super().__init__()
        # 2D UNet: 1 input channel (grayscale), 1 output channel (binary)
        self.model = UNet(
            spatial_dims=3,
            in_channels=1,
            out_channels=1,
            channels=(16, 32, 64, 128, 256),
            strides=(2, 2, 2, 2),
            num_res_units=2,
        )
        self.loss_function = DiceCELoss(sigmoid=True, squared_pred=True)
        self.weight_map = weight_map
        self.dice = DiceMetric(
            include_background=False,
            reduction="mean",
        )
        self.f1 = BinaryF1Score()
        self.recall = BinaryRecall()
        self.precision = BinaryPrecision()
        self.post_trans = Compose([
            Activations(sigmoid=True),
            AsDiscrete(threshold=0.5)
        ])

        self.evaluator = Panoptica_Evaluator.load_from_config(
            "src/twod/eval/panoptica_config.yaml")
        self.instance_f1 = []
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

        train_files = get_data_dicts_3d(self.data_dir, "train", samples=3)
        val_files = get_data_dicts_3d(self.data_dir, "val")
        test_files = get_data_dicts_3d(self.data_dir, "test")
        SPATIAL_KEYS = [
            "image", "label", "voronoi", "weight_map", "instances"
        ]
        MODES = [
            "bilinear",  # image
            "nearest",   # label
            "nearest",   # voronoi
            "bilinear",  # weight_map
            "nearest",   # instances
        ]

        train_transforms = [
            RandFlipd(
                keys=SPATIAL_KEYS, prob=0.5, spatial_axis=0),
            RandFlipd(keys=SPATIAL_KEYS, prob=0.5, spatial_axis=1),
            RandRotate90d(keys=SPATIAL_KEYS, prob=0.5, max_k=3),
            RandZoomd(
                keys=SPATIAL_KEYS,
                min_zoom=0.9,
                max_zoom=1.1,
                prob=0.3,
                mode=MODES,
            ),
            # RandGaussianSmoothd(keys=["image"], prob=0.3),
            # RandGaussianNoised(keys=["image"], std=0.25, prob=0.3),
            # RandScaleIntensityd(keys=["image"], factors=0.25, prob=0.3),
            # RandShiftIntensityd(keys=["image"], offsets=0.25, prob=0.3),
            EnsureTyped(keys=SPATIAL_KEYS),
        ]

        base_transforms = [
            LoadImaged(keys=['image', 'label']),
            EnsureChannelFirstd(keys=["image", "label"]),
            DivisiblePadd(keys=["image", "label"], k=16),
            Lambdad(keys=["label"], func=lambda x: (x > 0).astype(x.dtype)),
            ComputeVoronoiMapsd(keys=["label"]),
            EnsureChannelFirstd(
                keys=["voronoi", "instances"], channel_dim="no_channel"),
            ComputeWeightMapsd(
                keys=["label"], concept=self.weight_map, mountain_sigma_sc=2, island_sigma_sc=5),
            ScaleIntensityd(['image']),
            NormalizeIntensityd(keys=["image"]),
            EnsureTyped(keys=SPATIAL_KEYS),
        ]
        if self.data_dir.endswith('/sbm'):
            assert self.task in [
                'mets'], f"Task {self.task} and dataset {self.data_dir} do not match"
            print('Creating SBM datasets from volumes...')
            self.roi_size = (128, 128, 96)
            self.train_ds = create_random_patch_dataset(
                train_files, SPATIAL_KEYS, base_transforms, train_transforms, roi_size=self.roi_size, num_patches_per_image=18, cache_rate=0.5)
            self.val_ds = Dataset(
                data=val_files,
                transform=Compose(base_transforms),
            )
            self.test_ds = Dataset(
                data=test_files,
                transform=Compose(base_transforms),
            )
        else:
            raise NotImplementedError()

    def train_dataloader(self):
        return DataLoader(
            self.train_ds, batch_size=self.batch_size, num_workers=8, collate_fn=list_data_collate)

    def val_dataloader(self):
        return DataLoader(self.val_ds, batch_size=1, num_workers=8)

    def test_dataloader(self):
        return DataLoader(self.test_ds, batch_size=1, num_workers=4)

    def configure_optimizers(self):
        optimizer = torch.optim.AdamW(
            self.parameters(),
            lr=self.lr,
        )

        # scheduler = WarmupCosineSchedule(
        #    optimizer,
        #    t_total=self.trainer.max_epochs,
        #    warmup_steps=5
        # )
        scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
            optimizer, mode="max", factor=0.5, patience=15)

        return {
            "optimizer": optimizer,
            "lr_scheduler": {
                "scheduler": scheduler,
                "monitor": "val/dice",
                "interval": "epoch",
                "frequency": 1,
            },
        }

    def on_fit_start(self):
        total_params = sum(p.numel() for p in self.parameters())
        trainable_params = sum(p.numel()
                               for p in self.parameters() if p.requires_grad)

        tb = self.logger.experiment
        tb.add_scalar("model/total_params", total_params, 0)
        tb.add_scalar("model/trainable_params", trainable_params, 0)

    def training_step(self, batch, batch_idx):
        images = batch["image"]
        outputs = self.forward(images)

        loss = self.loss_function(outputs, batch['label'])

        preds_list = [self.post_trans(i) for i in decollate_batch(outputs)]
        labels_list = decollate_batch(batch["label"])
        self.dice(y_pred=preds_list, y=labels_list)
        self.log("train/loss", loss, on_epoch=True,
                 on_step=False, prog_bar=True)
        self.log("train/dice", self.dice.aggregate().item(),
                 on_step=False, on_epoch=True)
        self.log("train/lr", self.optimizers(
        ).param_groups[0]["lr"], on_step=False, on_epoch=True)
        return loss

    def validation_step(self, batch, batch_idx):
        images = batch["image"]
        outputs = self(images)
        val_loss = self.loss_function(outputs, batch['label'])

        preds = self.post_trans(outputs)
        self.dice(y_pred=preds, y=batch["label"])
        self.log("val/loss", val_loss, on_epoch=True,
                 on_step=False, batch_size=images.shape[0])
        self.f1(preds, batch["label"])
        self.log("val/f1", self.f1, on_epoch=True)
        if self.current_epoch > 20:  # Panoptica instance wise needs a while before it can be applied due to instability early
            self.instance_f1.append(self.evaluator.evaluate(preds.detach().cpu().numpy().squeeze(
            ), batch['label'].detach().cpu().numpy().squeeze(), log_times=False, verbose=False)['instance'].rq)
        else:
            self.instance_f1.append(0.5)
        self.precision(preds, batch["label"])
        self.log("val/precision", self.precision, on_epoch=True)
        self.recall(preds, batch["label"])
        self.log("val/recall", self.recall, on_epoch=True)

        if self.current_epoch % 10 == 0 and len(self.validation_vis_samples) < 4:
            self.validation_vis_samples.append((batch, outputs))

        return val_loss

    def on_validation_epoch_end(self):
        mean_dice = self.dice.aggregate().item()
        self.log("val/instance_f1",
                 statistics.mean(self.instance_f1), prog_bar=False)
        self.instance_f1 = []
        self.log("val/dice", mean_dice, prog_bar=True)
        self.dice.reset()

        if mean_dice > self.best_val_dice:
            self.best_val_dice = mean_dice
            self.best_val_epoch = self.current_epoch
        if self.validation_vis_samples:
            self._visualize_val_samples(self.validation_vis_samples)
            self.validation_vis_samples.clear()

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
            img = batch['image'].detach().cpu().numpy().squeeze()[:, :, 30]
            gt_label = batch['label'].detach().cpu().numpy().squeeze()[
                :, :, 30]
            gt_voronoi = batch['voronoi'].detach().cpu().numpy().squeeze()[
                :, :, 30]
            weight_map = batch['weight_map'].detach(
            ).cpu().numpy().squeeze()[:, :, 30]
            pred_mask = (outputs.detach().cpu().numpy().squeeze()
                         > 0.5).astype(np.float32)[:, :, 30]

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
        self.logger.experiment.add_figure("val/samples", fig, self.global_step)
        plt.close(fig)

    def on_fit_end(self):
        print(
            f"Training completed. Best Dice Score: {self.best_val_dice:.4f} at Epoch: {self.best_val_epoch}")
        self.logger.log_hyperparams(
            params=dict(self.hparams),
            metrics={
                "best_val_dice": self.best_val_dice,
                "best_val_epoch": self.best_val_epoch,
            },
        )
