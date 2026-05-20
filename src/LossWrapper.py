import torch
from typing import Tuple, Sequence, Dict, Any
import torch.nn.functional as F

class WeightedLossWrapper(torch.nn.Module):
    def __init__(self, loss_dict: Tuple[Tuple[Sequence[torch.nn.Module], float], Tuple[Sequence[torch.nn.Module], float]], adaptive: bool=False):
        super().__init__()
        
        self.global_losses = torch.nn.ModuleList(loss_dict[0][0])
        self.local_losses = torch.nn.ModuleList(loss_dict[1][0])
        
        total_weight = loss_dict[0][1] + loss_dict[1][1]
        self.global_weight = loss_dict[0][1] / total_weight
        self.local_weight = loss_dict[1][1] / total_weight
        self.adaptive = adaptive
        self.max_instances = 2048
    
    def adapt_weight_map(self, y_pred: torch.Tensor, batch: Dict[str, Any]) -> Dict[str, Any]:
        labels = batch["label"]       # Shape: (B, 1, H, W) or (B, 1, H, W, D)
        voronoi = batch["voronoi"]     # Same shape
        
        weight_map_std = batch['weight_map']
        weight_map_agg = batch['v_iw']
        B = labels.shape[0]
        
        # 1. Compute the True Positive (TP) mask
        tp_mask = (torch.sigmoid(y_pred) > 0.5) & (labels == 1)
        
        # 2. Shift Voronoi IDs to create unique global IDs across the entire batch
        max_id = int(voronoi.max())
        num_regions_per_sample = max_id + 1
        
        # Using trailing ellipses [..., None] allows this to dynamically adapt 
        # to 2D (B, 1, 1, 1) or 3D (B, 1, 1, 1, 1) structures perfectly.
        view_shape = [B] + [1] * (voronoi.ndim - 1)
        offsets = torch.arange(B, device=voronoi.device).view(view_shape) * num_regions_per_sample
        global_voronoi = (voronoi + offsets).long()
        
        # 3. Count TPs using bincount
        total_global_regions = B * num_regions_per_sample
        
        flat_voronoi = global_voronoi.as_tensor().flatten()
        flat_weights = tp_mask.as_tensor().flatten().float()
        
        # Check if strict determinism is turned on globally
        is_deterministic = torch.are_deterministic_algorithms_enabled()
        
        if is_deterministic:
            # Temporarily disable strict determinism strictly for this CUDA bincount call
            torch.use_deterministic_algorithms(False)
            
        try:
            region_tp_counts = torch.bincount(
                flat_voronoi, 
                weights=flat_weights, 
                minlength=total_global_regions
            )
        finally:
            if is_deterministic:
                # Re-enable strict determinism right after
                torch.use_deterministic_algorithms(True)
        
        # 4. Identify regions that have zero TPs
        missed_global_regions = (region_tp_counts == 0)
        
        # 5. Map the missed status back to the spatial image dimensions
        missed_mask = missed_global_regions[global_voronoi]
        
        # 6. Construct the hybrid weight map
        final_weight_map = torch.where(missed_mask, weight_map_agg, weight_map_std)
        
        # Update the batch dictionary
        batch["weight_map"] = final_weight_map
        return batch
    
    def forward(self, y_pred: torch.Tensor, batch: torch.Tensor) -> torch.Tensor:
        # Re-calculate weight map if adaptive is turned on
        if self.adaptive:
            batch = self.adapt_weight_map(y_pred, batch)
            
        global_total = torch.tensor(0.0, device=y_pred.device, dtype=y_pred.dtype)
        local_total = torch.tensor(0.0, device=y_pred.device, dtype=y_pred.dtype)
        
        for module in self.global_losses:
            global_total += module(y_pred, batch)
            
        for module in self.local_losses:
            local_total += module(y_pred, batch, local = True)
            
        return (global_total * self.global_weight) + (local_total * self.local_weight)


class WeightedDice(torch.nn.Module):
    def __init__(self, eps: float = 1e-6):
        super().__init__()
        self.eps = eps

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: torch.Tensor,
        local = False
    ) -> torch.Tensor:
        probs = torch.sigmoid(y_pred)
        y = batch['label']
        w = batch['weight_map']

        if not local:
            mask_map = torch.ones_like(y)
        else:
            mask_map = batch['voronoi']

        region_ids = torch.unique(mask_map)
        region_losses = []
        for r_id in region_ids:
            region_mask = (mask_map == r_id)
            
            r_probs = probs[region_mask]
            r_y = y[region_mask]
            r_w = w[region_mask]
            
            intersection = torch.sum(r_w * r_probs * r_y)
            denominator = torch.sum(r_w * (r_probs**2 + r_y**2))

            dice_score = (2.0 * intersection + self.eps) / (denominator + self.eps)
            region_losses.append(1.0 - dice_score)
        return torch.stack(region_losses).mean()


class WeightedBCE(torch.nn.Module):
    def __init__(self):
        super().__init__()

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: dict,
        local = False
    ) -> torch.Tensor:
        y = batch['label']
        bce_map = F.binary_cross_entropy_with_logits(y_pred, y, reduction="none")

        bce_map = bce_map * batch['weight_map']

        # If local is turned off, the entire image is the same region
        mask_map = batch['voronoi'] if local else torch.ones_like(y)

        region_ids = torch.unique(mask_map)
        region_losses = []

        for r_id in region_ids:
            mask = (mask_map == r_id)
            r_bce = bce_map[mask].mean()
            
            region_losses.append(r_bce)
        return torch.stack(region_losses).mean()


class Tversky(torch.nn.Module):
    def __init__(self, alpha: float = 0.3, beta: float = 0.7, eps: float = 1e-6):
        super().__init__()
        self.alpha = alpha
        self.beta = beta
        self.eps = eps

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: torch.Tensor,
        local = False
    ) -> torch.Tensor:
        probs = torch.sigmoid(y_pred)
        y = batch['label']
        w = batch['weight_map']

        mask_map = batch['voronoi'] if local else torch.ones_like(y)

        region_ids = torch.unique(mask_map)
        region_losses = []

        for r_id in region_ids:
            mask = (mask_map == r_id)
            
            r_probs = probs[mask]
            r_y = y[mask]
            r_w = w[mask]
            
            TP = torch.sum(r_w * r_probs * r_y)
            FP = torch.sum(r_w * r_probs * (1.0 - r_y))
            FN = torch.sum(r_w * (1.0 - r_probs) * r_y)
            
            # Symmetrically distribute custom spatial weights across the matrix components
            tversky_index = (TP + self.eps) / (
                TP + self.alpha * FP + self.beta * FN + self.eps
            )

            region_losses.append(1.0 - tversky_index)

        return torch.stack(region_losses).mean()