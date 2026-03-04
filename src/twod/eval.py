from network import PlateletSegmentationModel
import pytorch_lightning as pl
from LossWrapper import WeightedDice, WeightedBCE
import torch

TASKS = ["alpha granule", "canalicular vessel", ]

W_MAPS = ['none', 'iw', 'v_region', 'v_size', 'v_mountains', 'v_islands']


torch.serialization.add_safe_globals([WeightedDice, WeightedBCE])
for task in TASKS:
    for map in W_MAPS:
        best_path = f"/home/student/sebastian_ma/VoronoiLoss/src/twod/logs/{task}/{map}/version_0/checkpoints/best_f1.ckpt"

        model = PlateletSegmentationModel.load_from_checkpoint(
            best_path, data_dir='data/platelet-em/2d_binary_dataset_slices', task=task, weights_only=False)

        trainer = pl.Trainer(accelerator="gpu", devices=1)
        trainer.test(model)
