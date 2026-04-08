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
        'roi': (288, 288),
        'patches': 25,
        'cache': 1.0,
        'quartiles' : [460, 881, 1426.5]
    },
    'platelet_cv': {
        'roi': (288, 288),
        'patches': 25,
        'cache': 1.0,
        'quartiles' : [160, 271, 451.75]
    },
    'epfl_mit': {
        'roi': (512, 512),
        'patches': 16,
        'cache': 0.25,
        'quartiles' : [1393.25, 2265, 3737.5]
    },
    'sbm_mets': {
        'roi': (96, 96, 64),
        'patches': 20,
        'cache': 0.1,
        'quartiles' : [0,0,0]
    },
    'wmh_wmh': {
        'roi': (64, 64, 48),
        'patches': 16,
        'cache': 0.1,
        'quartiles' : [0,0,0]
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
    print(f"Saved {filename} with shape {data.shape}")


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

def configure_datasets(data_dir, task, train_files, val_files, test_files, base_transforms, train_transforms, spatial_keys=["image", "label", "voronoi", "weight_map", "instances"]):
    config = next((cfg for path, cfg in DATASET_CONFIGS.items() if f"{data_dir}_{task}".endswith(path)), None)
    print(f'Using config: {config}')
    assert config is not None
    train_ds = create_random_patch_dataset(
                train_files, spatial_keys, base_transforms, train_transforms, config['roi'], config['patches'], cache_rate=config['cache'])
    val_ds = CacheDataset(
        data=val_files,
        transform=Compose([*base_transforms,]),
        cache_rate=config['cache']
    )
    test_ds = Dataset(
        data=test_files,
        transform=base_transforms,
    )
    return train_ds, val_ds, test_ds, config['quartiles']


def get_data_dicts(data_dir, split, twod, task, samples=-1):
    """
    Consolidated loader for 2D or 3D medical imaging datasets.
    
    :param data_dir: Root directory containing split folders (train/val/test).
    :param split: The dataset split to load.
    :param twod: Boolean, True for 2D PNG data, False for 3D NIfTI data.
    :param task: Subfolder name for labels (used in 2D mode).
    :param samples: Number of samples to return. -1 returns all.
    """
    path_root = os.path.join(data_dir, split)
    limit = samples if samples > 0 else None

    if twod:
        images = sorted(glob(os.path.join(path_root, "images", "*.png")))[:limit]
        labels = sorted(glob(os.path.join(path_root, "labels", task, "*.png")))[:limit]
        
        return [{"image": img, "label": lbl} for img, lbl in zip(images, labels)]

    else:
        subj_dirs = sorted(glob(os.path.join(path_root, "images", "*")))[:limit]
        lbl_files = sorted(glob(os.path.join(path_root, "labels", "*.nii.gz")))[:limit]

        data_dicts = []
        for subj_dir, lbl in zip(subj_dirs, lbl_files):
            channels = sorted(glob(os.path.join(subj_dir, "*.nii.gz")))
            
            if channels and os.path.exists(lbl):
                data_dicts.append({
                    "image": channels, 
                    "label": lbl
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
