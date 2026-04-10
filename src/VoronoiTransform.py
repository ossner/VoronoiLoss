import torch
import numpy as np
from scipy.ndimage import distance_transform_edt, label
from monai.transforms import MapTransform
import torch


def voronoi_map_from_binary_mask(mask: np.ndarray, min_size=14):
    """
    mask: (H, W, optional D) binary ground truth
    Returns:
        voronoi_map: (H, W, optional D) int, Voronoi region id
        cc_labels:   (H, W, optional D) int, connected components
    """
    if mask.ndim == 2:
        # 8-connectivity for 2d images
        connector = np.ones((3, 3), dtype=np.int32)
    elif mask.ndim == 3:
        # 26-connectivity for 3d images
        connector = np.ones((3, 3, 3), dtype=np.int32)
    else:
        raise IndexError(
            f"Voronoi computaion of mask dimension {mask.ndim} and shape {mask.shape} is not supported")
    cc_labels, num_cc = label(mask > 0, connector)

    if num_cc == 0:
        return np.zeros_like(cc_labels), cc_labels
    
    # distance_transform_edt assigns each pixel to nearest foreground voxel
    _, indices = distance_transform_edt(
        cc_labels == 0, return_indices=True
    )

    voronoi_map = cc_labels[tuple(indices)]
    assert mask.shape == voronoi_map.shape, f"Mask shape {mask.shape} and voronoi map shape {voronoi_map.shape} not equal"
    assert mask.shape == cc_labels.shape, f"Mask shape {mask.shape} and labelmap shape {cc_labels.shape} not equal"
    return voronoi_map, cc_labels


class ComputeVoronoiMapsd(MapTransform):
    """
    Computes CC labels and Voronoi regions as a Monai transform for 2d or 3d labels.
    """

    def __call__(self, data):
        d = dict(data)

        for key in self.keys:
            mask = d[key]
            if isinstance(mask, torch.Tensor):
                mask = mask.detach().cpu().numpy()

            # Expect (1, H, W, optional D)
            mask = mask[0]
            voronoi, cc = voronoi_map_from_binary_mask(mask)

            d["voronoi"] = torch.from_numpy(voronoi).long()
            d["instances"] = torch.from_numpy(cc).long()
        return d