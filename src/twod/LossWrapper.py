import torch
from typing import Sequence, Tuple
import torch.nn.functional as F

class WeightedLossWrapper(torch.nn.Module):
    def __init__(self, loss_dict: Sequence[Tuple[str, torch.nn.Module, float]], weight_map = 'none'):
        """
        loss_dict: The linear combination of loss implementations and their respective relative weights
            example: {("Dice", DiceImpl, 1), ("CE", CEImpl: 2), ("CCDiceCE", CCDiceImpl, 1)} would weigh the losses
            among themselves with these weights, but their magnitude would sum to one
        weight_map: The weight map used to give different importances to different pixels, can be one of 
            ['none' (unit weight), 'iw' (inverse weighting), 'v_size' (inverse voronoi-region-based weights with equal share),
            'v_share' (inverse voronoi-region-based weights with region proportion share),
            'v_mountains' (voronoi-region-based weights exponential decay), 'v_islands'  (voronoi-region-based weights inverse exponential decay)]
        """
        super().__init__()
        assert weight_map in ['none', 'iw', 'v_size',
                              'v_share', 'v_mountains', 'v_islands'], f'Provided weight map {weight_map} not valid. Choose one of {['none', 'iw', 'v_size','v_share', 'v_mountains', 'v_islands']}'
        self.weight_map = weight_map
        # separate into loss dict and normalized weight dict
        self.losses = torch.nn.ModuleDict(
            {name: module for name, module, _ in loss_dict})
        
        sum_weights = sum([weight for _,_,weight in loss_dict])
        self.weights = {name: (float(weight)/float(sum_weights)) for name, _, weight in loss_dict}

    # TODO: This is getting unwieldy with the number of potential arguments, it would be more clean to pass the batch as a whole and only use the parts that are used maybe?
    def forward(self, y_pred: torch.Tensor, batch: torch.Tensor) -> torch.Tensor:
        total = torch.zeros((), device=y_pred.device, dtype=y_pred.dtype)
        for name, module in self.losses.items():
            weight = self.weights[name]
            if weight == 0:
                continue
            value = module(y_pred, batch['label'], batch[self.weight_map], batch['voronoi'])
            total = total + weight * value
        return total


class Dice(torch.nn.Module):
    def __init__(self, eps: float = 1e-6):
        super().__init__()
        self.eps = eps

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        y: torch.Tensor,       # targets (B,1,H,W)
        weight_map: torch.Tensor = None,  # ignored
        voronoi_map: torch.Tensor = None,  # ignored
    ) -> torch.Tensor:

        probs = torch.sigmoid(y_pred)

        dims = (2, 3)

        intersection = (probs * y).sum(dim=dims)
        denominator = probs.sum(dim=dims) + y.sum(dim=dims)

        dice_score = (2.0 * intersection + self.eps) / (denominator + self.eps)
        dice_loss = 1.0 - dice_score.mean()
        return dice_loss
        

class CE(torch.nn.Module):
    def __init__(self):
        super().__init__()

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        y: torch.Tensor,       # targets (B,1,H,W)
        weight_map: torch.Tensor,
        voronoi_map: torch.Tensor = None,  # ignored
    ) -> torch.Tensor:

        bce_map = F.binary_cross_entropy_with_logits(
            y_pred,
            y,
            reduction="none"
        )  # (B,1,H,W)

        if weight_map is None:
            return bce_map.mean()

        weighted = bce_map * weight_map
        return weighted.mean()


class CCDiceCE(torch.nn.Module):
    def __init__(self, eps: float = 1e-6):
        super().__init__()
        self.eps = eps

    def forward(
        self,
        y_pred: torch.Tensor,  # logits (B,1,H,W)
        y: torch.Tensor,       # targets (B,1,H,W)
        weight_map: torch.Tensor,  # (B,1,H,W)
        voronoi_map: torch.Tensor,  # (B,1,H,W)
    ) -> torch.Tensor:
        B = y_pred.shape[0]
        probs = torch.sigmoid(y_pred)

        total_loss = 0.0
        region_counter = 0
        
        for b in range(B):

            regions = torch.unique(voronoi_map[b, 0])
            for r in regions:
                region_mask = (voronoi_map[b, 0] == r)

                if region_mask.sum() == 0:
                    continue
                
                probs_b = probs[b, 0]   # (H, W)
                y_b = y[b, 0]       # (H, W)
                logits_b = y_pred[b, 0]  # (H, W)

                probs_r = probs_b[region_mask]
                y_r = y_b[region_mask]


                if weight_map is not None:
                    weights_b = weight_map[b, 0] if weight_map.ndim == 4 else weight_map[b]
                    weights_r = weights_b[region_mask]
                else:
                    weights_r = None

                # ----- Dice -----
                intersection = (probs_r * y_r).sum()
                denominator = probs_r.sum() + y_r.sum()

                dice_score = (2.0 * intersection + self.eps) / (denominator + self.eps)
                dice_loss = 1.0 - dice_score

                # ----- CE -----
                ce_map = F.binary_cross_entropy_with_logits(
                    logits_b[region_mask],
                    y_b[region_mask],
                    reduction="none"
                )

                if weights_r is not None:
                    ce_loss = (ce_map * weights_r).mean()
                else:
                    ce_loss = ce_map.mean()

                region_loss = (
                    dice_loss + ce_loss
                )

                total_loss += region_loss
                region_counter += 1

        if region_counter == 0:
            return torch.tensor(0.0, device=y_pred.device)

        return total_loss / region_counter
