import pytorch_lightning
from monai.inferers import sliding_window_inference
from monai.config import print_config
import torch
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import os
from network import Net

print_config()

ROOT_DIR = '../../data/platelet-em'
TASK = 'Task3_alphagranule'

task_data_dir = f'{ROOT_DIR}/{TASK}'

assert os.path.exists(f'{task_data_dir}')
assert os.path.exists(f'{task_data_dir}/imagesTr')
assert os.path.exists(f'{task_data_dir}/labelsTr')
assert len(os.listdir(f'{task_data_dir}/imagesTr')) > 0
assert len(os.listdir(f'{task_data_dir}/labelsTr')) > 0
assert len(os.listdir(f'{task_data_dir}/labelsTr')) == len(os.listdir(f'{task_data_dir}/imagesTr'))
assert os.listdir(f'{task_data_dir}/labelsTr') == os.listdir(f'{task_data_dir}/imagesTr')

net = Net(task_data_dir = task_data_dir, loss_type="Dice", test_size=0.2)
# set up loggers and checkpoints
log_dir = f'./logs_{TASK}'
os.makedirs(log_dir, exist_ok=True)
tb_logger = pytorch_lightning.loggers.TensorBoardLogger(save_dir=log_dir)

# initialise Lightning's trainer.
trainer = pytorch_lightning.Trainer(
    devices=[0],
    max_epochs=250,
    logger=tb_logger,
    enable_checkpointing=True,
    num_sanity_val_steps=1,
    log_every_n_steps=8,
)

# train
trainer.fit(net)