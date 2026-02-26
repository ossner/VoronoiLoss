import torch
import numpy as np
from scipy.ndimage import distance_transform_edt, label
from monai.transforms import MapTransform
import torch


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
            
            d[f"voronoi"] = torch.from_numpy(voronoi).long()
            d[f"instances"] = torch.from_numpy(cc).long()

        return d