from network import PlateletSegmentationModel
import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
from pytorch_lightning.callbacks import ModelCheckpoint

VERSION = '0'
LOSS = 'DiceCE'

logger = TensorBoardLogger(
    save_dir='/home/student/sebastian_ma/VoronoiLoss/src/2d/logs',
    name=LOSS,
    version=f"version_{VERSION}"
)

model = PlateletSegmentationModel.load_from_checkpoint(
    checkpoint_path=f"/home/student/sebastian_ma/VoronoiLoss/src/2d/logs/{LOSS}/version_{VERSION}/checkpoints/best.ckpt",
    hparams_file=f"/home/student/sebastian_ma/VoronoiLoss/src/2d/logs/{LOSS}/version_{VERSION}/hparams.yaml",
    data_dir='data/platelet-em/2d_binary_dataset_norm',
    map_location=None,
)

trainer = pl.Trainer(
    accelerator="auto",
    devices=1,
    precision="16-mixed",
    logger=logger,
)

trainer.test(model)
