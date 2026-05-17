#import "../utils.typ": todo

= Related Work <related_work>
This chapter covers prior research on the topic of multiple instance semantic segmentation, covering ways in which the instance imbalance problem posed earlier can be addressed. Since this has been done mainly through the use of specialized loss functions, it also provides a current landscape of common loss functions and their instance-aware extensions.

== A Taxonomy of Losses <loss_taxonomy>
A general idea of the current loss landscape in segmentation is proposed in @ma2021lossodyssey. The authors proposed a taxonomy that is valuable in understanding what abstractions can be found in the current thinking and how we can apply these abstractions to enhance problem-specific approaches. The researchers compiled the most common segmentation loss functions into four distinct categories, which we will later extend by a fifth:
1. Distribution-based losses such as @ce and Focal Loss
2. Region-based losses such as Dice or Tversky
3. Compound losses commonly combine distribution-based losses and region-based losses, for example DiceCE and DiceFocal
4. Boundary-based losses comprise a relatively new type of loss function that aims to minimize the distance between ground truth and predicted segmentation (e.g. Boundary Loss)

This provides a solid foundation of the different approaches that have been made to address specific segmentation problems as well as an evaluation in multiple popular segmentation datasets, showing that a compound of Dice loss and a variation of cross entropy generally provides the highest evaluation scores. This finding is consistent with the frequent use of DiceCE in medical image segmentation @liu2024we @zhang2021lesloss. Liu et al. propose that this is due to a deep implicit connection between the two losses @liu2024we.

== Instance-wise Losses
Multiple earlier works have shown that the use of the connected component algorithm to identify separate instances can be successfully incorporated into loss functions. Kofler et al. have published an  @kofler2023blobloss wherein instances are treated as individual, equally-weighted components of the loss formulation.

Using the notation of $K$ Instances $I$ identified using the connected components  described in @chapter_background the loss function $cal(L)_"blob"$ can be formulated as

$
  cal(L)_"blob" (Y, hat(Y)) = frac(1,K) sum_(k=1)^K cal(L)((y_i)_(i in I_k),(hat(y)_i)_(i in I_k) )
$<eq_blobloss>

This means that the loss value for each individual instance is calculated by only considering the pixels in that instance and averaging those loss values over all $K$ instances. This therefore describes not any specific loss function, but a general paradigm that can be applied using any loss function (the authors evaluate both Dice and Tversky loss as the function $cal(L)$ used in @eq_blobloss).

The instance-wise loss is then combined with a global loss component and invidual weighting terms $alpha$ and $beta$ to form:
$
  cal(L)_"total" = alpha cal(L)_"global" + beta cal(L)_"blob"
$
The ideal weights are explored experimentally and the researchers found that $alpha=2, beta=1$ provide the best results, meaning an increased impact of the global component leads to improved segmentation performance.

Zhang et al @zhang2021lesloss further expand the instance-wise loss space by transforming ground-truth lesions into uniform spheres, meaning every instance, no matter its size is represented in a separate target mask as a sphere around the instance centroid. This is shown to improve segmentation on multiple sclerosis datasets.

This notion of global and local components is mirrored in other instance-aware loss research such as @rachmadi2024iciloss and @rachmadi2024family which propse multiple novel loss functions based on connected components. In addition to connected components identification on the binary labels, these works also introduce connected components analysis on predicted segmentation, providing instance-level information for the learning signal such as the number of predicted instances vs. the number of label instances. This discrepency between predicted and labeled instance is used for example in $cal(L)_"false"$ @rachmadi2024family.

The introduction of instance analysis on prediction masks incurs a significant computational overhead since the connected components must be calculated on-the-fly as opposed to the precomputation on label masks only @rachmadi2024family.

A recent paper by Bouteille et al. includes the concept of voronoi regions as a partition of the image for the purpose of loss calculation @bouteille2025learning. They call this approach CC-loss. Similar to blob loss, the researchers use these voronoi regions as a masking function, averaging a local component across all regions, but also combining them with a global component. However, both blob loss and CC-loss fail to account for the change of total loss magnitude in their comparisons to the global-only loss. Furthermore, Bouteille at al. do not provide an analysis on the relative importance of $alpha$ and $beta$ and while the CC-loss methodology can be applied to arbitrary losses, only DiceCE is present in the evaluation.

These recent research directions can extend the taxonomy proposed in @ma2021lossodyssey by the following category.
5. Instance-aware losses that use the calculation of connected components on the label mask to provide a learning signal to the network.

These instance-aware loss functions can provide both a flexible paradigm (e.g. in the case of $cal(L)_"blob"$) as well as concrete instance-based learning signals (as is the case in $cal(L)_"false"$).

== Weight Maps
Shirokik et al. introduced weight maps to address the instance-imbalance problem. Weight maps can be seen as tensors $W$ of the same shape as the image and label, but they can be applied to the prediction mask to change the contribution of individual voxels to the loss calculation @shirokikh2020universal. In their proposed @iw approach, the weight map is calculated by equally distributing a fixed budget corresponding to the number of voxels in the image across all connected components as well as the background.

This results in an increased weight in smaller lesions compared to larger ones, but generally also results in the background voxels being assigned a much lower weight as the budget needs to be distributed across a significantly larger area. When compared to blob loss, however, @iw is unable to improve segmentation results @kofler2023blobloss. @iw nevertheless provides a concrete example of how a weight map can be used to address specific shortcomings of segmentation networks.

This work aims to position itself in the research gap created by these publications, providing a more thorough analysis of the use of voronoi tessellation in loss calculation as well an exploration of possible extensions to improve segmenation in multi-instance segmetnation problems.