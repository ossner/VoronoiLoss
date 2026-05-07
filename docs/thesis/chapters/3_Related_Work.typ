#import "../utils.typ": todo

= Related Work <related_work>
This chapter covers prior research on the topic of multiple instance semantic segmentation, covering ways in which the instance imbalance problem posed earlier can be addressed. Since this has been done mainly through the use of specialized loss functions, it also provides a current landscape of common loss functions and their instance-aware extensions.

== A Taxonomy of Losses <loss_taxonomy>
A general idea of the current loss landscape in segmentation is proposed in @ma2021lossodyssey. The authors proposed a taxonomy that is valuable in understanding what abstractions can be found in the current thinking and how we can apply these abstractions to enhance problem-specific approaches. The researchers compiled the most common segmentation loss functions into four distinct categories, which we will later extend by a fifth:
1. Distribution-based losses such as @ce and Focal Loss
2. Region-based losses such as Dice or Tversky
3. Compound losses commonly combine distribution-based losses and region-based losses, for example DiceCE and DiceFocal
4. Boundary-based losses comprise a relatively new type of loss function that aims to minimize the distance between ground truth and predicted segmentation (e.g. Boundary Loss)

This provides a solid foundation of the different approaches that have been made to address specific segmentation problems as well as an evaluation in multiple popular segmentation datasets, showing that a variation of Dice loss generally provides the highest evaluation scores.
== Instance-wise Losses
Multiple earlier works have shown that the use of the connected component algorithm to identify separate instances can be successfully incorporated into loss functions. The most impactful seems to have been @kofler2023blobloss wherein instances are treated as individual, equally-weighted components of the loss formulation.
@zhang2021lesloss
@rachmadi2024iciloss
@rachmadi2024family
@bouteille2025learning

#todo("Extend loss odyssey figure with instance-wise losses")

== Weight Maps
@shirokikh2020universal