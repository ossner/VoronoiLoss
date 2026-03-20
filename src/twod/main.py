import argparse
import torch
import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
from pytorch_lightning.callbacks import ModelCheckpoint, EarlyStopping
from monai.utils.enums import TraceKeys

# Local imports
from network import PlateletSegmentationModel
from LossWrapper import WeightedDice, WeightedBCE, CCDiceCE

# Register safe globals for torch 2.0+ checkpoint loading
torch.serialization.add_safe_globals(
    [WeightedDice, WeightedBCE, CCDiceCE, TraceKeys])


def get_callbacks(monitor_metric="val/dice", mode="max", patience=25):
    """Returns a list of standard callbacks."""
    return [
        ModelCheckpoint(
            filename="best_dice",
            monitor="val/dice",
            mode="max",
            save_top_k=1
        ),
        ModelCheckpoint(
            filename="best_f1",
            monitor="val/instance_f1",
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
        #EarlyStopping(
        #    monitor=monitor_metric,
        #    mode=mode,
        #    patience=patience
        #)
    ]


def run_train(args):
    """Iterates through tasks and weight maps for sequential training."""
    for task in args.tasks:
        for w_map in args.weight_maps:
            print(f"\nStarting Training | Task: {args.dataset}_{task} | Map: {w_map}")

            logger = TensorBoardLogger(
                save_dir=args.log_dir,
                name=f"{args.dataset}_{task}/{w_map}",
                default_hp_metric=False
            )

            trainer = pl.Trainer(
                max_epochs=args.epochs,
                deterministic=True,
                accelerator="gpu",
                devices=1,
                precision="16-mixed",
                logger=logger,
                callbacks=get_callbacks(),
                log_every_n_steps=25
            )

            model = PlateletSegmentationModel(
                data_dir=f'data/organelles/{args.dataset}',
                loss_dict=[('Dice', WeightedDice(), 1),
                           ('CE', WeightedBCE(), 1),
                           #('CCDiceCE', CCDiceCE(), 1),
                           #('BlobDiceCE', BlobDiceCE(), 1)
                           ],
                weight_map=w_map,
                batch_size=args.batch_size,
                lr=args.lr,
                seed=args.seed,
                task=task,
            )

            trainer.fit(model)


def run_eval(args):
    """Iterates through checkpoints for evaluation."""
    for loss_variant in args.eval_losses:
        for task in args.tasks:
            for w_map in args.weight_maps:
                print(
                    f"\nEvaluating | Loss: {loss_variant} | Task: {task} | Map: {w_map}")

                ckpt_path = f"{args.log_dir}/{loss_variant}/{task}/{w_map}/version_0/checkpoints/best_dice.ckpt"

                logger = TensorBoardLogger(
                    save_dir='src/twod/eval/logs',
                    name=f"{loss_variant}/{args.dataset}_{task}/{w_map}",
                    default_hp_metric=False
                )


                try:
                    model = PlateletSegmentationModel.load_from_checkpoint(
                        ckpt_path,
                        data_dir=f'data/organelles/{args.dataset}/',
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

    parser.add_argument('--dataset', type=str, default='platelet')
    parser.add_argument('--tasks', nargs='+', default=['cv', 'ag'])
    parser.add_argument('--weight_maps', nargs='+',
                        default=['none', 'iw', 'v_region', 'v_size', 'v_mountains', 'v_islands'])

    parser.add_argument('--batch_size', type=int, default=8)
    parser.add_argument('--lr', type=float, default=0.001)
    parser.add_argument('--epochs', type=int, default=-1)
    parser.add_argument('--seed', type=int, default=0)

    parser.add_argument('--log_dir', type=str, default='src/twod/logs')

    parser.add_argument('--losses', nargs='+',
                        default=['110', '111'], help="Loss folders to look for during eval")

    args = parser.parse_args()

    if args.mode == 'train':
        run_train(args)
    else:
        run_eval(args)


if __name__ == '__main__':
    main()
