from monai.transforms import AsDiscrete
from monai.metrics import DiceMetric, MeanIoU
import numpy as np
import glob
import os
import shutil
import tempfile
import matplotlib.pyplot as plt
import pytorch_lightning
from monai.utils import set_determinism
from monai.transforms import (
    AsDiscrete,
    EnsureChannelFirstd,
    Compose,
    CropForegroundd,
    LoadImaged,
    Orientationd,
    NormalizeIntensityd,
    RandCropByPosNegLabeld,
    ScaleIntensityRanged,
    Spacingd,
    RandFlipd,
    RandAdjustContrastd,
    RandRotate90d,
    RandGaussianNoised,
    RandGaussianSmoothd,
    RandSpatialCropd,
    EnsureType,
    Rand3DElasticd,
    RandZoomd,
    RandShiftIntensityd,
    RandScaleIntensityd,
    RandSimulateLowResolutiond
)
from monai.networks.nets import UNet
from monai.networks.layers import Norm
from monai.metrics import DiceMetric
from monai.losses import DiceLoss, DiceCELoss
from monai.inferers import sliding_window_inference
from monai.data import CacheDataset, list_data_collate, decollate_batch, DataLoader
import torch
import matplotlib
from sklearn.model_selection import train_test_split
matplotlib.use("Agg")  # non-interactive backend suitable for scripts


class Net(pytorch_lightning.LightningModule):
    def __init__(self, task_data_dir, backbone_name="UNet", loss_type="DiceCE", test_size=0.2, lr=1e-3, **kwargs):
        super().__init__()
        if backbone_name == 'UNet':
            self._model = UNet(
                spatial_dims=3,
                in_channels=1,
                out_channels=2,
                channels=(16, 32, 64, 128),
                strides=(2, 2, 2),
                num_res_units=2,
                norm=Norm.BATCH,
            )
        else:
            raise ValueError

        if loss_type == 'DiceCE':
            self.loss_function = DiceCELoss(to_onehot_y=True, softmax=True)
        elif loss_type == 'Dice':
            self.loss_function = DiceLoss(to_onehot_y=True, softmax=True)
        else:
            raise ValueError

        self.post_pred = Compose(
            [EnsureType("tensor", device="cpu"), AsDiscrete(argmax=True, to_onehot=2)])
        self.post_label = Compose(
            [EnsureType("tensor", device="cpu"), AsDiscrete(to_onehot=2)])
        self.dice_metric = DiceMetric(
            include_background=False, reduction="mean", get_not_nans=False)
        self.iou_metric = MeanIoU(include_background=False, reduction="mean")
        
        self.test_size = test_size
        
        self.save_hyperparameters()

        self.best_val_dice = 0
        self.best_val_epoch = 0
        self.validation_step_outputs = []
        self.task_data_dir = task_data_dir

    def forward(self, x):
        return self._model(x)

    def prepare_data(self):
        # set up the correct data path
        train_images = sorted(glob.glob(os.path.join(
            self.task_data_dir, "imagesTr", "*.nii.gz")))
        train_labels = sorted(glob.glob(os.path.join(
            self.task_data_dir, "labelsTr", "*.nii.gz")))
        data_dicts = [
            {"image": image_name, "label": label_name} for image_name, label_name in zip(train_images, train_labels)
        ]
        train_files, val_files = train_test_split(
            data_dicts,
            test_size=self.test_size,
            random_state=42,
            shuffle=True,
        )

        # set deterministic training for reproducibility
        set_determinism(seed=0)

        # define the data transforms
        train_transforms = Compose(
            [
                LoadImaged(keys=["image", "label"]),
                EnsureChannelFirstd(keys=["image", "label"]),
                Orientationd(keys=["image", "label"], axcodes="RAS"),
                Spacingd(
                    keys=["image", "label"],
                    pixdim=(10, 10, 40),
                    mode=("bilinear", "nearest"),
                ), NormalizeIntensityd(
                    keys=["image"],
                    nonzero=False,
                    channel_wise=True
                ), RandSpatialCropd(
                    keys=["image", "label"],
                    roi_size=(256, 256, 48),
                    random_center=True,
                    random_size=False
                ),
                RandFlipd(keys=["image", "label"], prob=0.5, spatial_axis=0),
                RandFlipd(keys=["image", "label"], prob=0.5, spatial_axis=1),
                RandFlipd(keys=["image", "label"], prob=0.5, spatial_axis=2),
                RandRotate90d(keys=["image", "label"], prob=0.5, max_k=3),
                RandGaussianNoised(
                    keys=["image"], prob=0.15, mean=0.0, std=0.1),
                RandGaussianSmoothd(
                    keys=["image"],
                    sigma_x=(0.5, 1.15),
                    sigma_y=(0.5, 1.15),
                    sigma_z=(0.5, 1.15),
                    prob=0.15,
                ),
                RandAdjustContrastd(
                    keys=["image"], prob=0.15, gamma=(0.7, 1.5)),
                Rand3DElasticd(
                    keys=["image", "label"],
                    sigma_range=(5, 8),
                    magnitude_range=(100, 200),
                    prob=0.15,
                    spatial_size=(256, 256, 48),
                    mode=("bilinear", "nearest"),
                ),
                RandZoomd(
                    keys=["image", "label"],
                    min_zoom=0.9,
                    max_zoom=1.1,
                    mode=("bilinear", "nearest"),
                    prob=0.15,
                ),
                RandScaleIntensityd(keys="image", factors=0.4, prob=0.15),
                RandShiftIntensityd(keys="image", offsets=0.4, prob=0.15),
                RandSimulateLowResolutiond(
                    keys=["image"],
                    zoom_range=(0.5, 1.0),
                    prob=0.15,
                )
            ]
        )
        val_transforms = Compose(
            [
                LoadImaged(keys=["image", "label"]),
                EnsureChannelFirstd(keys=["image", "label"]),
                Orientationd(keys=["image", "label"], axcodes="RAS"),
                Spacingd(
                    keys=["image", "label"],
                    pixdim=(10, 10, 40),
                    mode=("bilinear", "nearest"),
                ), NormalizeIntensityd(
                    keys=["image"],
                    nonzero=False,
                    channel_wise=True
                ),
            ]
        )

        # we use cached datasets - these are 10x faster than regular datasets
        self.train_ds = CacheDataset(
            data=train_files,
            transform=train_transforms,
            cache_rate=1.0,
            num_workers=4,
        )
        self.val_ds = CacheDataset(
            data=val_files,
            transform=val_transforms,
            cache_rate=1.0,
            num_workers=4,
        )

    def train_dataloader(self):
        train_loader = DataLoader(
            self.train_ds,
            batch_size=2,
            shuffle=True,
            num_workers=4,
            collate_fn=list_data_collate,
        )
        return train_loader

    def val_dataloader(self):
        val_loader = DataLoader(self.val_ds, batch_size=1, num_workers=4)
        return val_loader

    def configure_optimizers(self):
        optimizer = torch.optim.Adam(self._model.parameters(), 1e-4)
        return optimizer

    def training_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]
        output = self.forward(images)
        loss = self.loss_function(output, labels)
        self.log(
            "train_loss",
            loss,
            on_step=True,
            on_epoch=True,
            prog_bar=True,
            logger=True,
        )
        return loss

    def validation_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]
        roi_size = (256, 256, 48)
        sw_batch_size = 4
        outputs = sliding_window_inference(
            images, roi_size, sw_batch_size, self.forward)
        loss = self.loss_function(outputs, labels)
        processed_outputs = [self.post_pred(i)
                             for i in decollate_batch(outputs)]
        processed_labels = [self.post_label(i)
                            for i in decollate_batch(labels)]
        self.dice_metric(y_pred=processed_outputs, y=processed_labels)
        self.iou_metric(y_pred=processed_outputs, y=processed_labels)
        # Log images every 20 epochs, only for the first batch of the validation set
        if self.current_epoch % 10 == 0 and batch_idx == 0:
            # Take the first image in the batch
            img = images[0].detach().cpu().numpy()  # [C, H, W, D]
            lab = labels[0].detach().cpu().numpy()  # [C, H, W, D]
            # Get argmax of prediction for visualization
            pred = torch.argmax(outputs[0], dim=0,
                                keepdim=True).detach().cpu().numpy()

            # Select middle slice in the Z-axis (Depth)
            mid_slice = img.shape[-1] // 2

            # Create a 3-panel figure: Image, Label, Prediction
            fig, axes = plt.subplots(1, 3, figsize=(15, 5))
            axes[0].imshow(img[0, :, :, mid_slice], cmap="gray")
            axes[0].set_title("Image")
            axes[1].imshow(lab[0, :, :, mid_slice])
            axes[1].set_title("Label")
            axes[2].imshow(pred[0, :, :, mid_slice])
            axes[2].set_title("Prediction")

            # Log to TensorBoard
            self.logger.experiment.add_figure(
                f"segmentation_vis",
                fig,
                global_step=self.global_step
            )
            plt.close(fig)
        # -------------------------------

        self.validation_step_outputs.append({
            "val_loss": loss.detach(),
            "val_number": len(processed_outputs),
        })
        return loss

    def on_fit_start(self):
        total_params = sum(p.numel() for p in self.parameters())
        trainable_params = sum(p.numel()
                               for p in self.parameters() if p.requires_grad)

        tb = self.logger.experiment
        tb.add_scalar("model/total_params", total_params, 0)
        tb.add_scalar("model/trainable_params", trainable_params, 0)

    def on_validation_epoch_end(self):
        val_loss, num_items = 0, 0
        for output in self.validation_step_outputs:
            val_loss += output["val_loss"].sum().item()
            num_items += output["val_number"]

        # Dice
        mean_val_dice = self.dice_metric.aggregate().item()
        self.dice_metric.reset()
        self.log("val_dice", mean_val_dice, prog_bar=True, logger=True)
        # IoU
        mean_val_iou = self.iou_metric.aggregate().item()
        self.iou_metric.reset()
        self.log("val_iou", mean_val_iou, prog_bar=True)
        # Loss
        mean_val_loss = torch.tensor(val_loss / num_items)
        self.log("val_loss", mean_val_loss, prog_bar=True, logger=True)

        self.validation_step_outputs.clear()

        if mean_val_dice > self.best_val_dice:
            self.best_val_dice = mean_val_dice
            self.best_val_epoch = self.current_epoch
        print(
            f"current epoch: {self.current_epoch} "
            f"current mean dice: {mean_val_dice:.4f}"
            f" best dice {self.best_val_dice:.4f} at epoch: {self.best_val_epoch}"
        )

    def on_train_end(self):
        # This runs at the very end of training
        print(
            f"Training completed. Best Dice Score: {self.best_val_dice:.4f} at Epoch: {self.best_val_epoch}")
        # You could also log this to a text file or as a hyperparameter metric
        self.logger.log_hyperparams(
            params={"max_epochs": self.trainer.max_epochs, "lr": 1e-4},
            metrics={"final_best_dice": self.best_val_dice}
        )
