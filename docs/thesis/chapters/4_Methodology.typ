#import "../utils.typ": todo
#import "@preview/glossarium:0.5.9": gls

= Methodology <chapter_methodology>
This section will devote itself to outlining the structure of the implementation of the thesis, the datasets used as well as some notions on their fidelity and subsequent consequences. It will also cover the details of the neural network architecture used and outlines of experiments that were run.

== Datasets <datasets>
The practical implementation of this thesis was evaluated against multiple datasets that span dimensionality (2D as well as 3D), modality (@mri, @em) and various anatmoical features and pathologies that result in varied segmentation instance properties.

Due to the diverse nature of the underlying data, it was imperative to gather dataset statistics that encapsulate these varied instance properties not only to properly evaluate our fundamental hypotheses, but also to deal with noise and errors during training. In order to investigate why certain approaches worked better than others, concrete information on the size, morphology, distribution, and number of instances must be reported and taken into consideration before conclusions can be drawn. This subsection contains a description of the datasets used, their properties and calculated statistics as well as a comprehensive overview on the estimation of their fidelity that could serve as a basis for future research in multi-instance segmentation.

Some statistics of interest on multi-instance datasets are:
- Number of instances per sample
- size distribution of instances
- instance dominance (largest instance fraction of foreground)
- Instance size fraction of voronoi region

=== Statistics and Fidelity of Multi-Instance Segmantation Datasets <dataset_fidelity>
Since this thesis concerns itself with bianry semantic segmentation, all datasets can be abstracted into their constituent components as follows:
An image of shape $(h,w)$ ($(h,w,d)$ in the case of 3D) and a binarized label file of the same shape for each image. The label file is therefore partitioned into background pixels/voxels and $n gt.eq 0$ foreground pixels/voxels. The $n$ foreground pixels/voxels then undergo a process of labeling based on their local neighborhood, in which they are split into $m gt.eq 0$ foreground instances (typically $n gt.double m$). In 2D, this is based on 8-connectivity while 3D instances are labeled using the higher-dimensional equivalent of 26-connectivity.

The resulting instances have inherent properties that are important to examine both when formulating hypotheses as well as investigating noise and segmentation errors. As these properties are of such importance, prior works in the fields of #gls("miqa") and #gls("tda") have provided comprehensive frameworks for identifying the properties of segmentation data and how these impact performance reporting @kofler2023panoptica @maier2022metrics. While these works place substantial focus on the selection and calculation of quantitative segmentation metrics, this section provides a more holistic interpretation of multi-instance dataset attributes that shall aid in the interpretation of results.

#todo(
  "Description of removal of small annotation errors and what theoretical effects these instances would have and a link to the evaluation of intact vs cleaned datasets",
)

=== Brain Metastases
The Stanford brainmetshare dataset @brainmetshare consists of 105 labeled MRI scans with multiple co-registered channels of the human head, with binary labels indicating metastatic cancer lesions. The dataset has been split into (train, validation, test) sets with proportions $(0.7, 0.15, 0.15)$.

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

== Segmentation Evaluation Metrics
Many works have previously discussed the importance of the choice of metrics and the need to adapt to the specific task at hand, @maier2022metrics have provided concrete guidance in the choice of instance-wise metrics in segmentation problems and @kofler2023panoptica provide a tool to calculate these metrics.

Additionally, @jaus2025every proposed a family of metrics that are of particular interest to us since they also use voronoi tesselation and aggregate metrics on each region separately to address instance volume imbalance during evaluation.

This subsection will provide a comprehensive overview of the metrics of interest, the rationales behind this choice and supplementary information on how predicted segmentations were evaluated.

#todo(
  "Relatively metrics-agnostic implementation: No checkpointing, training to completion, mirror sentiment from nnUNet",
)
=== Global Metrics
Global metrics operate simply on the label $Y$ and the prediction $hat(Y)$, they do not take instances, or regions into account and are calculated solely on the number of pixels classified as @tp, @tn:short, @fp, @fn.

Two metrics often seen as complementary are precision and recall (which are also known as specificity and sensitivity respectively):
$
  "precision" = frac("TP","TP"+"FP")
$
$
  "recall" = frac("TP","TP"+"FN")
$

Many other measurements can be said to be derived from precision and recall, one such metric has already been proposed in @eqDSC, but it can be generalized in the case of binary segmentation as the $F_beta$ metric where $beta$ is a non-negative scalar value acting as a weight:

$
  F_beta=frac(1+beta^2 * "TP",(1+beta^2) * "TP" + beta^2 * "FN" + "FP")
$

from this, it can be seen that $F_1$ is equal to $"DSC"$. While this is the most commonly used metric in segmentation, considering alternative values for $beta$ is prudent in certain use cases.

$F_2$ places a higher emphasis on the number of @tp and reduces the importance of @fp values, meaning it results in a higher score if a prediction identifies more positive pixels even if it produces an equal number of false positives.
#todo("Work over this description")

This can be considered as especially important in the high-stakes domain of medical imaging where finding segmentation pixels is often more important than predicting real negatives as positives.
=== Instance-wise Metrics
Instance-wise metrics are of particular interest to us since they give us a measure of how well a model performs at predicting each foreground component  in the image. A lot of these metrics are formalized and implemented in @kofler2023panoptica which provides an algorithm that tries to match predicted instances to ground truth instances using an approximation algorithm. Once a matching instance has been identified, metrics such as @assd or @cedi can be calculated on the pair of components.

#todo("Clarify sq_assd, etc. Text suffices")

#todo("explain maybe instead of ASSD, CEDI formulas")

Instance F1, Instance Dice, CCDice, Instance Recall by volume

== Loss Formulation and Weighted Combination<loss_functions>
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
=== Weight Maps
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
Any of the above discussed weight maps can be easily incorporated into arbitrary loss functions. The loss functions discussed in @loss_functions can be adapted into their weighted counterparts as follows:

$
  cal(L)_"Dice"_w=1-frac(2 sum_(i=1)^N w_i hat(y)_(i)y_i, sum_(i=1)^N w_i (hat(y)_i^2+y_i^2))
$

$
  cal(L)_"BCE"_w=-w_i (y_i log hat(y)_i+(1-y_i) log(1-hat(y)_i))
$

$
  cal(L)_"Tversky"_w (alpha, beta)=1-frac(sum_(i=1)^N hat(y)_i y_i, sum_(i=1)^N hat(y)_i y_i + alpha sum_(i=1)^N hat(y)_i (1-y_i) + beta sum_(i=1)^N (1-hat(y)_i) y_i)
$

== Model Architecture
This section describes the technical setup used in the construction of the training pipeline, the architecture of the adaptive neural network used in experiments, etc.
=== Adaptive U-Net
#todo("A description of a somewhat adaptive UNet that can handle 2D and 3D data")
=== Precomputation and Image Patching
#todo("Instance information, voronoi maps, and weight maps can be precomputed and patched alongside images and labels.")
This can lead to artifacts in train patches that are devoid of instances, but are still tesselated as a region and therefore punish FPs more harshly than in LTLC.

== Experimental Setup
 