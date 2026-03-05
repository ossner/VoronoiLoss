from network import PlateletSegmentationModel
import pytorch_lightning as pl
from LossWrapper import WeightedDice, WeightedBCE, CCDiceCE
import torch
from pytorch_lightning.loggers import TensorBoardLogger

LOSSES = ['110', '111']

TASKS = ["canalicular vessel", "alpha granule",]

W_MAPS = ['none', 'iw', 'v_region', 'v_size', 'v_mountains', 'v_islands']


torch.serialization.add_safe_globals([WeightedDice, WeightedBCE, CCDiceCE])
for loss in LOSSES:
    for task in TASKS:
        for map in W_MAPS:
            eval_logger = TensorBoardLogger(
                save_dir='/home/student/sebastian_ma/VoronoiLoss/src/twod/eval/logs',
                name=f"{loss}/{task}/{map}",
                default_hp_metric=False
            )
            best_path = f"/home/student/sebastian_ma/VoronoiLoss/src/twod/logs/{loss}/{task}/{map}/version_0/checkpoints/best_dice.ckpt"

            model = PlateletSegmentationModel.load_from_checkpoint(
                best_path, data_dir='data/platelet-em/2d_binary_dataset_slices', task=task, weights_only=False)

            trainer = pl.Trainer(
                accelerator="gpu", devices=1, logger=eval_logger)
            trainer.test(model)
