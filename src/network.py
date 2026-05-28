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
    EnsureTyped,
    RandZoomd,
    CopyItemsd,
    RandGaussianNoised,
    RandGaussianSmoothd,
    Lambdad,
    RandScaleIntensityd,
    RandShiftIntensityd,
)
import os
import numpy as np
import json
from VoronoiTransform import ComputeVoronoiMapsd
from monai.data import decollate_batch, DataLoader, list_data_collate
from monai.utils import set_determinism
from monai.networks.layers import Norm
from monai.optimizers import WarmupCosineSchedule
from util import get_data_dicts, split_gt_by_volume, to_serializable, configure_datasets, save_as_nifti, save_2d_as_png
import statistics
from PIL import Image
import nibabel as nib
from LossWrapper import WeightedLossWrapper
from lightning.pytorch.utilities import grad_norm
from torchmetrics.classification import BinaryPrecision, BinaryRecall, BinaryFBetaScore
from panoptica import Panoptica_Evaluator, Panoptica_Aggregator, Panoptica_Statistic
from WeightMapTransforms import ComputeWeightMapsd
from CCMetrics import CCDiceMetric


class InstanceSegmentationModel(pl.LightningModule):
    def __init__(self, data_dir, dataset_config, loss_dict, weight_map, lr, seed, adaptive=True):
        super().__init__()
        set_determinism(seed=seed)
        # Initialize adaptive Unet that changes dimensions and channels based on the data
        self.model = UNet(
            spatial_dims=dataset_config['dimensions'],
            in_channels=dataset_config['channels'],
            out_channels=1,
            channels=(32, 64, 128, 256, 512),
            strides=(2, 2, 2, 2),
            num_res_units=2,
            norm=Norm.BATCH,
        )
        self.adaptive = adaptive
        self.loss_function = WeightedLossWrapper(loss_dict=loss_dict, adaptive=self.adaptive) # Intialize losses with relative weights as specified
        self.weight_map = weight_map
        self.dice = DiceMetric(
            include_background=True,
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
            "src/eval/panoptica_config.yaml")
        self.instance_f1 = []
        self.instance_recall = []
        self.instance_dice = []
        self.lr = lr
        self.batch_size = dataset_config['batch_size']
        self.dataset_config = dataset_config
        self.data_dir = data_dir
        self.save_hyperparameters(
            'dataset_config', 'loss_dict', 'adaptive', "lr", 'weight_map', 'seed')

    def forward(self, x):
        return self.model(x)

    def prepare_data(self):
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
            CopyItemsd(keys=['label'], times=1, names=['label_path']),
            LoadImaged(keys=['image', 'label']),
            EnsureChannelFirstd(keys=["image", "label"]),
            DivisiblePadd(keys=["image", "label"], k=16),
            Lambdad(keys=["label"], func=lambda x: (x == self.dataset_config['label']).astype(x.dtype)),
            ComputeVoronoiMapsd(keys=["label"]),
            EnsureChannelFirstd(
                keys=["voronoi", "instances"], channel_dim="no_channel"),
            ComputeWeightMapsd(
                keys=["label"], concept=self.weight_map, mountain_sigma_sc=2, island_sigma_sc=5),
            NormalizeIntensityd(['image']),
            EnsureTyped(keys=SPATIAL_KEYS),
        ]
        
        train_files = get_data_dicts(self.data_dir, "train", self.dataset_config)
        val_files = get_data_dicts(self.data_dir, "val", self.dataset_config)
        test_files = get_data_dicts(self.data_dir, "test", self.dataset_config)
        self.train_ds, self.val_ds, self.test_ds = configure_datasets(self.dataset_config, train_files, val_files, test_files, base_transforms, train_transforms, SPATIAL_KEYS)

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

    def training_step(self, batch, batch_idx):
        images = batch["image"]
        outputs = self.forward(images)

        loss = self.loss_function(outputs, batch)

        preds_list = [self.post_trans(i) for i in decollate_batch(outputs)]
        labels_list = decollate_batch(batch["label"])
        self.dice(y_pred=preds_list, y=labels_list)
        self.log("train/loss", loss, on_epoch=True,
                 on_step=False, prog_bar=True, batch_size=self.dataset_config['batch_size'])
        self.log("train/lr", self.optimizers(
        ).param_groups[0]["lr"], on_step=False, on_epoch=True, batch_size=self.dataset_config['batch_size'])
        return loss

    def on_before_optimizer_step(self, optimizer):
        total_grad_norm = grad_norm(self, norm_type=2)
        self.log_dict(total_grad_norm)

    def validation_step(self, batch, batch_idx):
        images, labels = batch["image"], batch["label"]
        outputs = self(images)
        preds = self.post_trans(outputs)

        # Calculate global metrics
        self.recall(preds, labels)
        self.precision(preds, labels)
        self.f2(preds, labels)
        self.dice(preds, labels)

        val_loss = self.loss_function(outputs, batch)
        self.log("val/loss", val_loss, on_epoch=True,
                 on_step=False)
        self.log("val/precision", self.precision, on_epoch=True)
        self.log("val/recall", self.recall, on_epoch=True)
        self.log("val/f2", self.f2, on_epoch=True)

        preds_np = preds.detach().cpu().numpy().squeeze()
        labels_np = labels.detach().cpu().numpy().squeeze()
        if self.current_epoch > (self.trainer.max_epochs * 0.05):  # Panoptica instance wise needs a while before it can be applied due to instability early
            try:
                panoptica_metrics = self.evaluator.evaluate(
                    preds_np, labels_np, log_times=False, verbose=False)['instance']
                self.instance_f1.append(panoptica_metrics.rq)
                self.instance_recall.append(panoptica_metrics.rec)
                self.instance_dice.append(panoptica_metrics.sq_dsc)
            except:
                self.instance_f1.append(0.5)
                self.instance_recall.append(0.5)
                self.instance_dice.append(0.5)
        else:
            self.instance_f1.append(0.5)
            self.instance_recall.append(0.5)
            self.instance_dice.append(0.5)
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
        if batch_idx == 0:
            os.makedirs(f"{self.logger.log_dir}/val_sample_0/", exist_ok=True)
            if not self.dataset_config['dimensions'] == 2:
                if self.current_epoch == 0:
                    save_as_nifti(images, f"{self.logger.log_dir}/val_sample_0/image.nii.gz", is_multichannel=True)
                    save_as_nifti(batch["label"], f"{self.logger.log_dir}/val_sample_0/labels.nii.gz")
                    save_as_nifti(batch["voronoi"], f"{self.logger.log_dir}/val_sample_0/voronoi.nii.gz")
                    save_as_nifti(batch['weight_map'], f"{self.logger.log_dir}/val_sample_0/weight_map.nii.gz")
                elif self.adaptive:
                    weight_map = self.loss_function.adapt_weight_map_budget(y_pred=outputs, batch=batch)['weight_map'] if self.adaptive else batch['weight_map']
                    save_as_nifti(weight_map, f"{self.logger.log_dir}/val_sample_0/weight_map.nii.gz")
                save_as_nifti(preds, f"{self.logger.log_dir}/val_sample_0/preds.nii.gz")
            else:
                if self.current_epoch == 0:
                    save_2d_as_png(images, f"{self.logger.log_dir}/val_sample_0/image")
                    save_2d_as_png(batch["label"], f"{self.logger.log_dir}/val_sample_0/labels")
                    save_2d_as_png(batch["voronoi"], f"{self.logger.log_dir}/val_sample_0/voronoi")
                    save_2d_as_png(batch['weight_map'], f"{self.logger.log_dir}/val_sample_0/weight_map")
                elif self.adaptive:
                    weight_map = self.loss_function.adapt_weight_map_budget(y_pred=outputs, batch=batch)['weight_map'] if self.adaptive else batch['weight_map']
                    save_2d_as_png(weight_map, f"{self.logger.log_dir}/val_sample_0/weight_map")
                save_2d_as_png(preds, f"{self.logger.log_dir}/val_sample_0/preds")
                
        return val_loss

    def on_validation_epoch_end(self):
        self.log("val/instance_f1",
                 statistics.mean(self.instance_f1), prog_bar=False, sync_dist=True)
        self.instance_f1 = []
        self.log("val/instance_recall",
                 statistics.mean(self.instance_recall), prog_bar=False, sync_dist=True)
        self.instance_recall = []
        self.log("val/instance_dice",
                 statistics.mean(self.instance_dice), prog_bar=False, sync_dist=True)
        self.instance_dice = []
        self.log("val/ccdice",
                 self.cc_dice.cc_aggregate().mean().item(), on_epoch=True, sync_dist=True)
        self.cc_dice.reset()
        val_dice = self.dice.aggregate().item()
        self.log("val/dice", val_dice, prog_bar=True, sync_dist=True)
        self.dice.reset()
        
    def on_fit_end(self):
        self.logger.log_hyperparams(
            params=dict(self.hparams)
        )

    def on_test_start(self):
        self.recall.reset()
        self.precision.reset()
        self.cc_dice.reset()
        self.dice.reset()
        self.f2.reset()
        self.quartile_recalls = {
            "q0": [],
            "q1": [],
            "q2": [],
            "q3": []
        }
        self.aggregator = Panoptica_Aggregator(
            panoptica_evaluator=self.evaluator, output_file=f'{self.logger.log_dir}/eval.tsv')
        os.makedirs(f'{self.logger.log_dir}/preds/')

    def test_step(self, batch, batch_idx):
        casename = os.path.basename(batch['label_path'][0]).split('.')[0]
        images, labels = batch["image"], batch["label"]
        outputs = self(images)
        preds = self.post_trans(outputs)

        # Calculate global metrics
        self.recall(preds, labels)
        self.precision(preds, labels)
        self.f2(preds, labels)
        self.dice(preds, labels)

        # image = images.cpu().numpy().squeeze()
        preds = preds.cpu().numpy().squeeze()
        labels = labels.cpu().numpy().squeeze()
        if len(preds.shape) == 2:
            preds_img = (preds * 255).astype(np.uint8)

            # 2D images in MONAI need to be mirrored and flipped due to how they are loaded
            # Mirror horizontally
            preds_img = np.flipud(preds_img)

            # Rotate 90° clockwise
            preds_img = np.rot90(preds_img, k=-1)
            im = Image.fromarray(preds_img)
            im.save(f'{self.logger.log_dir}/preds/{casename}.png')
            
            preds = preds[None, ...]
            labels = labels[None, ...]
        else:
            preds_vol = preds.astype(np.uint8)
            pred_nifti = nib.Nifti1Image(preds_vol, affine=np.eye(4))

            nib.save(
                pred_nifti,
                f'{self.logger.log_dir}/preds/{casename}.nii.gz'
            )

        self.aggregator.evaluate(preds, labels, subject_name=casename)

        B, C = 1, 2
        D, H, W = preds.shape

        y_hat = torch.zeros((B, C, D, H, W), dtype=torch.float32)
        y = torch.zeros((B, C, D, H, W), dtype=torch.float32)

        y_hat[0, 1] = torch.from_numpy(preds)
        y[0, 1] = torch.from_numpy(labels)

        y_hat[0, 0] = 1 - y_hat[0, 1]
        y[0, 0] = 1 - y[0, 1]
        self.cc_dice(y_pred=y_hat, y=y)
        gt_quartiles = split_gt_by_volume(labels, self.dataset_config['quartiles'])
        for i, gt_q in enumerate(gt_quartiles):
            if np.sum(gt_q) == 0:
                continue
            self.quartile_recalls[f"q{i}"].append(self.evaluator.evaluate(
                preds, gt_q, log_times=False, verbose=False)['instance'].rec)

    def on_test_epoch_end(self):
        statistics_obj = Panoptica_Statistic.from_file(f'{self.logger.log_dir}/eval.tsv')
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
            "test/global/dice":           self.dice.aggregate().item(),
            "test/global/precision":      self.precision.compute(),
            "test/global/recall":         self.recall.compute(),
            "test/global/F2":             self.f2.compute(),
            "test/cc/dice":               self.cc_dice.cc_aggregate().mean().item(),
            "test/instance/dice":         summary['sq_dsc'].avg,
            "test/instance/tp":           summary['tp'].avg,
            "test/instance/fp":           summary['fp'].avg,
            "test/instance/fn":           summary['fn'].avg,
            "test/instance/precision":    summary['prec'].avg,
            "test/instance/recall_q0":    mean_quartile_recall['q0'],
            "test/instance/recall_q1":    mean_quartile_recall['q1'],
            "test/instance/recall_q2":    mean_quartile_recall['q2'],
            "test/instance/recall_q3":    mean_quartile_recall['q3'],
            "test/instance/recall":       summary['rec'].avg,
            "test/instance/f1":           summary['rq'].avg,
            "test/instance/assd":         summary['sq_assd'].avg,
            "test/instance/cedi":         summary['sq_cedi'].avg,
        }
        metrics_to_log = to_serializable(metrics_to_log)

        with open(f"{self.logger.log_dir}/test_results.json", "w") as fp:
            json.dump(metrics_to_log, fp, indent=2)
        self.log_dict(metrics_to_log)

        print(f"\nTest Results for {self.dataset_config}:")
        statistics_obj.print_summary(3, only_across_groups=False)
        # Reset metrics again just to be safe
        self.recall.reset()
        self.precision.reset()
        self.cc_dice.reset()
        self.dice.reset()
        self.f2.reset()

