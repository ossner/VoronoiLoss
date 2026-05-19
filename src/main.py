import argparse
import torch
import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
from pytorch_lightning.callbacks import ModelCheckpoint
from monai.utils.enums import TraceKeys

# Local imports
from network import InstanceSegmentationModel
from LossWrapper import WeightedDice, WeightedBCE, Tversky
from util import DATASET_CONFIGS

# Register safe globals for torch 2.0+ checkpoint loading
torch.serialization.add_safe_globals(
    [WeightedDice, WeightedBCE, Tversky, TraceKeys])


def get_callbacks():
    """Returns a list of standard callbacks."""
    return [
        ModelCheckpoint(
            filename="best_dice",
            monitor="val/dice",
            mode="max",
            save_top_k=1
        ),
        ModelCheckpoint(
            filename="best_ccdice",
            monitor="val/ccdice",
            mode="max",
            save_top_k=1
        ),
        ModelCheckpoint(
            filename="final",
            save_top_k=1,
            monitor=None,
            every_n_epochs=1,
            save_on_train_epoch_end=True
        ),
    ]
    
def build_loss_dict(config_str: str):
    loss_registry = [
        ('Dice', WeightedDice()),
        ('CE', WeightedBCE()),
        ('Tversky', Tversky()),
    ]
    
    num_losses = len(loss_registry)
    
    if len(config_str) != 2 * num_losses:
        raise ValueError(
            f"Expected config string of length {2 * num_losses} "
            f"(Global + Local), got {len(config_str)}"
        )

    global_part = config_str[:num_losses]
    local_part = config_str[num_losses:]

    def process_sub_config(sub_str):
        modules = []
        total_weight = 0
        for digit, (name, loss_fn) in zip(sub_str, loss_registry):
            weight = int(digit)
            if weight > 0:
                modules.append(loss_fn)
                total_weight += weight
        return modules, float(total_weight)

    global_tuple = process_sub_config(global_part)
    local_tuple = process_sub_config(local_part)

    if global_tuple[1] == 0 and local_tuple[1] == 0:
        raise ValueError("Config string resulted in zero active losses.")

    return global_tuple, local_tuple

def run_train(args):
    """Iterates through tasks and weight maps for sequential training."""
    for dataset in args.datasets:
        for w_map in args.weight_maps:
            for losses in args.losses:
                dataset_config = DATASET_CONFIGS[dataset]
                print(f"\nStarting Training | Task: {dataset} | Map: {w_map} | Loss config: {losses}")
                print(f"Dataset config: {dataset_config}")
                logger = TensorBoardLogger(
                    save_dir=args.log_dir,
                    name=f"{losses}/{dataset}/{w_map}",
                    default_hp_metric=False
                )

                trainer = pl.Trainer(
                    max_epochs=dataset_config['epochs'],
                    deterministic=True,
                    accelerator="gpu",
                    devices=1,
                    precision="32", 
                    #detect_anomaly=True, # expensive and slows down training, only turn on in case of suspected errors
                    logger=logger,
                    callbacks=get_callbacks(),
                    log_every_n_steps=1
                )

                model = InstanceSegmentationModel(
                    data_dir=f'data/datasets',
                    dataset_config = dataset_config,
                    loss_dict=(build_loss_dict(losses)),
                    weight_map=w_map,
                    lr=args.lr,
                    seed=args.seed,
                    adaptive=(w_map == 'v_adaptive')
                )

                trainer.fit(model)


def run_eval(args):
    """Iterates through checkpoints for evaluation."""
    for loss_variant in args.losses:
        for task in args.tasks:
            for w_map in args.weight_maps:
                print(
                    f"\nEvaluating | Loss: {loss_variant} | Task: {task} | Map: {w_map}")

                ckpt_path = f"{args.log_dir}/{loss_variant}/{args.dataset}_{task}/{w_map}/version_0/checkpoints/final.ckpt"

                logger = TensorBoardLogger(
                    save_dir='src/twod/eval/logs',
                    name=f"{loss_variant}/{args.dataset}_{task}/{w_map}",
                    default_hp_metric=False
                )

                try:
                    model = InstanceSegmentationModel.load_from_checkpoint(
                        ckpt_path,
                        data_dir=f'data/datasets/{args.dataset}',
                        task=task,
                        weights_only=False
                    )

                    trainer = pl.Trainer(
                        accelerator="gpu", devices=1, logger=logger)
                    trainer.test(model)
                except FileNotFoundError:
                    print(
                        f"Checkpoint not found at {ckpt_path}. Skipping...")


def main():
    parser = argparse.ArgumentParser(
        description="Platelet Segmentation Training/Eval CLI")

    parser.add_argument('--mode', type=str,
                        choices=['train', 'eval'])

    parser.add_argument('--datasets', nargs='+')
    parser.add_argument('--weight_maps', nargs='+', default=['none'])
    parser.add_argument('--losses', nargs='+', help="Loss config relative weights")

    parser.add_argument('--lr', type=float, default=0.001)
    parser.add_argument('--seed', type=int, default=42)

    parser.add_argument('--log_dir', type=str, default='src/logs')


    args = parser.parse_args()

    if args.mode == 'train':
        run_train(args)
    else:
        run_eval(args)


if __name__ == '__main__':
    main()
