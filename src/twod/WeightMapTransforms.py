import torch
import numpy as np
from monai.transforms import MapTransform
from scipy.ndimage import label
from scipy.ndimage import distance_transform_edt


class ComputeWeightMapsd(MapTransform):
    def __init__(self, keys, allow_missing_keys=False, mountain_sigma_sc=1, island_sigma_sc=5):
        super().__init__(keys, allow_missing_keys)
        self.mountain_sigma = mountain_sigma_sc
        self.island_sigma = island_sigma_sc

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

            # Instantiate maps as unit tensors
            maps = {}
            for concept in ['none', 'iw', 'v_size', 'v_share', 'v_mountains', 'v_islands']:
                maps[concept] = np.ones_like(inst_np, dtype=np.float32)

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

                maps['iw'][inst_mask] = total_budget / \
                    ((len(region_ids)+1)*area_inst)
                maps['iw'][bg_mask] = total_budget / \
                    ((len(region_ids)+1)*np.sum(inst_np == 0))

                budget_is_size = area_vor
                budget_is_equalized = total_budget/len(region_ids)

                alpha = 0.5
                maps['v_size'][inst_mask] = alpha * \
                    budget_is_equalized / area_inst
                maps['v_size'][bg_mask] = (
                    1-alpha) * budget_is_equalized / area_bg

                # TODO: There is a midpoint between these approaches where the region_budget is equal, but intra-region split is 0.5

                alpha = area_vor/total_budget
                maps['v_share'][inst_mask] = (1-alpha) * \
                    budget_is_equalized / area_inst
                maps['v_share'][bg_mask] = alpha * \
                    budget_is_equalized / area_bg

                # Topographical approaches
                sigma = self.mountain_sigma * np.sqrt(area_inst / np.pi)
                # Lower bound to prevent division by zero
                sigma = max(sigma, 1.0)
                dists = distance_map[bg_mask]
                bg_decay = np.exp(-dists / sigma)
                bg_integral = np.sum(bg_decay)

                w_l = budget_is_equalized / (area_inst + bg_integral)
                maps['v_mountains'][inst_mask] = w_l
                maps['v_mountains'][bg_mask] = w_l * bg_decay

                # --- Concept: V_ISLANDS (The Moat/Shore) ---
                # We use a wider sigma for the 'moat' to give more breathing room
                sigma = self.island_sigma * np.sqrt(area_inst / np.pi)
                sigma = max(sigma, 1.0)
                # Lower bound to prevent division by zero
                island_growth = 1.0 - np.exp(-dists / sigma)
                i_integral = np.sum(island_growth)

                # WL = Total Area / (Area_L + Sum of growth)
                w_l = budget_is_equalized / (area_inst + i_integral)

                maps['v_islands'][inst_mask] = w_l
                maps['v_islands'][bg_mask] = w_l * island_growth

            for concept, map in maps.items():
                map_sum = np.sum(map)
                unit_sum = np.sum(np.ones_like(map))
                total_delta = np.abs(map_sum - unit_sum)
                assert total_delta < (1e-5 * unit_sum), f"Sum over weight map {concept} not within range of unit tensor, difference: {total_delta}"
                map = torch.from_numpy(map[None, ...])
                if torch.is_tensor(instances):
                    map = map.to(instances.device)
                d[concept] = map
        return d