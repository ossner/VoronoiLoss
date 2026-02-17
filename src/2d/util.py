import os
from glob import glob
import numpy as np
import scipy.ndimage as ndi
from monai.transforms import MapTransform
import numpy as np


SEMANTIC_COLORS = np.array([
    [0,   0,   0,   0],        # 0: Background
    [0,  40, 255, 255],        # 1: Cell
    [0, 212, 255, 255],        # 2: Mitochondrion
    [124, 255, 121, 255],     # 3: Alpha granule
    [255, 229,   0, 255],     # 4: Canalicular vessel
    [255,  70,   0, 255],     # 5: Dense granule body
    [127,   0,  127, 255],    # 6: Dense granule core
], dtype=np.uint8)

class SemanticColorToBinaryd(MapTransform):
    def __init__(self, keys, target_class):
        super().__init__(keys)
        self.semantic_colors = SEMANTIC_COLORS
        self.target_color = SEMANTIC_COLORS[target_class]

    def __call__(self, data):
        d = dict(data)
        for key in self.keys:
            label = d[key]  # shape: (4, H, W) or (H, W, 4)

            # Ensure channel-last for comparison
            if label.shape[0] == 4:
                label = np.moveaxis(label, 0, -1)

            # Exact color match
            binary = np.all(label == self.target_color, axis=-1)

            # Convert to (1, H, W) float32 tensor
            d[key] = binary[None].astype(np.float32)

        return d

def get_data_dicts(data_dir, split, task='alpha granule'):
    """
    Docstring for get_data_dicts

    :param data_dir: Parent directory that contains the splits. In this directory, this should contain train/ val/ (test/)
    :param split: The split to generate the data_dir for. Should be one of [train, val, test]
    """
    images = sorted(glob(os.path.join(data_dir, split, "images", "*.png")))
    labels = sorted(
        glob(os.path.join(data_dir, split, "labels", task, "*.png")))

    return [{"image": img, "label": lbl} for img, lbl in zip(images, labels)]


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
