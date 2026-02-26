from network import PlateletSegmentationModel
import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
from pytorch_lightning.callbacks import ModelCheckpoint
from LossWrapper import Dice, CE, CCDiceCE
import torch

TASK = 'canalicular vessel'
TASK = 'alpha granule'

torch.serialization.add_safe_globals([Dice, CE, CCDiceCE])

for weight_map in ['none', 'iw', 'v_size', 'v_share', 'v_mountains', 'v_islands', ]:
    best_checkpoint = ModelCheckpoint(
        dirpath=None,
        filename="best",
        monitor="val_dice",
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
        save_dir='/home/student/sebastian_ma/VoronoiLoss/src/twod/logs',
        name=f"{TASK}/{weight_map}",
        default_hp_metric=False
    )

    trainer = pl.Trainer(
        max_epochs=200,
        deterministic=True,
        accelerator="gpu",
        devices=1,
        precision="16-mixed",
        logger=run_logger,
        callbacks=[best_checkpoint, final_checkpoint],
        log_every_n_steps=25
    )
    
    model = PlateletSegmentationModel(  # , ('CCDiceCE', CCDiceCE(), 1)
        'data/platelet-em/2d_binary_dataset_slices', loss_dict=[('Dice', Dice(), 1), ('CE', CE(), 1), ('CCDiceCE', CCDiceCE(), 1)], weight_map=weight_map, batch_size=8, lr=0.001, seed=0, task=TASK)

    trainer.fit(model)
    trainer.test(
        model, ckpt_path=f'/home/student/sebastian_ma/VoronoiLoss/src/twod/logs/{TASK}/{weight_map}/version_1/checkpoints/best.ckpt')
