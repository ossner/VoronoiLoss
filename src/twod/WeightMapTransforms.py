import torch
import numpy as np
from monai.transforms import MapTransform
from scipy.ndimage import label
from scipy.ndimage import distance_transform_edt

class ComputeInverseWeightMapd(MapTransform):
    """
    MONAI transform to compute Inverse Weight (iw) maps.
    Weights are inversely proportional to lesion area to balance size inequality.
    """

    def __init__(self, keys, allow_missing_keys=False):
        super().__init__(keys, allow_missing_keys)

    def __call__(self, data):
        d = dict(data)
        for key in self.keys:
            mask = d[key]

            if isinstance(mask, torch.Tensor):
                mask_np = mask.detach().cpu().numpy()
            else:
                mask_np = mask

            original_shape = mask_np.shape
            if len(original_shape) == 3:
                work_mask = mask_np[0]
            else:
                work_mask = mask_np

            # TODO: This can be used from the voronoi transform which should be done already
            labeled_mask, num_lesions = label(work_mask > 0.5)
            total_pixels = work_mask.size
            K = num_lesions

            weight_map = np.zeros_like(work_mask, dtype=np.float32)

            for j in range(K + 1):
                component_mask = (labeled_mask == j)
                component_size = np.sum(component_mask)

                if component_size > 0:
                    weight = total_pixels / ((K + 1) * component_size)
                    weight_map[component_mask] = weight

            weight_map = weight_map[np.newaxis, ...]

            if isinstance(mask, torch.Tensor):
                d[f"weight_map"] = torch.from_numpy(weight_map).to(mask.device)
            else:
                d[f"weight_map"] = weight_map

        return d


class ComputeVoronoiWeightMapd(MapTransform):
    """
    Computes a weight map where each Voronoi region is weighted inversely 
    to the proportion of the instance area within that region.
    Expects '{key}_voronoi' and '{key}_instances' to be in the data dictionary.
    """

    def __call__(self, data):
        d = dict(data)

        for key in self.keys:
            instances = d.get(f"instances")
            voronoi = d.get(f"voronoi")

            if instances is None or voronoi is None:
                raise KeyError(f"Voronoi or Instance maps not found for key: {key}. "
                               "Ensure ComputeVoronoiMapsd is run first.")

            inst_np = instances.detach().cpu().numpy(
            ) if torch.is_tensor(instances) else instances
            vor_np = voronoi.detach().cpu().numpy() if torch.is_tensor(voronoi) else voronoi

            if inst_np.ndim == 3:
                inst_np = inst_np[0]
            if vor_np.ndim == 3:
                vor_np = vor_np[0]

            weight_map = np.ones_like(inst_np, dtype=np.float32)

            unique_ids = np.unique(inst_np)
            unique_ids = unique_ids[unique_ids != 0]

            for idx in unique_ids:
                inst_mask = (inst_np == idx)
                vor_mask = (vor_np == idx)
                region_bg_mask = vor_mask & ~inst_mask
                
                area_inst = np.sum(inst_mask)
                area_vor = np.sum(vor_mask)
                area_region_bg = np.sum(region_bg_mask)

                if area_inst > 0:
                    weight_map[inst_mask] = area_vor / (2 * area_inst)
                    weight_map[region_bg_mask] = area_vor / (2 * area_region_bg)

            weight_map_tensor = torch.from_numpy(weight_map[None, ...])

            if torch.is_tensor(instances):
                weight_map_tensor = weight_map_tensor.to(instances.device)

            d[f"voronoi_weight"] = weight_map_tensor
        return d


class ComputeVoronoiPullWeightd(MapTransform):
    def __init__(self, keys, sigma=5.0):
        super().__init__(keys)
        self.sigma = sigma

    def __call__(self, data):
        d = dict(data)
        for key in self.keys:
            inst_np = d[f"instances"].detach().cpu().numpy().squeeze()
            vor_np = d[f"voronoi"].detach().cpu().numpy().squeeze()

            weight_map = np.ones_like(inst_np, dtype=np.float32)
            unique_ids = np.unique(inst_np)
            unique_ids = unique_ids[unique_ids != 0]

            dist_to_lesion = distance_transform_edt(inst_np == 0)

            for idx in unique_ids:
                inst_mask = (inst_np == idx)
                vor_mask = (vor_np == idx)
                region_only_mask = vor_mask & ~inst_mask

                area_vor = np.sum(vor_mask)
                budget = area_vor / 2.0  # We want half the weight sum to come from background

                area_inst = np.sum(inst_mask)
                if area_inst > 0:
                    weight_map[inst_mask] = budget / area_inst

                if np.sum(region_only_mask) > 0:
                    dists = dist_to_lesion[region_only_mask]

                    pull_values = np.exp(-dists / self.sigma)

                    pull_sum = np.sum(pull_values)
                    if pull_sum > 0:
                        pull_values = pull_values * (budget / pull_sum)

                    weight_map[region_only_mask] = pull_values

            d[f"voronoi_pull_weight"] = torch.from_numpy(
                weight_map[None, ...]).to(d[key].device)
        return d


class ComputeUnifiedVoronoiPulld(MapTransform):
    def __init__(self, keys, sigma_scale=0.5):
        """
        sigma_scale: Scales the 'pull' relative to the lesion size.
        """
        super().__init__(keys)
        self.sigma_scale = sigma_scale

    def __call__(self, data):
        d = dict(data)
        for key in self.keys:
            inst_np = d[f"instances"].detach().cpu().numpy().squeeze()
            vor_np = d[f"voronoi"].detach().cpu().numpy().squeeze()

            weight_map = np.ones_like(inst_np, dtype=np.float32)
            dist_to_lesion = distance_transform_edt(inst_np == 0)

            unique_ids = np.unique(inst_np)
            unique_ids = unique_ids[unique_ids != 0]

            for idx in unique_ids:
                inst_mask = (inst_np == idx)
                vor_mask = (vor_np == idx)
                bg_mask = vor_mask & ~inst_mask

                area_l = np.sum(inst_mask)
                area_total = np.sum(vor_mask)

                # Adaptive Sigma: Pull scales with lesion size
                # Prevents 'needles' for small lesions and 'cliffs' for large ones
                sigma = self.sigma_scale * np.sqrt(area_l / np.pi)
                # Lower bound to prevent division by zero
                sigma = max(sigma, 1.0)

                # Calculate the background exponential sum (the integral)
                if np.any(bg_mask):
                    dists = dist_to_lesion[bg_mask]
                    bg_decay = np.exp(-dists / sigma)
                    bg_integral = np.sum(bg_decay)
                else:
                    bg_decay = 0
                    bg_integral = 0

                # Solve for WL: WL = Area_Total / (Area_L + BG_Integral)
                w_l = area_total / (area_l + bg_integral)

                # Assign weights
                weight_map[inst_mask] = w_l
                if np.any(bg_mask):
                    weight_map[bg_mask] = w_l * bg_decay

            d[f"unified_weight"] = torch.from_numpy(
                weight_map[None, ...]).to(d[key].device)
        return d
