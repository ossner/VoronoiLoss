import torch.nn as nn
import kornia.contrib as kornia_contrib
import torch
from typing import Sequence, Tuple
import torch.nn.functional as F


class WeightedLossWrapper(torch.nn.Module):
    def __init__(self, loss_dict: Sequence[Tuple[str, torch.nn.Module, float]]):
        """
        loss_dict: The linear combination of loss implementations and their respective relative weights
            example: {("Dice", DiceImpl, 1), ("CE", CEImpl: 2), ("CCDiceCE", CCDiceImpl, 1)} would weigh the losses
            among themselves with these weights, but their magnitude would sum to one
        """
        super().__init__()
        # separate into loss dict and normalized weight dict
        self.losses = torch.nn.ModuleDict(
            {name: module for name, module, _ in loss_dict})

        sum_weights = sum([weight for _, _, weight in loss_dict])
        self.weights = {name: (float(weight)/float(sum_weights))
                        for name, _, weight in loss_dict}

    def forward(self, y_pred: torch.Tensor, batch: torch.Tensor) -> torch.Tensor:
        total = torch.zeros((), device=y_pred.device, dtype=y_pred.dtype)
        # Optional: For some experiments, one can calculate the connected components of predictions and use them as instances
        # probs = torch.sigmoid(y_pred)
        # pred_binary = (probs > 0.5).float()
        # pred_instances = kornia_contrib.connected_components(
        #     pred_binary, num_iterations=150)
        # batch['pred_instances'] = pred_instances
        for name, module in self.losses.items():
            weight = self.weights[name]
            if weight == 0:
                continue
            value = module(y_pred, batch)
            total = total + weight * value
        return total


class WeightedDice(torch.nn.Module):
    def __init__(self, weighted = False, eps: float = 1e-6):
        super().__init__()
        self.eps = eps
        self.weighted = weighted

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: torch.Tensor,
        mask_map: torch.Tensor = None,
    ) -> torch.Tensor:

        probs = torch.sigmoid(y_pred)
        y = batch['label']
        weight_map = batch['weight_map']

        if mask_map is None:
            mask_map = torch.ones_like(y)

        region_ids = torch.unique(mask_map)
        region_losses = []
        for r_id in region_ids:
            mask = (mask_map == r_id).float()
            m_probs = probs * mask
            m_y = y * mask
            mask = weight_map * mask if self.weighted else mask
            intersection = torch.sum(mask * m_probs * m_y)
            denominator = torch.sum(mask * (m_probs**2 + m_y**2))

            dice_score = (2.0 * intersection + self.eps) / \
                (denominator + self.eps)
            region_losses.append(1.0 - dice_score)
        return torch.stack(region_losses).mean()


class WeightedBCE(torch.nn.Module):
    def __init__(self, lambda_reg: float = 1.0, weighted = False):
        super().__init__()
        self.lambda_reg = lambda_reg
        self.weighted = weighted

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: dict,
        mask_map: torch.Tensor = None,
    ) -> torch.Tensor:
        y = batch['label']
        weight_map = batch['weight_map']
        bce_map = F.binary_cross_entropy_with_logits(
            y_pred, y, reduction="none")
        bce_map = bce_map * weight_map if self.weighted else bce_map
        if mask_map is None:
            mask_map = torch.ones_like(y)

        region_ids = torch.unique(mask_map)
        region_losses = []

        for r_id in region_ids:
            mask = (mask_map == r_id)
            region_bce = bce_map[mask].mean()
            region_loss = region_bce
            region_losses.append(region_loss)
        return torch.stack(region_losses).mean()


class CCDiceCE(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.bce = WeightedBCE(weighted=True)
        self.dice = WeightedDice(weighted=True)

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        batch: torch.Tensor,
    ) -> torch.Tensor:
        return self.bce(y_pred, batch, batch['voronoi']) + self.dice(y_pred, batch, batch['voronoi'])


class CCTversky(torch.nn.Module):
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
        mask_map: torch.Tensor = None,
    ) -> torch.Tensor:
        probs = torch.sigmoid(y_pred)
        y = batch['label']
        weight_map = batch['weight_map']
        mask_map = batch['voronoi']

        region_ids = torch.unique(mask_map)
        region_losses = []

        for r_id in region_ids:
            mask = (mask_map == r_id).float()

            m_probs = probs * mask
            m_y = y * mask

            w = weight_map * mask if self.weighted else mask

            TP = torch.sum(w * m_probs * m_y)
            FP = torch.sum(w * m_probs * (1.0 - m_y))
            FN = torch.sum(w * (1.0 - m_probs) * m_y)

            tversky = (TP + self.eps) / (
                TP + self.alpha * FP + self.beta * FN + self.eps
            )

            region_losses.append(1.0 - tversky)

        return torch.stack(region_losses).mean()