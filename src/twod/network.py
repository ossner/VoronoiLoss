import torch
import pytorch_lightning as pl
from monai.networks.nets import UNet
from monai.losses import DiceCELoss
from monai.metrics import DiceMetric, MeanIoU
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
import numpy as np
from VoronoiTransform import ComputeVoronoiMapsd, voronoi_map_from_binary_mask
from CCDiceCELoss import CCDiceCELoss
from monai.data import decollate_batch
from monai.data import CacheDataset, DataLoader
from monai.utils import set_determinism
from util import get_data_dicts, instance_f1_score
from skimage.measure import label
from stardist.matching import matching_dataset
import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.colors import ListedColormap
matplotlib.use("Agg")  # non-interactive backend suitable for scripts


class PlateletSegmentationModel(pl.LightningModule):
    def __init__(self, data_dir, lr=1e-3, batch_size=8, loss='DiceCE', seed=0, alpha=1.0, beta=1.0, region_weighting = False):
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
        self.loss = loss
        self.alpha = alpha / (alpha + beta)
        self.beta = beta / (alpha + beta)
        if loss == 'DiceCE':
            self.loss_function = DiceCELoss(sigmoid=True)
        elif loss == 'CCDiceCE':
            self.loss_function = CCDiceCELoss(alpha=self.alpha, beta=self.beta, region_weighting=region_weighting)
        else:
            raise NotImplementedError('No Such loss function implemented')
        self.dice = DiceMetric(
            include_background=False,
            reduction="mean",
        )
        self.iou = MeanIoU(include_background=False, reduction="mean")

        self.post_trans = Compose([
            Activations(sigmoid=True),
            AsDiscrete(threshold=0.5)
        ])

        self.lr = lr
        self.batch_size = batch_size

        self.best_val_dice = 0.0
        self.best_val_epoch = 0
        self.validation_step_outputs = []
        self.test_instance_f1_scores = []
        self.seed = seed
        self.data_dir = data_dir
        
        self.save_hyperparameters(
            "lr", "batch_size", "alpha", "beta", "loss", "region_weighting")

    def forward(self, x):
        return self.model(x)

    def prepare_data(self):
        set_determinism(seed=self.seed)

        train_files = get_data_dicts(self.data_dir, "train")
        val_files = get_data_dicts(self.data_dir, "val")
        test_files = get_data_dicts(self.data_dir, "test")
        
        base_normalization = [
            LoadImaged(keys=['image', 'label']),
            EnsureChannelFirstd(keys=["image", "label"],
                                channel_dim="no_channel"),
            Lambdad(keys=["label"], func=lambda x: x /
                    255.0),
            ScaleIntensityd(['image'])
        ]

        train_transforms = Compose([
            *base_normalization,
            # --- Geometric Augmentations ---
            RandFlipd(keys=["image", "label"], prob=0.5, spatial_axis=0),
            RandFlipd(keys=["image", "label"], prob=0.5, spatial_axis=1),
            RandRotate90d(keys=["image", "label"], prob=0.5, max_k=3),
            RandRotated(
                keys=["image", "label"],
                range_x=0.26,  # ±15 degrees
                prob=0.4,
                mode=["bilinear", "nearest"],
                padding_mode="zeros",
            ),
            CenterSpatialCropd(
                keys=["image", "label"],
                roi_size=(288, 288)
            ),
            RandZoomd(
                keys=["image", "label"],
                min_zoom=0.9,
                max_zoom=1.1,
                prob=0.3,
                mode=["area", "nearest"],
                padding_mode="constant",
            ),
            Rand2DElasticd(
                keys=["image", "label"],
                spacing=(48, 48),
                magnitude_range=(3, 6),
                prob=0.3,
                mode=["bilinear", "nearest"],
                padding_mode="zeros",
            ),
            RandGaussianSmoothd(
                keys=["image"],
                prob=0.3
            ),
            RandGaussianNoised(
                keys=["image"],
                mean=0.0,
                std=0.1,
                prob=0.3,
            ),
            RandScaleIntensityd(keys=["image"], factors=0.2, prob=0.3),
            RandShiftIntensityd(keys=["image"], offsets=0.2, prob=0.3),
            ComputeVoronoiMapsd(keys=["label"]),
            EnsureTyped(keys=["image", "label"]),
        ])

        val_transforms = Compose([
            *base_normalization,
            CenterSpatialCropd(
                keys=["image", "label"],
                roi_size=(288, 288)
            ),
            ComputeVoronoiMapsd(keys=["label"]),
            EnsureTyped(keys=["image", "label"]),
        ])

        self.train_ds = CacheDataset(
            data=train_files, transform=train_transforms,
            cache_rate=1.0,  # Cache everything
            num_workers=4)

        self.val_ds = CacheDataset(data=val_files, transform=val_transforms,
                                   cache_rate=1.0)

        self.test_ds = CacheDataset(data=test_files, transform=val_transforms,
                                    cache_rate=1.0)

    def train_dataloader(self):
        return DataLoader(
            self.train_ds, batch_size=self.batch_size, shuffle=True, num_workers=4)

    def val_dataloader(self):
        return DataLoader(self.val_ds, batch_size=2, num_workers=4)

    def test_dataloader(self):
        return DataLoader(self.test_ds, num_workers=4)

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

        # Log augmented samples
        self._visualiza_augmentations()

    def _visualiza_augmentations(self, num_samples=8):
        """Log multiple augmented versions of the same samples to visualize augmentations"""
        tb = self.logger.experiment

        idx = 0
        original_sample = self.train_ds.data[idx]  # Get raw data dict

        # Create a figure showing original + multiple augmented versions
        fig, axes = plt.subplots(
            3, num_samples, figsize=(num_samples * 3, 9))

        # Apply transforms multiple times to see variation
        for aug_idx in range(num_samples):
            # Apply the full transform pipeline
            transformed = self.train_ds.transform(original_sample)

            # Remove channel dim
            img = transformed["image"][0].cpu().numpy()
            label = transformed["label"][0].cpu().numpy()

            # Row 1: Augmented image
            axes[0, aug_idx].imshow(img, cmap="gray")
            axes[0, aug_idx].set_title(f"Aug {aug_idx + 1}")
            axes[0, aug_idx].axis("off")

            # Row 2: Augmented label
            axes[1, aug_idx].imshow(label, cmap="gray")
            axes[1, aug_idx].axis("off")

            # Row 3: Overlay
            axes[2, aug_idx].imshow(img, cmap="gray")
            axes[2, aug_idx].imshow(label, alpha=0.5, cmap="Reds")
            axes[2, aug_idx].axis("off")

            # Labels for rows
            axes[0, 0].set_ylabel("Image", fontsize=12)
            axes[1, 0].set_ylabel("Label", fontsize=12)
            axes[2, 0].set_ylabel("Overlay", fontsize=12)

            fig.suptitle(
                f"Augmentation Samples - Training Sample {idx}", fontsize=14)
            plt.tight_layout()

            # Log to tensorboard
            tb.add_figure(f"augmentation_sample", fig, 0)
            plt.close(fig)

        print(
            f"✓ Logged a sample augmentation to TensorBoard")

    def training_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]
        outputs = self.forward(images)
        if self.loss == 'CCDiceCE':
            voronoi_map = batch["voronoi"]
            label_instances = batch["instances"]
            loss = self.loss_function(
                outputs, labels, voronoi_map, label_instances)
        elif self.loss == "DiceCE":
            loss = self.loss_function(outputs, labels)

        self.log("train_loss", loss, on_epoch=True,
                 on_step=False, prog_bar=True)
        return loss
    
    def on_train_epoch_end(self):
        optimizer = self.optimizers()
        lr = optimizer.param_groups[0]["lr"]
        self.log("lr", lr, prog_bar=True, on_epoch=True)


    def validation_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]
        outputs = self(images)

        voronoi, instance_labels = None, None
        if self.loss == 'CCDiceCE':
            voronoi = batch["voronoi"]
            instance_labels = batch["instances"]
            val_loss = self.loss_function(
                outputs, labels, voronoi, instance_labels)
        elif self.loss == "DiceCE":
            val_loss = self.loss_function(outputs, labels)

        preds_list = [self.post_trans(i) for i in decollate_batch(outputs)]
        labels_list = decollate_batch(labels)

        self.dice(y_pred=preds_list, y=labels_list)
        self.iou(y_pred=preds_list, y=labels_list)

        self.log("val_loss", val_loss, on_epoch=True,
                 on_step=False, batch_size=images.shape[0])

        if self.current_epoch % 10 == 0 and batch_idx == 0:
            # Pass the first item of the batch for the extra maps
            v_img = voronoi if voronoi is not None else None
            v_lab = instance_labels if instance_labels is not None else None
            self._visualize_val_samples(
                images, labels, preds_list, v_img, v_lab)

        return val_loss

    def _visualize_val_samples(self, img, label, pred, voronoi=None, v_labels=None):
        n_cols = 3
        n_rows = 2
        fig, ax = plt.subplots(n_rows, n_cols, figsize=(4 * n_cols, 4*n_rows))

        # Standard image visualization
        for idx in [0, 1]:
            img_cpu = img[idx][0].cpu().numpy()
            ax[idx, 0].imshow(img_cpu, cmap="gray")
            ax[idx, 0].set_title("Original Image")

            # Labels + Label Voronoi Map
            ax[idx, 1].imshow(img_cpu, cmap="gray")
            ax[idx, 1].imshow(label[idx][0].cpu(), alpha=0.75, cmap="Blues")
            if voronoi is not None:
                ax[idx, 1].imshow(voronoi[idx].cpu().numpy(), alpha=0.33, cmap=ListedColormap(np.insert(np.random.rand(
                    int(v_labels[idx].max()) + 1, 3), 0, [0, 0, 0], axis=0)),
                    interpolation='nearest')
                ax[idx, 1].set_title(
                    f"GT Instances (Count: {int(v_labels[idx].max())})")
            else:
                ax[idx, 1].set_title("Ground Truth")

            # Predictions + Voronoi Map
            ax[idx, 2].imshow(img_cpu, cmap="gray")
            ax[idx, 2].imshow(pred[idx][0].cpu(), alpha=0.75, cmap="Reds")
            if voronoi is not None:
                voronoi_map, labeled_array = voronoi_map_from_binary_mask(
                    pred[idx][0].cpu())
                ax[idx, 2].imshow(voronoi_map, alpha=0.33, cmap=ListedColormap(np.insert(np.random.rand(
                    int(labeled_array.max()) + 1, 3), 0, [0, 0, 0], axis=0)),
                    interpolation='nearest')
                ax[idx, 2].set_title(
                    f"Pred Instances (Count: {int(labeled_array.max())})")
            else:
                ax[idx, 2].set_title("Prediction")

        plt.tight_layout()
        self.logger.experiment.add_figure("val_samples", fig, self.global_step)
        plt.close(fig)

    def on_validation_epoch_end(
            self):
        mean_dice = self.dice.aggregate().item()
        mean_iou = self.iou.aggregate().item()

        self.log("val_dice", mean_dice, prog_bar=True)
        self.log("val_iou", mean_iou)

        self.dice.reset()
        self.iou.reset()

        if mean_dice > self.best_val_dice:
            self.best_val_dice = mean_dice
            self.best_val_epoch = self.current_epoch

    def on_fit_end(self):
        # This runs at the very end of training
        print(
            f"Training completed. Best Dice Score: {self.best_val_dice:.4f} at Epoch: {self.best_val_epoch}")

        self.dice.reset()
        self.iou.reset()
        self.logger.log_hyperparams(
            params=dict(self.hparams),
            metrics={
                "best_val_dice": self.best_val_dice,
                "best_val_epoch": self.best_val_epoch,
            },
        )


    def on_test_start(self):
        # Initialize containers to store labels across the whole test set
        self.test_step_outputs_gt = []
        self.test_step_outputs_pred = []

    def test_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]

        logits = self(images)
        preds = self.post_trans(logits)

        self.dice(preds, labels)
        self.iou(preds, labels)
        
        preds_np = preds.cpu().numpy().astype(np.uint8)
        masks_np = labels.cpu().numpy().astype(np.uint8)

        for i in range(preds_np.shape[0]):
            # Label connected components (the actual platelets)
            self.test_step_outputs_pred.append(label(preds_np[i].squeeze()))
            self.test_step_outputs_gt.append(label(masks_np[i].squeeze()))


    def on_test_epoch_end(self):
        dice = self.dice.aggregate().item()
        iou = self.iou.aggregate().item()

        self.log("test_dice", dice, prog_bar=True, sync_dist=True)
        self.log("test_iou", iou, prog_bar=True, sync_dist=True)

        self.dice.reset()
        self.iou.reset()
        
        results = matching_dataset(
            self.test_step_outputs_gt,
            self.test_step_outputs_pred,
            thresh=0.5,
            show_progress=True
        )

        # Log the main metrics back to the logger (TensorBoard)
        self.log("metrics/PQ", results.panoptic_quality)
        self.log("metrics/Recall", results.recall)
        self.log("metrics/Precision", results.precision)

        # Create a detailed report for the console/notebook
        print("\n" + "="*30)
        print("INSTANCE EVALUATION REPORT")
        print("="*30)
        metrics_df = pd.DataFrame([results._asdict()])
        print(metrics_df[['panoptic_quality',
              'recall', 'precision', 'f1']].to_string())

        self.test_step_outputs_gt.clear()
        self.test_step_outputs_pred.clear()
