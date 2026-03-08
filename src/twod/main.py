from network import PlateletSegmentationModel
import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
from pytorch_lightning.callbacks import ModelCheckpoint
from LossWrapper import WeightedDice, WeightedBCE, CCDiceCE
from lightning.pytorch.callbacks.early_stopping import EarlyStopping
import torch
from monai.utils.enums import TraceKeys

# DATASET = 'cem_mitolab_split'
DATASET = 'platelet-em'

# TASK = 'alpha granule'
# TASK = 'mitochondria'
TASK = 'canalicular vessel'
W_MAPS = ['none', 'iw', 'v_region', 'v_size', 'v_mountains', 'v_islands']

torch.serialization.add_safe_globals(
    [WeightedDice, WeightedBCE, CCDiceCE, TraceKeys])

def train():
    for map in W_MAPS:
        best_dice_checkpoint = ModelCheckpoint(
            dirpath=None,
            filename="best_dice",
            monitor="val/dice",
            mode="max",
            save_top_k=1
        )

        best_f1_checkpoint = ModelCheckpoint(
            dirpath=None,
            filename="best_f1",
            monitor="val/f1",
            mode="max",
            save_top_k=1
        )

        final_checkpoint = ModelCheckpoint(
            dirpath=None,
            filename="final",
            save_top_k=1,
            monitor=None,
            every_n_epochs=1,
            save_on_train_epoch_end=True
        )

        run_logger = TensorBoardLogger(
            save_dir='src/twod/train_logs',
            name=f"{TASK}/{map}",
            default_hp_metric=False
        )

        trainer = pl.Trainer(
            max_epochs=-1,
            deterministic=True,
            accelerator="gpu",
            devices=1,
            precision="16-mixed",
            logger=run_logger,
            callbacks=[best_dice_checkpoint, best_f1_checkpoint, final_checkpoint,
                    EarlyStopping(monitor="val/dice", mode="max", patience=25)],
            log_every_n_steps=25
        )

        model = PlateletSegmentationModel(  # ('Dice', Dice(), 1), ('CE', CE(), 1), ('CCDiceCE', CCDiceCE(), 1)
            f'data/{DATASET}/2d_binary_dataset_slices', loss_dict=[('Dice', WeightedDice(), 1), ('CE', WeightedBCE(), 1)], weight_map=map, batch_size=8, lr=0.001, seed=0, task=TASK, roi_size=(288, 288))
        trainer.fit(model)

def eval():
    LOSSES = ['110', '111']
    TASKS = ["canalicular vessel", "alpha granule",]
    for loss in LOSSES:
        for task in TASKS:
            for map in W_MAPS:
                eval_logger = TensorBoardLogger(
                    save_dir='src/twod/eval/logs',
                    name=f"{loss}/{task}/{map}",
                    default_hp_metric=False
                )
                best_path = f"src/twod/train_logs_1/{loss}/{task}/{map}/version_0/checkpoints/best_dice.ckpt"

                model = PlateletSegmentationModel.load_from_checkpoint(
                    best_path, data_dir=f'data/{DATASET}/2d_binary_dataset_slices', task=task, weights_only=False)

                trainer = pl.Trainer(
                    accelerator="gpu", devices=1, logger=eval_logger)
                trainer.test(model)


if __name__ == '__main__':
    # train()
    eval()
    
    