import torch
from typing import Sequence, Tuple
import torch.nn.functional as F

class WeightedLossWrapper(torch.nn.Module):
    def __init__(self, loss_dict: Tuple[Tuple[Sequence[torch.nn.Module], float], Tuple[Sequence[torch.nn.Module], float]]):
        super().__init__()
        
        self.global_losses = torch.nn.ModuleList(loss_dict[0][0])
        self.local_losses = torch.nn.ModuleList(loss_dict[1][0])
        
        total_weight = loss_dict[0][1] + loss_dict[1][1]
        self.global_weight = loss_dict[0][1] / total_weight
        self.local_weight = loss_dict[1][1] / total_weight
        
    def forward(self, y_pred: torch.Tensor, batch: torch.Tensor) -> torch.Tensor:
        global_total = torch.tensor(0.0, device=y_pred.device, dtype=y_pred.dtype)
        local_total = torch.tensor(0.0, device=y_pred.device, dtype=y_pred.dtype)
        
        for module in self.global_losses:
            global_total += module(y_pred, batch)
            
        for module in self.local_losses:
            local_total += module(y_pred, batch, local = True)
            
        return (global_total * self.global_weight) + (local_total * self.local_weight)


class WeightedDice(torch.nn.Module):
    def __init__(self, eps: float = 1e-6, weighted = False):
        super().__init__()
        self.eps = eps
        self.weighted = weighted

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: torch.Tensor,
        local = False
    ) -> torch.Tensor:
        probs = torch.sigmoid(y_pred)
        y = batch['label']
        
        if self.weighted:
            weight_map = batch['weight_map']
            probs = probs * weight_map 

        if not local:
            mask_map = torch.ones_like(y)
        else:
            mask_map = batch['voronoi']

        region_ids = torch.unique(mask_map)
        region_losses = []
        for r_id in region_ids:
            mask = (mask_map == r_id).float()
            m_probs = probs * mask
            m_y = y * mask
            intersection = torch.sum(mask * m_probs * m_y)
            denominator = torch.sum(mask * (m_probs**2 + m_y**2))

            dice_score = (2.0 * intersection + self.eps) / \
                (denominator + self.eps)
            region_losses.append(1.0 - dice_score)
        return torch.stack(region_losses).mean()


class WeightedBCE(torch.nn.Module):
    def __init__(self, weighted = False):
        super().__init__()
        self.weighted = weighted

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: dict,
        local = False
    ) -> torch.Tensor:
        y = batch['label']
        bce_map = F.binary_cross_entropy_with_logits(
            y_pred, y, reduction="none")

        if self.weighted:
            weight_map = batch['weight_map']
            bce_map = bce_map * weight_map 

        if not local:
            mask_map = torch.ones_like(y)
        else: 
            mask_map = batch['voronoi']

        region_ids = torch.unique(mask_map)
        region_losses = []

        for r_id in region_ids:
            mask = (mask_map == r_id)
            region_bce = bce_map[mask].mean()
            region_loss = region_bce
            region_losses.append(region_loss)
        return torch.stack(region_losses).mean()

class Tversky(torch.nn.Module):
    def __init__(self, alpha: float = 0.3, beta: float = 0.7, eps: float = 1e-6, weighted=False):
        super().__init__()
        self.alpha = alpha
        self.beta = beta
        self.eps = eps
        self.weighted = weighted

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: torch.Tensor,
        local = False
    ) -> torch.Tensor:
        probs = torch.sigmoid(y_pred)
        y = batch['label']
        
        if self.weighted:
            weight_map = batch['weight_map']
            probs = probs * weight_map

        if not local:
            mask_map = torch.ones_like(y)
        else: 
            mask_map = batch['voronoi']

        region_ids = torch.unique(mask_map)
        region_losses = []

        for r_id in region_ids:
            mask = (mask_map == r_id).float()

            m_probs = probs * mask
            m_y = y * mask

            TP = torch.sum(m_probs * m_y)
            FP = torch.sum(m_probs * (1.0 - m_y))
            FN = torch.sum((1.0 - m_probs) * m_y)

            tversky = (TP + self.eps) / (
                TP + self.alpha * FP + self.beta * FN + self.eps
            )

            region_losses.append(1.0 - tversky)

        return torch.stack(region_losses).mean()