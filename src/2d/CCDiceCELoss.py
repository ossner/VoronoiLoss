import torch
import torch.nn as nn
from monai.losses import DiceCELoss, DiceLoss
import numpy as np
from scipy.ndimage import distance_transform_edt, label
from monai.transforms import MapTransform
from scipy.ndimage import distance_transform_edt, label
import torch
import cv2
from typing import Mapping, Sequence, Tuple


def voronoi_map_from_binary_mask(mask_2d: np.ndarray):
    """
    mask_2d: (H, W) binary ground truth
    Returns:
        voronoi_map: (H, W) int, Voronoi region id
        cc_labels:   (H, W) int, connected components
    """
    cc_labels, num_cc = label(mask_2d > 0, np.ones((3, 3), dtype=np.int32))

    if num_cc == 0:
        return np.zeros_like(cc_labels), cc_labels

    # Compute Voronoi assignment for *all* pixels
    # distance_transform_edt assigns each pixel to nearest foreground voxel
    _, indices = distance_transform_edt(
        cc_labels == 0, return_indices=True
    )

    voronoi_map = cc_labels[indices[0], indices[1]]
    return voronoi_map, cc_labels


class ComputeVoronoiMapsd(MapTransform):
    """
    Computes 2D CC labels and Voronoi regions for CC-DiceCE.
    """

    def __call__(self, data):
        d = dict(data)

        for key in self.keys:
            mask = d[key]
            if isinstance(mask, torch.Tensor):
                mask = mask.detach().cpu().numpy()

            # Expect (1, H, W) or (H, W)
            if mask.ndim == 3:
                mask = mask[0]

            voronoi, cc = voronoi_map_from_binary_mask(mask)

            d[f"{key}_voronoi"] = torch.from_numpy(voronoi).long()
            d[f"{key}_instances"] = torch.from_numpy(cc).long()

        return d

class CCDiceCELoss(nn.Module):
    """
    2D CC-DiceCE loss faithful to:
        Q_m(P, K) = (1/|K|) ∑_C m(P ∩ R_C, C)
    """

    def __init__(self, alpha=1.0, beta=1.0, region_weighting=False):
        super().__init__()
        self.dice_loss = DiceLoss(sigmoid=True, reduction='none')
        self.ce_loss = nn.BCEWithLogitsLoss(reduction='none')
        self.alpha = alpha
        self.beta = beta
        self.region_weighting = region_weighting

    def forward(self, pred, target, voronoi, cc_labels):
        """
        pred:      (B, 1, H, W) logits
        target:    (B, 1, H, W) binary GT
        voronoi:   (B, H, W) Voronoi region IDs
        cc_labels: (B, H, W) connected components
        """
        # Global DiceCE (Dice + CE)
        g_dice = self.dice_loss(pred, target).mean()
        g_ce = self.ce_loss(pred, target).mean()
        global_loss = g_dice + g_ce
        
        if self.beta == 0:
            return self.alpha * global_loss

        batch_cc_losses = []

        for b in range(pred.shape[0]):
            component_ids = torch.unique(cc_labels[b])
            component_ids = component_ids[component_ids > 0]

            if len(component_ids) == 0:
                continue
            
            pixel_ce = self.ce_loss(pred[b:b+1], target[b:b+1])

            per_cc_loss = 0.0

            for cid in component_ids:
                region_mask = (voronoi[b] == cid)
                gt_instance = (cc_labels[b] == cid)

                # --- MASKED CE ---
                instance_ce = pixel_ce[0, 0][region_mask].mean()
                
                # --- MASKED DICE ---
                p = torch.sigmoid(pred[b, 0][region_mask])
                g = gt_instance[region_mask].float()

                intersection = (p * g).sum()
                union = p.sum() + g.sum()
                instance_dice = 1 - (2. * intersection + 1e-5) / (union + 1e-5)

                combined_instance_loss = instance_ce + instance_dice

                if self.region_weighting:
                    region_factor = (
                        1 - (gt_instance.sum() / region_mask.sum())) ** 2
                    per_cc_loss += region_factor * combined_instance_loss
                else:
                    per_cc_loss += combined_instance_loss

            batch_cc_losses.append(per_cc_loss / len(component_ids))

        if len(batch_cc_losses) == 0:
            return self.alpha * global_loss

        cc_loss = torch.stack(batch_cc_losses).mean()
        return self.alpha * global_loss + self.beta * cc_loss
