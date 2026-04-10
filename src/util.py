import torch
import os
from glob import glob
import numpy as np
import scipy.ndimage as ndi
import nibabel as nib
from matplotlib.colors import ListedColormap
from scipy.ndimage import label
from monai.data import CacheDataset, PatchDataset, Dataset
from PIL import Image
from monai.transforms import (
    Compose,
    RandCropByPosNegLabeld,
)

DATASET_CONFIGS = {
    'platelet_ag': {
        'superset': 'platelet',
        'task': 'ag',
        'dimensions': 2,
        'channels' : 1,
        'batch_size': 16,
        'epochs': 300,
        'roi': (288, 288),
        'patches': 25,
        'cache': 1.0,
        'label': 255,
        'quartiles' : [460, 881, 1426.5],
    },
    'platelet_cv': {
        'superset': 'platelet',
        'task': 'cv',
        'dimensions': 2,
        'channels' : 1,
        'batch_size': 16,
        'epochs': 300,
        'roi': (288, 288),
        'patches': 25,
        'cache': 1.0,
        'label': 255,
        'quartiles' : [160, 271, 451.75],
    },
    'epfl_mit': {
        'superset': 'epfl',
        'task': 'mit',
        'dimensions': 2,
        'channels' : 1,
        'batch_size': 16,
        'epochs': 300,
        'roi': (512, 512),
        'patches': 16,
        'cache': 0.25,
        'label': 255,
        'quartiles' : [1393.25, 2265, 3737.5],
    },
    'sbm_mets': {
        'superset': 'sbm',
        'task': 'mets',
        'dimensions': 3,
        'channels' : 2,
        'batch_size': 4,
        'epochs': 500,
        'roi': (96, 96, 64),
        'patches': 20,
        'cache': 0.25,
        'label': 1,
        'quartiles' : [0,0,0],
    },
    'wmh_wmh': {
        'superset': 'wmh',
        'task': 'wmh',
        'dimensions': 3,
        'channels' : 2,
        'batch_size': 4,
        'epochs': 500,
        'roi': (64, 64, 48),
        'patches': 16,
        'cache': 0.25,
        'label': 1,
        'quartiles' : [0,0,0],
    }
}

def save_as_nifti(tensor, filename, is_multichannel=False):
    data = tensor.detach().cpu().numpy()
    data = np.squeeze(data, axis=0)
    
    if is_multichannel:
        data = np.transpose(data, (1, 2, 3, 0))
    else:
        data = np.squeeze(data, axis=0)

    img = nib.Nifti1Image(data, affine=np.eye(4), dtype=data.dtype)
    
    nib.save(img, filename)


def save_2d_as_png(tensor, base_name):
    data = tensor.detach().cpu().numpy().squeeze(0)
    def to_8bit(arr):
        arr_min, arr_max = arr.min(), arr.max()
        if arr_max - arr_min > 0:
            return ((arr - arr_min) / (arr_max - arr_min) * 255).astype(np.uint8)
        return np.zeros_like(arr, dtype=np.uint8)

    if data.ndim == 3:
        data = data.squeeze(0)
    Image.fromarray(to_8bit(data)).save(f"{base_name}.png")

def configure_datasets(data_dir, dataset_config, train_files, val_files, test_files, base_transforms, train_transforms, spatial_keys=["image", "label", "voronoi", "weight_map", "instances"]):
    assert dataset_config is not None
    train_ds = create_random_patch_dataset(
                train_files, spatial_keys, base_transforms, train_transforms, dataset_config['roi'], dataset_config['patches'], cache_rate=dataset_config['cache'])
    val_ds = CacheDataset(
        data=val_files,
        transform=Compose([*base_transforms,]),
        cache_rate=dataset_config['cache']
    )
    test_ds = Dataset(
        data=test_files,
        transform=base_transforms,
    )
    return train_ds, val_ds, test_ds


def get_data_dicts(data_dir, split, dataset_config, samples=-1):
    """
    General loader supporting:
    - 2D (png) and 3D (nii.gz)
    - multi-channel per case
    - multiple tasks (but loads one task at a time)

    Returns MONAI-style dict:
    [{"image": [ch1, ch2, ...], "label": label_path}, ...]
    """

    superset = dataset_config["superset"]
    task = dataset_config["task"]

    images_root = os.path.join(data_dir, superset, split, "images")
    labels_root = os.path.join(data_dir, superset, split, "labels", task)

    case_dirs = sorted([
        d for d in glob(os.path.join(images_root, "*"))
        if os.path.isdir(d)
    ])

    if samples > 0:
        case_dirs = case_dirs[:samples]

    data_dicts = []

    for case_dir in case_dirs:
        case_id = os.path.basename(case_dir)

        channels = sorted(
            glob(os.path.join(case_dir, "*.png")) +
            glob(os.path.join(case_dir, "*.nii")) +
            glob(os.path.join(case_dir, "*.nii.gz"))
        )

        if len(channels) == 0:
            continue

        label_candidates = (
            glob(os.path.join(labels_root, case_id + ".*"))  # flexible extension
        )

        if len(label_candidates) == 0:
            continue

        label_path = label_candidates[0]

        data_dicts.append({
            "image": channels,
            "label": label_path
        })
    return data_dicts

def instance_f1_score(pred, gt, iou_thresh=0.5):
    """
    pred, gt: torch.Tensor or np.ndarray, shape (H, W), binary
    """
    pred = pred.cpu().numpy().astype(np.uint8)
    gt = gt.cpu().numpy().astype(np.uint8)

    pred_labeled, n_pred = ndi.label(pred)
    gt_labeled, n_gt = ndi.label(gt)

    if n_pred == 0 and n_gt == 0:
        return 1.0
    if n_pred == 0 or n_gt == 0:
        return 0.0

    iou_matrix = np.zeros((n_pred, n_gt), dtype=np.float32)

    for i in range(1, n_pred + 1):
        pred_mask = pred_labeled == i
        for j in range(1, n_gt + 1):
            gt_mask = gt_labeled == j
            intersection = np.logical_and(pred_mask, gt_mask).sum()
            union = np.logical_or(pred_mask, gt_mask).sum()
            if union > 0:
                iou_matrix[i - 1, j - 1] = intersection / union

    matched_gt = set()
    tp = 0

    for i in range(n_pred):
        j = np.argmax(iou_matrix[i])
        if iou_matrix[i, j] >= iou_thresh and j not in matched_gt:
            tp += 1
            matched_gt.add(j)

    fp = n_pred - tp
    fn = n_gt - tp

    if tp == 0:
        return 0.0

    return 2 * tp / (2 * tp + fp + fn)

def _get_random_cmap(max_val):
    """Generates a random colormap for instance visualization."""
    colors = np.random.rand(int(max_val) + 1, 3)
    colors[0] = [0, 0, 0]  # Background is black
    return ListedColormap(colors)


def split_gt_by_volume(gt, quartiles):
    """
    Returns 4 GT masks containing only instances in each quartile.
    """
    gt_q = [np.zeros_like(gt) for _ in range(4)]
    gt, _ = label(gt > 0, np.ones((3,) * gt.ndim, dtype=int))
    instance_ids = np.unique(gt)
    instance_ids = instance_ids[instance_ids != 0]

    for inst_id in instance_ids:
        inst_mask = gt == inst_id
        volume = inst_mask.sum()

        if volume <= quartiles[0]:
            q = 0
        elif volume <= quartiles[1]:
            q = 1
        elif volume <= quartiles[2]:
            q = 2
        else:
            q = 3

        gt_q[q][inst_mask] = 1

    return gt_q

def create_random_patch_dataset(data_files, cropKeys, base_transforms, train_transforms, roi_size, num_patches_per_image, cache_rate):
    base_ds = CacheDataset(
        data=data_files,
        transform=Compose(base_transforms),
        cache_rate=cache_rate,
    )

    patcher = RandCropByPosNegLabeld(
        keys=cropKeys,
        label_key="label",
        image_key="image",
        spatial_size=roi_size,
        pos=2,
        neg=1,
        num_samples=num_patches_per_image,
        image_threshold=0,
    )

    return PatchDataset(
        data=base_ds,
        patch_func=patcher,
        samples_per_image=num_patches_per_image,
        transform=Compose(train_transforms)
    )


def to_serializable(x):
    if isinstance(x, torch.Tensor):
        return x.detach().cpu().item()
    elif hasattr(x, "item"):  # catches MetaTensor + numpy scalars
        try:
            return x.item()
        except Exception:
            pass
    elif isinstance(x, dict):
        return {k: to_serializable(v) for k, v in x.items()}
    elif isinstance(x, (list, tuple)):
        return [to_serializable(v) for v in x]
    return x
