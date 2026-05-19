import torch
import numpy as np
from monai.transforms import MapTransform
from scipy.ndimage import label
from scipy.ndimage import distance_transform_edt


class ComputeWeightMapsd(MapTransform):
    def __init__(self, keys, concept, allow_missing_keys=False, mountain_sigma_sc=1, island_sigma_sc=5):
        super().__init__(keys, allow_missing_keys)
        self.mountain_sigma = mountain_sigma_sc
        self.island_sigma = island_sigma_sc
        allowed_maps = ['none', 'iw', 'v_region', 'v_iw',
                        'v_mountains', 'v_islands', 'v_adaptive']
        assert concept in allowed_maps, f'Provided weight map {concept} not valid. Choose one of {allowed_maps}'
        self.concept = concept

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
            
            # Remove first dimension
            inst_np = inst_np[0]
            vor_np = vor_np[0] 
            assert vor_np.ndim == 2 or vor_np.ndim == 3, f"Weight map computaion of mask dimension {vor_np.ndim} and shape {vor_np.shape} is not supported"

            # Instantiate map as unit tensor
            map = np.ones_like(inst_np, dtype=np.float32)
            map2 = np.ones_like(inst_np, dtype=np.float32)

            # The overall budget that can be distributed (B)
            total_budget = inst_np.size

            region_ids = np.unique(vor_np)
            region_ids = region_ids[region_ids != 0]

            distance_map = distance_transform_edt(inst_np == 0)

            for idx in region_ids:
                inst_mask = (inst_np == idx)
                vor_mask = (vor_np == idx)
                bg_mask = vor_mask & ~inst_mask

                area_inst = np.sum(inst_mask)
                area_vor = np.sum(vor_mask)
                area_bg = np.sum(bg_mask)

                region_budget = total_budget/len(region_ids)
                if self.concept == 'iw':
                    map[inst_mask] = total_budget / \
                        ((len(region_ids)+1)*area_inst)
                    map[bg_mask] = total_budget / \
                        ((len(region_ids)+1)*np.sum(inst_np == 0))
                elif self.concept == 'v_region':
                    map[vor_mask] = region_budget / area_vor
                elif self.concept == 'v_iw':
                    alpha = 0.5
                    map[inst_mask] = alpha * \
                        region_budget / area_inst
                    map[bg_mask] = (
                        1-alpha) * region_budget / area_bg
                elif self.concept == 'v_adaptive':
                    alpha = 0.5
                    map[vor_mask] = region_budget / area_vor
                    map2[inst_mask] = alpha * \
                        region_budget / area_inst
                    map2[bg_mask] = (
                        1-alpha) * region_budget / area_bg
                elif self.concept == 'v_mountains':
                    sigma = self.mountain_sigma * np.sqrt(area_inst / np.pi)
                    # Lower bound to prevent division by zero
                    sigma = max(sigma, 1.0)
                    dists = distance_map[bg_mask]
                    bg_decay = np.exp(-dists / sigma)
                    bg_integral = np.sum(bg_decay)

                    w_l = region_budget / (area_inst + bg_integral)
                    map[inst_mask] = w_l
                    map[bg_mask] = w_l * bg_decay
                elif self.concept == 'v_islands':
                    sigma = self.island_sigma * np.sqrt(area_inst / np.pi)
                    # Lower bound to prevent division by zero
                    sigma = max(sigma, 1.0)
                    dists = distance_map[bg_mask]
                    island_growth = 1.0 - np.exp(-dists / sigma)
                    i_integral = np.sum(island_growth)

                    w_l = region_budget / (area_inst + i_integral)

                    map[inst_mask] = w_l
                    map[bg_mask] = w_l * island_growth

            map_sum = np.sum(map)
            unit_sum = np.sum(np.ones_like(map))
            total_delta = np.abs(map_sum - unit_sum)
            assert total_delta < (
                1e-5 * unit_sum), f"Sum over weight map {self.concept} not within range of unit tensor, difference: {total_delta}"
            map = torch.from_numpy(map[None, ...])
            map2 = torch.from_numpy(map2[None, ...])
            if torch.is_tensor(instances):
                map = map.to(instances.device)
                map2 = map2.to(instances.device)
            d['weight_map'] = map
            d['v_iw'] = map2
        return d
