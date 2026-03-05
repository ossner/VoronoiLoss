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

torch.serialization.add_safe_globals(
    [WeightedDice, WeightedBCE, CCDiceCE, TraceKeys])

for weight_map in ['v_region', 'none', 'v_size', 'v_mountains', 'v_islands', 'iw']:
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
        save_dir='/home/student/sebastian_ma/VoronoiLoss/src/twod/train_logs',
        name=f"{TASK}/{weight_map}",
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
                   EarlyStopping(monitor="val/dice", mode="max", patience=20)],
        log_every_n_steps=25
    )
    
    model = PlateletSegmentationModel(  # ('Dice', Dice(), 1), ('CE', CE(), 1), ('CCDiceCE', CCDiceCE(), 1)
        f'data/{DATASET}/2d_binary_dataset_slices', loss_dict=[('Dice', WeightedDice(), 1), ('CE', WeightedBCE(), 1)], weight_map=weight_map, batch_size=8, lr=0.001, seed=0, task=TASK, roi_size=(288, 288))
    trainer.fit(model)