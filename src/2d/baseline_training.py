from network import PlateletSegmentationModel
import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
from pytorch_lightning.callbacks import ModelCheckpoint

logger = TensorBoardLogger(
    save_dir='/home/student/sebastian_ma/VoronoiLoss/src/2d/logs',
    name='DiceCE',
    default_hp_metric=False
)

checkpoint_cb = ModelCheckpoint(
    dirpath=None,
    filename="best",
    monitor="val_dice",
    mode="max",
    save_top_k=1,
    save_last=True
)

model = PlateletSegmentationModel(
    '/home/student/sebastian_ma/VoronoiLoss/data/platelet-em/2d_binary_dataset_mixed', loss='DiceCE', batch_size=8, lr=0.001, seed=0)

trainer = pl.Trainer(
    max_epochs=200,
    deterministic=True,
    accelerator="gpu",
    devices=1,
    precision="16-mixed",
    logger=logger,
    callbacks=[checkpoint_cb],
    log_every_n_steps=25
)

trainer.fit(model)
