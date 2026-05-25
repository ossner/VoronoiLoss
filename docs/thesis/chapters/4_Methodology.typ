#import "../utils.typ": todo
#import "@preview/glossarium:0.5.9": gls

= Methodology <chapter_methodology>
This section gives a description outlining the concrete implementation of the thesis. It gives a comprehensive review of the datasets in @sec_datasets as well as some notions on their fidelity and its consequences. @sec_metrics describes and formalizes the metrics used to evaluate the performance of the experiments and the reasoning behind them. In @sec_loss_functions_method, all used loss functions and their combination into global and local components are described. Additionally, different instance-aware weight maps and their incorporation into these losses are proposed. @sec_modelarchitecture describes the adaptive model architecture used for both 2D and 3D data. Finally, @sec_experimentalsetup describes which experiments have been conducted and why they were chosen.

== Datasets <sec_datasets>
The practical implementation of this thesis was evaluated against multiple datasets that span dimensionality (2D as well as 3D), modality (@mri, @em) and various anatmoical features and pathologies that result in varied segmentation instance properties.

Due to the diverse nature of the underlying data, it was imperative to gather dataset statistics that encapsulate these varied instance properties not only to properly evaluate our fundamental hypotheses, but also to deal with noise and errors during training. In order to investigate why certain approaches worked better than others, concrete information on the size, morphology, distribution, and number of instances must be reported and taken into consideration before accurate conclusions can be drawn. This subsection contains a description of the datasets used, their properties and calculated statistics as well as a comprehensive overview on the estimation of their fidelity.

Some reported statistics of interest on multi-instance datasets are:
- Number of instances per sample
- Size distribution of instances
- Instance dominance (largest instance fraction of foreground)
- Instance size fraction of containing voronoi region
- Morphological attributes such as compactness, sphereness, skewness, stringiness
#todo("The morphology was used in blob loss, perhaps add this to the appendix?")

Adhering to current methods and standards, all datasets have been partitioned into a train, validation and test set, with the train set being used for algorithmic model optimization, the validation (val) set being used for hyperparameter tuning such as learning rate adjustment and the test set being used only once to report the final metrics of the model.

=== On Statistics and Fidelity of Multi-Instance Segmantation Datasets <dataset_fidelity>
Since this thesis concerns binary semantic segmentation, all datasets can be abstracted into their constituent components as follows:
An image of shape $(n_x,n_y)$ ($(n_x,n_y,n_z)$ in the case of 3D) and a binarized label $Y$ of the same shape for each image. Each image and accompanying label therefore contains a total of $N=n_x*n_y*n_z$ voxels.

As introduced in @sec_connectedcomponents, the binary label file can be used to calculate sptially connected instances $I$ using a neighborhood parameter, in this work 2D connected component analysis exclusively used 8-connectivity, whereas 3D connected components used 26-connectivity (see @figneighborhood for a visual interpretation of these neighborhood parameters).

The resulting instances have inherent properties that are important to examine, both when formulating hypotheses, as well as investigating noise and segmentation errors. As these properties are of such importance, prior works in the field have provided comprehensive frameworks for identifying the properties of segmentation masks and how these impact performance reporting @kofler2023panoptica @maier2022metrics. While these works place their focus on the selection and calculation of quantitative segmentation metrics, this section aims to simply describe the attributes of the instances within datasets.

It furthermore analyzes probable annotation errors and how the inclusion of those errors can skew behaviors of instance-aware segmentation implementations.

=== Brain Metastases
The Stanford brainmetshare dataset @brainmetshare consists of 105 labeled MRI scans with multiple co-registered channels of the human head, with binary labels indicating metastatic cancer lesions. The dataset has been randomly split into (train, validation, test) sets with proportions $(0.7, 0.15, 0.15)$ respectively.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/sbmsample.png", width: 45%),
    image("../figures/sbm_metrics.png", width: 100%),
  ),
  caption: [
  ],
) <figsbmmetrics>
#todo("Split description, instance distribution, sizes and variance, etc.")
=== White Matter Hyperintensities
The @wmh dataset @wmhdataset contains 170 MRI scans with labels indicating the presence of @wmh:pl which manifest as especially morphologically diverse instances.
#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/wmhsample.png", width: 45%),
    image("../figures/wmh_metrics.png", width: 100%),
  ),
  caption: [
  ],
) <figwmhmetrics>
#todo("Split description, instance distribution, sizes and variance, etc.")
=== Platelet Organelles
In the platelet organelles dataset @plateletdataset, @em was used to image multiple human blood platelet cells and expert labels were created indicating multiple types of organelles. Of particular interest to this work were the canalicular vessels and alpha granules as they are present in high numbers and varied shapes and sizes in each platelet cell.
The 72 individual 2D slices were extracted from the original .tiff files and split into (train, val, test) with proportions $(0.6, 0.2, 0.2)$ from each file. This served as a means to gather data more generalized data since intensities between scans can vary greatly.
#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/cvsample.jpeg", width: 45%),
    image("../figures/cv_metrics.png", width: 100%),
  ),
  caption: [
  ],
) <figplateletcvmetrics>
#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/agsample.jpeg", width: 45%),
    image("../figures/ag_metrics.png", width: 100%),
  ),
  caption: [
  ],
) <figplateletagmetrics>

#todo("Split description, instance distribution, sizes and variance, etc.")
=== Mitochondria
The EPFL mitochondria dataset introduced by Lucchi et al. @epflmitochondria is another @em dataset that shows images taken from the hippocampus region of the brain with segmentations of mitochondrial organelles and serves as a common benchmark for certain segmentation tasks. 2D slices were again extracted from the 3D volume and used as independent image samples.
#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/connected_components.png", width: 45%),
    image("../figures/mit_metrics.png", width: 100%),
  ),
  caption: [
  ],
) <figepflmetrics>
#todo("Split description, instance distribution, sizes and variance, etc.")

== Segmentation Evaluation Metrics <sec_metrics>
Many works have previously discussed the importance of the choice of metrics and the need to adapt to the specific task at hand, Maier et al. @maier2022metrics have provided concrete guidance in the choice of instance-wise metrics in segmentation problems and Kofler et al. @kofler2023panoptica provide a tool to calculate many of these metrics.

Additionally, Jaus et al. @jaus2025every proposed a family of metrics that are of particular interest to us since they use voronoi tesselation to aggregate metrics on each region separately and average them to identify learned instance imbalance during evaluation.

This section will provide a comprehensive overview of the metrics of interest, the rationales behind their choice and supplementary information on how predicted segmentations were evaluated.

=== Global Metrics
Global metrics operate simply on the label $Y$ and the prediction $hat(Y)$, they do not take instances or regions into account and are calculated solely on the number of pixels classified as @tp, @tn:short, @fp, @fn.

Two metrics often seen as complementary are precision and recall (which are also known as specificity and sensitivity respectively):
$
  "precision" = frac("TP","TP"+"FP")
$
$
  "recall" = frac("TP","TP"+"FN")
$

Many other measurements can be derived from precision and recall, one such metric has already been proposed in @eqDSC, but it can be generalized in the case of binary segmentation as the $F_beta$ metric where $beta$ is a non-negative scalar value acting as a weight:

$
  F_beta=frac(1+beta^2 * "TP",(1+beta^2) * "TP" + beta^2 * "FN" + "FP")
$

$F_1$ is equal to the $"DSC"$. While $beta=1$ is the most commonly chosen value in segmentation, considering alternative values for $beta$ is prudent in certain use cases. 

$F_2$ places a higher emphasis on the number of @tp and reduces the importance of @fp values, meaning it results in a higher score if a prediction identifies more positive pixels even if it produces an equal number of false positives. This can be considered as especially important in the high-stakes domain of medical imaging where finding segmentation pixels is often more important than predicting real negatives as positives.
=== Instance-wise Metrics
Instance-wise metrics are of particular interest to us since they give us a measure of how well a model performs at predicting each connected foreground component in the image. A lot of these metrics are formalized and implemented in tha Panoptica library described in @kofler2023panoptica, which provides an algorithm that tries to match predicted instances to ground truth instances using an approximation algorithm. Once a match has been identified, metrics such as @assd or @cedi can be calculated on the pair of components.

#todo("Clarify sq_assd, etc. Text suffices")

#todo("explain maybe instead of ASSD, CEDI formulas")

Instance F1, Instance Dice, CCDice, Instance Recall by volume

== Loss Formulation and Weighted Combination<sec_loss_functions_method>
This section provides a concrete formulation of the loss functions that were used and compared during the course of our experimentation, since there are many loss functions to choose from and the introduction of hyperparaters makes a complete comparrison untractable, we will limit ourselves to the most common losses.

$
  cal(L)_"Dice"=1-frac(2sum_(i=1)^N hat(y)_(i)y_i, sum_(i=1)^N (hat(y)_i^2+y_i^2))
$

$
  cal(L)_"BCE"=-(y_i log hat(y)_i+(1-y_i) log(1-hat(y)_i))
$

$
  cal(L)_"Tversky" (alpha, beta)=1-frac(sum_(i=1)^N hat(y)_i y_i, sum_(i=1)^N hat(y)_i y_i + alpha sum_(i=1)^N hat(y)_i (1-y_i) + beta sum_(i=1)^N (1-hat(y)_i) y_i)
$

$cal(L)_"Dice"$ and $cal(L)_"BCE"$ are often combined into a compound loss function $cal(L)_"DiceCE"$ using individual weights $lambda_"Dice"$ and $lambda_"BCE"$ (though these are almost always set to $1$) in the formulation:

$
  cal(L)_"DiceCE"=lambda_"Dice"cal(L)_"Dice"+lambda_"BCE"cal(L)_"BCE"
$

#todo(
  "Tested Losses, Global vs. Local splits and weight distribution and normalization as potential shortcombing of previous studies",
)

=== Voronoi-based Loss Paradigm

Why does everyone combine local and global losses?

Why didn't anyone account for potential absolute value inconsistency when doing so?
=== Weight Maps <sec_weight_maps_method>
Weight maps provide a way to emphasize different aspects of the segmentation based on the ground truth labels, they can be precomputed and are therefore an efficient way to introduce assumptions and address computational biases.
$
  W:{w_1,w_2,dots, w_N | w_i in RR, sum_i^N w_i=1}
$

#todo("Budgets, unit tensor, etc. basics")
==== Inverse Weighting
#todo("Formula, hypothesis, figure")
==== Equal Region Weights
#todo("Formula, hypothesis, figure")
==== Region Proportion Weights
#todo("Formula, hypothesis, figure")
==== Voronoi Mountains
#todo("Formula, hypothesis, figure")
==== Voronoi Islands
#todo("Formula, hypothesis, figure")
=== Weighted Losses
Any of the above discussed weight maps can be easily incorporated into arbitrary loss functions. The loss functions discussed in @sec_loss_functions_method can be adapted into their weighted counterparts as follows:

$
  cal(L)_"Dice"_w=1-frac(2 sum_(i=1)^N w_i hat(y)_(i)y_i, sum_(i=1)^N w_i (hat(y)_i^2+y_i^2))
$

$
  cal(L)_"BCE"_w=-w_i (y_i log hat(y)_i+(1-y_i) log(1-hat(y)_i))
$

$
  cal(L)_"Tversky"_w (alpha, beta)=1-frac(sum_(i=1)^N hat(y)_i y_i, sum_(i=1)^N hat(y)_i y_i + alpha sum_(i=1)^N hat(y)_i (1-y_i) + beta sum_(i=1)^N (1-hat(y)_i) y_i)
$

== Model Architecture<sec_modelarchitecture>
This section describes the technical setup used in the construction of the training pipeline, the architecture of the adaptive neural network used in experiments, etc.
=== Adaptive U-Net
#todo("A description of a somewhat adaptive UNet that can handle 2D and 3D data")
=== Precomputation and Image Patching
#todo("Instance information, voronoi maps, and weight maps can be precomputed and patched alongside images and labels.")
This can lead to artifacts in train patches that are devoid of instances, but are still tesselated as a region and therefore punish FPs more harshly than in LTLC.
#todo(
  "Relatively metrics-agnostic implementation: No checkpointing, training to completion, mirror sentiment from nnUNet",
)

== Experimental Setup<sec_experimentalsetup>
 