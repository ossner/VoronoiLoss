#import "../utils.typ": *
#import "@preview/glossarium:0.5.9": gls

= Methodology <chapter_methodology>
This section gives a description outlining the concrete implementation of the thesis. It contains a comprehensive review of the datasets in @sec_datasets as well as some notions on their fidelity and its consequences. @sec_metrics describes and formalizes the metrics used to evaluate the performance of the experiments and the reasoning behind them. In @sec_loss_functions_method, all used loss functions and their combination into global and local components are described. Additionally, different instance-aware weight maps and their incorporation into these losses are proposed. @sec_modelarchitecture describes the adaptive model architecture used for both 2D and 3D data. Finally, @sec_experimentalsetup describes which experiments have been conducted and why they were chosen.

== Datasets and Instance Statistics <sec_datasets>
The practical implementation of this thesis was evaluated against multiple datasets that span dimensionality (2D as well as 3D), modality (@mri, @em) and various anatomical features and pathologies that result in highly varied instance properties. By analyzing our performance on these varied datasets, we aim to show that the approaches can be used both on macro-scale @mri pathologies as well as micro-scale @em organelles and are therefore generalizable and agnostic to biological dimension as well as imaging technique.

Since this thesis concerns binary semantic segmentation, all datasets can be abstracted into their constituent components as follows:
An image of shape $(N_x,N_y)$ ($(N_x,N_y,N_z)$ in the case of 3D) and a binarized label $Y$ of the same shape for each image.

As introduced in @sec_connectedcomponents, the binary label file can be used to calculate spatially connected instances $I$ using a neighborhood parameter. In this work, 2D connected component analysis exclusively used 8-connectivity, whereas 3D connected components used 26-connectivity (see @figneighborhood for a visual interpretation of these neighborhood parameters).

Due to the diverse nature of the underlying data, it is necessary to gather dataset statistics that encapsulate these varied instance properties to properly evaluate our fundamental hypotheses.

Prior works in the field have provided comprehensive frameworks for identifying the properties of segmentation masks and how these metrics impact performance reporting @kofler2023panoptica @maier2022metrics. While these works place their focus on the selection and calculation of quantitative segmentation metrics, this section details the instance attributes within each datasets in order to provide context for the interpretation of experimental results.

Specifically, we report the following statistics on multi-instance datasets:
- Number of instances per sample
- Volume distribution of instances
- Instance dominance (the fraction of the total foreground the largest instance takes up)
- Instance volume as fraction of containing Voronoi region volume

Instance dominance is an important statistic to evaluate across datasets since it can serve as an identifier for volumetrically biased segmentation if images are dominated by few relatively large components with many smaller instances receiving a lower priority in the learning process. An idealized image with $K$ equally-sized instances should have a dominance of $1/K$.

Adhering to current methods and standards, all datasets have been partitioned into a train, validation and test set, with the train set being used for algorithmic model optimization, the validation (val) set being used for hyperparameter tuning such as learning rate adjustment and the test set being used only once to report the final metrics of the model.

All statistics were calculated on the train and val set only to remain agnostic to the test set.

=== Brain Metastases
The Stanford brainmetshare dataset (@mets:short) consists of 105 labeled MRI scans with multiple co-registered channels depicting the human brain, with binary labels indicating metastatic cancer lesions @brainmetshare. The dataset has been randomly split into (train, validation, test) sets with approximate proportions of $(0.7, 0.15, 0.15)$ respectively.

The dataset provides T1-weighted as well as @flair images, which were used as separate channels during training. Labels include at least one brain metastasis.

@figsbmmetrics shows a sample of an image volume with the metastatic cancer lesions as colored instances and several statistical metrics computed on the connected components. The tumors in the sample appear as relatively spherical, yet spatially scattered instances. Most images contain fewer than 20 instances, though some images can contain more than 100 metastases. Instances have a median size of 29 voxels with some encompassing more than 10,000 voxels.

An instance typically makes up only a small fraction of the Voronoi region it gives rise to, likely due to the significant number of voxels that lie outside of the brain and are therefore treated as background. Within images with multiple instances, a significant dominance can be found where the largest instance makes up a high proportion of the total foreground pixels.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -50mm,
    row-gutter: 1mm,

    // Top row
    image("../figures/sbmsample.png", width: 40%),
    image("../figures/metrics/mets/num_instances_hist.png", width: 50%),

    // Middle row (spans both columns)
    grid.cell(
      colspan: 2,
      align: center,
      image(
        "../figures/metrics/mets/instance_volume_hist.png",
        width: 67%,
      ),
    ),

    // Bottom row
    image("../figures/metrics/mets/instance_dominance.png", width: 50%),
    move(dy: -5pt, image("../figures/metrics/mets/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Statistical and visual overview of the @mets dataset. Top left shows a sample image with colored instances in diverse regions of the brain. Top right shows a histogram of the number of instances per image. The center histogram shows the volume distribution of instances. The bottom left scatter plot shows the relative dominance of the largest instance in a volume. The bottom right violin plot shows the ratio of foreground to background voxels within Voronoi regions.],
) <figsbmmetrics>

This dataset presents a critical, high-stakes segmentation challenge. Accurate automated identification and delineation of brain metastases are vital, as missed lesions or incorrect volume estimations directly impact clinical intervention planning, radiation dosing, and ultimately, patient outcomes. The severe clinical consequences of false negatives place an emphasis on a model's ability to robustly detect all instances, regardless of their size or location as even small lesions can have a highly detrimental effect on neurological capabilities @lassman2003brain.

=== White Matter Hyperintensities
The @wmh dataset contains 170 T1-weighted and @flair @mri scans with labels indicating the presence of hyperintensities which manifest as especially morphologically diverse instances @wmhdataset. The 3D volumes were split into the (train, val, test) sets with ratios of $(0.7, 0.15, 0.15)$.

The statistical analysis in @figwmhmetrics shows that images typically contain dozens to hundreds of white matter hyperintensity instances with the lesions in the sample image appearing irregularly shaped and scattered.

While the vast majority of instances are only made up of a few voxels, with a median instance size of 5, a single connected component can also span up to 10,000 voxels. The instance dominance chart also shows that even in images with over 20 instances, the largest one often makes up over 50% of all foreground voxels. This is a consequence of the general manifestation of white matter hyperintensites in periventricular white matter areas, which results in voluminous, elongated instances in the deep regions of the brain (see the yellow and gray instances in the sample of @figwmhmetrics) while also manifesting as smaller lesions in the general cerebrum @merino2019white. On average, instances occupy $<1%$ of their assigned region. This can be explained similarly to the @mets dataset, since the vast amount of background voxels dominates the relatively few foreground voxels in a given region.

The contrast in the instance volume distribution of @wmh lesions to brain metastases shows that metastases are in general much larger while most hyperintensities are smaller than 10 voxels even though the largest components of both can present as equally voluminous.

The @wmh dataset also provides a clinically highly relevant segmentation dataset with hyperintensities acting as a biomarker for several neurological pathologies including ischemic strokes and dementia @li2024association.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -50mm,
    row-gutter: 1mm,

    // Top row
    image("../figures/wmhsample.png", width: 40%),
    image("../figures/metrics/wmh/num_instances_hist.png", width: 50%),

    // Middle row (spans both columns)
    grid.cell(
      colspan: 2,
      align: center,
      image(
        "../figures/metrics/wmh/instance_volume_hist.png",
        width: 67%,
      ),
    ),

    // Bottom row
    image("../figures/metrics/wmh/instance_dominance.png", width: 50%),
    move(dy: -5pt, image("../figures/metrics/wmh/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Statistical and visual overview of the @wmh:long (@wmh) dataset. Top left shows a sample image with colored instances in diverse regions of the brain. Top right shows a histogram of the number of instances per image. The center histogram shows the volume distribution of instances. The bottom left scatter plot shows the relative dominance of the largest instance in a volume. The bottom right violin plot shows the ratio of foreground to background voxels within Voronoi regions.],
) <figwmhmetrics>

=== Platelet Organelles
In the platelet organelles dataset, @em was used to image multiple human blood platelet cells and expert labels were created indicating multiple types of organelles @plateletdataset. This thesis focuses on the segmentation targets @cv and @ag as they are present in high numbers and varied shapes and sizes in each platelet cell.

The 72 individual 2D slices of shape (800*800) were extracted from the original .tiff files and split into (train, val, test) with proportions $(0.6, 0.2, 0.2)$ from each file. This served as a means to gather more generalized data since intensities between scans can vary greatly. All slices were treated as separate 2D images for the calculation of connected components, metrics, and input to the segmentation network.

Both @cv and @ag provide a diverse landscape of connected components. @figplateletcvmetrics and @figplateletagmetrics show dataset samples and statistics of these organelles respectively. Comparatively, alpha granule instances are much larger than canalicular vessels, though there are a fewer of them in each image. As a fraction of the containing Voronoi fraction, they share a similar distribution, since on average both @cv and @ag instances make up $3-5%$ of the region they seeded.
#figure(
  grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -50mm,
    row-gutter: 1mm,

    // Top row
    image("../figures/cvsample.jpeg", width: 40%),
    image("../figures/metrics/cv/num_instances_hist.png", width: 50%),

    // Middle row (spans both columns)
    grid.cell(
      colspan: 2,
      align: center,
      image(
        "../figures/metrics/cv/instance_volume_hist.png",
        width: 67%,
      ),
    ),

    // Bottom row
    image("../figures/metrics/cv/instance_dominance.png", width: 50%),
    move(dy: -5pt, image("../figures/metrics/cv/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Statistical and visual overview of the @cv:long (@cv) dataset. Top left shows a sample image slice with colored instances. Top right shows a histogram of the number of instances per image. The center histogram shows the volume distribution of instances. The bottom left scatter plot shows the relative dominance of the largest instance in a volume. Bottom right shows the ratio of foreground to background voxels within Voronoi regions.
  ],
) <figplateletcvmetrics>

Both canalicular vessels and alpha granules are important components of platelet cells, regulating the response against vascular injury and controlling the clotting of blood. Identification and delineation of these organelles can be used as an indicator of several platelet function disorders. For instance, a reduction or absence of alpha granules can indicate gray platelet syndrome, a debilitating bleeding disorder @tomaiuolo2020use.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -50mm,
    row-gutter: 1mm,

    // Top row
    image("../figures/agsample.jpeg", width: 40%),
    image("../figures/metrics/ag/num_instances_hist.png", width: 50%),

    // Middle row (spans both columns)
    grid.cell(
      colspan: 2,
      align: center,
      image(
        "../figures/metrics/ag/instance_volume_hist.png",
        width: 67%,
      ),
    ),

    // Bottom row
    image("../figures/metrics/ag/instance_dominance.png", width: 50%),
    move(dy: -5pt, image("../figures/metrics/ag/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Statistical and visual overview of the @ag:long (@ag) dataset. Top left shows a sample image slice with colored instances. Top right shows a histogram of the number of instances per image. The center histogram shows the volume distribution of instances. The bottom left scatter plot shows the relative dominance of the largest instance in a volume. Bottom right shows the ratio of foreground to background voxels within Voronoi regions.
  ],
) <figplateletagmetrics>

=== Mitochondria
The EPFL @mit dataset introduced by Lucchi et al. @epflmitochondria is another @em dataset that shows images taken from the hippocampus region of the rodent brain with segmentations of mitochondrial organelles. 2D slices were again extracted from the 3D volume and used as independent image samples. The original dataset consists of two annotated volumes of $(1024*768*165)$. As recommended by the authors, one was used as the training volume, the other was split into the validation and test set. This results in a $(0.5, 0.25, 0.25)$ split.

@figepflmetrics shows dataset statistics on the 2D mitochondria dataset. The number of labeled mitochondria per image is between 10 and 23 and they are generally larger in size than @cv and @ag organelles. There are no severely dominating instances, however in images with 11 label components, the largest instance can make up anywhere from $17%-27%$ of the foreground. The fraction of foreground pixels in Voronoi regions generally follows a similar distribution as the other 2D datasets with regions consisting of $~5%$ foreground.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -50mm,
    row-gutter: 1mm,

    // Top row
    image("../figures/connected_components.png", width: 50%),
    image("../figures/metrics/mit/num_instances_hist.png", width: 50%),

    // Middle row (spans both columns)
    grid.cell(
      colspan: 2,
      align: center,
      image(
        "../figures/metrics/mit/instance_volume_hist.png",
        width: 67%,
      ),
    ),

    // Bottom row
    image("../figures/metrics/mit/instance_dominance.png", width: 50%),
    move(dy: -5pt, image("../figures/metrics/mit/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Statistical and visual overview of the @mit:long (@mit) dataset. Top left shows a sample image slice with colored instances. Top right shows a histogram of the number of instances per image. The center histogram shows the volume distribution of instances. The bottom left scatter plot shows the relative dominance of the largest instance in a volume. Bottom right shows the ratio of foreground to background voxels within Voronoi regions.
  ],
) <figepflmetrics>

Neuronal mitochondria are some of the most energy-demanding organelles of the body, and their natural function is maintaining nominal cognitive capabilities. A dysfunction in mitochondria often manifests as morphological variation such as swelling or altered spatial distribution. These structural alterations are heavily implicated in several neurological diseases such as Alzheimers and Huntingtons, among others @sirois2026mitochondrial.

=== Comparative Dataset Summary <sec_datasetsummary>
@tabdatasetsummary presents a summary and comparison table of all datasets. It shows the diverse segmentation targets, image dimensions, the number of samples used for training, evaluation and testing and the volumetric quartiles of all connected component instances in the dataset.
#figure(
  table(
    columns: (0.075fr, 0.075fr, 0.075fr, 0.175fr, 0.125fr, 0.15fr),
    stroke: (
      y: 1pt + luma(220),
      x: none,
    ),
    inset: 8pt,
    table.header(
      table.cell(align: horizon)[Dataset],
      table.cell(align: horizon)[Modality],
      table.cell(align: horizon)[Dimension],
      table.cell(align: horizon)[Segmentation Target],
      table.cell(align: horizon)[Samples\ (train, val, test)],
      table.cell(align: horizon)[Volumetric Quartiles [Q1,Q2,Q3]],
    ),
    table.hline(start: 1, stroke: 1pt + luma(150)),
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(0), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(0))[METS],
    ),
    [@mri],
    [3D],
    [Brain metastases],
    [(74, 17, 14)],
    [[13, 29, 84]vx],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(1), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(1))[WMH],
    ),
    table.cell(
      rowspan: 1,
      align: center + horizon,
    )[@mri],
    table.cell(
      rowspan: 1,
      align: center + horizon,
    )[3D],
    table.cell(
      rowspan: 1,
      align: center + horizon,
    )[White matter hyperintensities],
    table.cell(
      rowspan: 1,
      align: center + horizon,
    )[(118, 25, 27)],
    table.cell(
      rowspan: 1,
      align: center + horizon,
    )[[3, 5, 13]vx],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(2), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(2))[CV],
    ),
    table.cell(
      rowspan: 1,
      align: center + horizon,
    )[@em],
    [2D],
    [Canalicular Vessels],
    [(44, 15, 15)],
    [[165, 274, 456]px],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(3), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(3))[AG],
    ),
    [@em],
    [2D],
    [Alpha granules],
    [(44, 15, 15)],
    [[478, 901, 1440]px],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(4), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(4))[MIT],
    ),
    [@em],
    [2D],
    [Mitochondria],
    [(165, 82, 83)],
    [[1412, 2274, 3758]px],
  ),
  caption: [A summary overview of all used datasets with identifiable abbreviations and consistent color code for reference. Volumetric quartiles of foreground instances are given in voxels (vx) for 3D and pixels (px) in 2D. The fourth quartile Q4 includes all instances larger than Q3.],
)<tabdatasetsummary>

== Segmentation Evaluation Metrics <sec_metrics>
Many works have previously discussed the importance of the choice of metrics and the need to adapt to the specific task at hand, Maier-Hein et al. @maier2022metrics have provided concrete guidance in the choice of global as well as instance-wise metrics in segmentation problems and Kofler et al. @kofler2023panoptica provide a tool to calculate many of these instance-wise metrics.

Additionally, Jaus et al. @jaus2025every proposed a family of metrics that are of particularly valuable to us since they use Voronoi tesselation to aggregate metrics on each region separately and average them to identify learned instance imbalance during evaluation.

This section will provide a comprehensive overview of the metrics of interest, the rationales behind their choice and supplementary information on how predicted segmentations were evaluated. We further divide metrics into three categories: global, instance-wise, and region-wise indicating the information used in the computation.

=== Global Metrics
Global metrics operate on the label $Y$ and the prediction $hat(Y)$, they do not take instances or regions into account and are calculated solely on the number of pixels classified as @tp, @tn, @fp, @fn (see @taberrorclassification).

Two metrics often seen as complementary are precision and recall (which are also known as specificity and sensitivity respectively):
$
  "precision" = frac("TP", "TP"+"FP")
$<eqprecision>

Precision describes the fraction of true positives among all predicted pixels and therefore does not take into account how many foreground label pixels were missed.

$
  "recall" = frac("TP", "TP"+"FN")
$<eqrecall>

Recall, on the other hand, punishes @fn pixels with no consideration for @fp:pl, meaning a "perfect" segmentation recall can be achieved by predicting every pixel as foreground.

Many other measurements can be derived from precision and recall, one such metric has already been proposed in @eqDSC, but it can be generalized in the case of binary segmentation as the $F_beta$ metric where $beta$ is a non-negative scalar value acting as a weight:

$
  F_beta=frac((1+beta^2) * "TP", (1+beta^2) * "TP" + beta^2 * "FN" + "FP")
$

$F_1$ is equal to $"DSC"$ and while $beta=1$ is the most commonly chosen value in segmentation, considering alternative values for $beta$ is prudent in certain use cases. $F_1$ is also the harmonic mean between precision and recall, higher values for $beta$ place a higher relevance on recall, while lower ones prioritize precision.

=== Instance-wise Metrics
Instance-wise metrics are of particular interest to us since they give us a measure of how well a model performs at predicting each connected foreground component in the image. A lot of these metrics are formalized and implemented in the Panoptica library described by Kofler et al. @kofler2023panoptica, which provides an algorithm that tries to match predicted instances to ground truth instances using an approximation algorithm: The predicted segmentation $hat(Y)$ is used in identifying connected components $hat(I)$. With the set of label instances $I$ and the predicted instances $hat(I)$, an overlap-based matching algorithm is performed. Once a match has been identified, metrics such as @rq or @sq can be calculated on the mapping of predicted to label components. Both of these metrics were introduced by Kirillov et al. @kirillov2019panoptic and @sq later extended into @sqassd in Panoptica.

#figure(
  grid(
    columns: 1,
    align: center + horizon,
    image("../figures/instance_matching.png", width: 80%),
  ),
  caption: [Pixel-wise notions of #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(0), stroke: 0.1pt)) TP, #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(1), stroke: 0.1pt)) FN,  #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(2), stroke: 0.1pt)) FP are extended to instances, with the left two instances being identified as TP instances ($"TP"_"inst"$), the top right being a false positive instance ($"FP"_"inst"$) as the model predicted a component not present in the label. The bottom right component is classified as a false negative ($"FN"_"inst"$) due to the label showing a component without any overlapping prediction pixels.
  ],
) <figinstancematching>

Calculation of these measures is done by extending the notion of segmentation error classification from pixels (as visualized in @figinstanceimbalance) to instances. A simplified overview of instance matching can be seen in @figinstancematching. Using this as a basis, @rq can be calculated analogously to @eqDSC, but considering only the instance error classifications:

$
  "RQ" = frac(2*"TP"_"inst", 2*"TP"_"inst" + "FP"_"inst" + "FN"_"inst")
$<eqrecognitinquality>

Both precision precision (@eqprecision) and recall (@eqrecall) have similar instance-wise counterparts, with instance recall being of critical importance when considering multi-instance datasets in a medical setting. If all label components have a matching predicted component, the instance recall is $1$, if half of them have a matching prediction, the value drops to $0.5$. The label and prediction overlay in @figinstancematching would have an instance recall of $frac(2, 3)$ due to 2 of the 3 label instances having a matched predicted counterpart.

This can be extended by calculating instance recall by volume. Due to the instance imbalance probem posed in @instance_imbalance, quantifying how well a model can spot instances with lower volume can be especially important when this small instance could be a malignant tumor. Therefore, previous works have proposed instance recall by volume, a metric in which all connected components are partitioned into e.g. quartiles based on their volume with the smallest instances in Q1 and the largest in Q4 @bouteille2026learning. The instance recall metric $"recall"_"inst"$ is then computed on each quartile separately, resulting in $("recall"_"inst"_"Q1", "recall"_"inst"_"Q2", "recall"_"inst"_"Q3","recall"_"inst"_"Q4")$. This gives us a comparable measure how well small instances are recognized compared to larger ones.

@sqassd is a boundary based metric that calculates the average deviation of a prediction instance surface to its matched label surface in pixels or voxels. This means that the lower this metric is, the closer the prediction adheres to the label. Perfect predictions would therefore have an @sqassd of 0.

@sqdsc is the last of the truly instance-wise metrics we considered and measures the @dsc averaged over all $"TP"_"inst"$ instances. In the set of all matched instances $cal(I) = {(I_p, I_g) | I_p in hat(I), I_g in I}$ identified by the matching algorithm, @sqdsc can be calculated as:

$
  "SQDSC"(cal(I)) = frac(1, |"TP"_"inst"|)sum_((I_p, I_g) in cal(I))"DSC"(I_p, I_g)
$

Since this metric is calculated only on matched instances, we can again separate the label based on instance volume for the calculation of $("SQDSC"_"Q1", "SQDSC"_"Q2", "SQDSC"_"Q3", "SQDSC"_"Q4")$, to analyze segmentation performance across instance volume quartiles particularly in smaller components to validate our hypotheses of addressing the instance imbalance problem.

=== Region-Wise Metrics
Connected-component metrics are a family of segmentation evaluation statistics introduced by Jaus et al. @jaus2025every that leverage Voronoi regions $R$ computed on the labels $Y$ and seeded by the ground truth instances $I$. In an image, each Voronoi region $R_k in R$ is considered separately. The voxels of the label $Y$ of a particular region are therefore:

$
  Y_R_k = (y_n)_(n in R_k)
$

With $hat(Y)_R_k$ and $tilde(Y)_R_k$ being defined analagously. Then, an arbitrary pixel-wise metric such as @dsc ($F_1$) can be calculated per region and averaged across the image:

$
  "CCDice"(Y, hat(Y)) = frac(1, K) sum_(k=1)^K F_1(Y_R_k, hat(Y)_R_k)
$

CCDice is of particular interest as a metric, as it incorporates the notion that all regions and their instances are equally important.

== Loss Formulations and Weighted Combination<sec_loss_functions_method>
This section provides concrete formulations of the loss functions that were used and compared during the course of our experimentation, since there are many loss functions to choose from and the introduction of hyperparamters makes a complete comparison untractable, we will restrict our comparisons to the most common losses in medical image segmentation introduced in @sec_lossfunctionsbg as a basis and propose several augmentations to them.

@sec_voronoi_loss describes the region-wise paradigm based on Voronoi regions that can be applied to arbitrary loss functions. @sec_weight_maps_method introduces several novel weight maps aimed to provide an efficient way to steer model behaviour.

=== Voronoi-based Region Wise Loss <sec_voronoi_loss>
We define a Voronoi-based loss similarly to CC-Loss introduced by Bouteille et al. @bouteille2026learning as the average region-wise loss across all Voronoi regions $R$ using an arbitrary loss function $cal(L)$:

$
  cal(L)_"Voronoi" (Y,tilde(Y)) = frac(1, K) sum_(k=1)^K cal(L)(Y_R_k, tilde(Y)_R_k)
$<eqvoronoiloss>

@figvoronoiloss shows the process on a label with $K=3$ regions. The labels and predictions from each region are passed to the loss function and their signals are averaged.

#figure(
  grid(
    columns: 1,
    align: center + horizon,
    image("../figures/VoronoiLoss.png", width: 85%),
  ),
  caption: [An example of Voronoi-based region-wise loss. The labels $Y$ and their connected components are used to compute the Voronoi regions $R$. The labels and the predicted segmentation probabilities from the model $tilde(Y)$ are then masked using the regions and the region-wise loss is averaged across them. For visual simplicity, continuous probabilities in the top right image are binarized.
  ],
) <figvoronoiloss>

As in the previously introduced instance-aware loss functions, $cal(L)_"Voronoi"$ is combined with a global loss in a weighted formula where the weights $alpha$ and $beta$ scale the relative importance of the global- and region-wise components:

$
  cal(L)_"total" = alpha * cal(L)_"global" + beta * cal(L)_"Voronoi"
$<eqtotalloss>

In this work, we examine several combinations of weights as well as several different loss functions for both $cal(L)_"global"$ and $cal(L)_"Voronoi"$. During those experiments, it is crucial that the total loss magnitude is kept consistent, in order to avoid implicit scaling of the gradients, altering the effective learning rate @kofler2023blobloss. For this, two user-specified hyperparameter weights $hat(alpha)$ and $hat(beta)$ are normalized in the following fashion:
$
  alpha = frac(hat(alpha), hat(alpha) + hat(beta)), beta = frac(hat(beta), hat(alpha) + hat(beta))
$<eqgloballocalweights>

This constrains the weights to a convex combination $alpha + beta = 1$, with different combinations therefore only altering the ratio of the network's optimization capacity allocated to the global image versus the individual regions.

=== Weight Maps <sec_weight_maps_method>
Weight maps, as previously described in @sec_weight_maps_bg, provide a way to emphasize different aspects of the segmentation based on the ground truth labels, they can be precomputed and are therefore an efficient way to introduce assumptions and address computational biases.

This section provides several examples of novel weight maps calculated on Voronoi regions. As a basis, the "none" weight map $W_"none"$ as the unit tensor can be seen as the standard case, assigning every pixel the same weight, therefore changing nothing in the final calculation when integrated into the loss function:
$
  W_"none" = {w_1, w_2, dots, w_N | w_n = 1}
$<eqvnone>

Given the constraint of a weight map sum having to equal $N$, a weight map can be seen as the distribution of a total "budget" of $N$ with $W_"none"$ distributing this budget equally to every pixel.

Any of the subsequently introduced weight maps can be easily incorporated into arbitrary loss functions. The loss functions discussed in @sec_lossfunctionsbg can be adapted into their weighted counterparts with $w_n$ being the value of the weight map voxel at the same location as $y_n$ and $tilde(y)_n$ in the label and prediction respectively:

$
  cal(L)_"Dice"_w (Y,tilde(Y))=1-frac(2 sum_(n=1)^N w_n tilde(y)_(n)y_n, sum_(n=1)^N w_n (tilde(y)_n^2+y_n^2))
$<eqLDiceweighted>

$
  cal(L)_"BCE"_w (Y,tilde(Y))=-1/N sum_(n=1)^(N) w_n [y_n log tilde(y)_n+(1-y_n) log(1-tilde(y)_n)]
$<eqLBCEweighted>

$
  cal(L)_"Tversky"_w (Y,tilde(Y), alpha_"T", beta_"T")=
  \
  1-frac(sum_(n=1)^N w_n tilde(y)_n y_n, sum_(n=1)^N w_n tilde(y)_n y_n + alpha_"T" sum_(n=1)^N w_n tilde(y)_n (1-y_n) + beta_"T" sum_(n=1)^N w_n (1-tilde(y)_n) y_n)
$<eqLTverskyweighted>

We set $alpha_"T", beta_"T"$ to 0.3 and 0.7 respectively, reducing the penalty of @fp pixels and increasing it for @fn pixels compared to @dsc. These values were identified by Salehi et al. @salehi2017tversky as achieving the best results in their study.

We now present several weight maps aimed at counteracting unwanted loss behaviour in multi-instance segmentation cases. They all rely on the underlying principle of the tessellation of the image into instance-based Voronoi regions and using weights to control the importance of those regions and the instances within them.

==== Equal Region Weights<secvregion>
The equal region weights map $W_"v_region"$ is a naive approach to equalize the weights of all regions $R$, not just in the foreground pixels $I_k$, but also in the background pixels that belong to the same Voronoi region $R_k$.

$
  w_n = frac(N, K|R_k|) quad quad "if" n in R_k
$<eqvregion>

@figvregionmap shows the weight map calculated on the sample image. The tessellation into Voronoi regions is apparent and regions with fewer pixels receive a higher pixel-wise weight. The idea behind this map is that all regions and therefore all instances within them are equalized in importance by dividing the budget of $N$ among all regions.

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_region.png", width: 70%),
  ),
  caption: [A sample of the $W_"v_region"$ weight map. The total available budget $N$ is divided by the number of regions $K$. Each region receives this $frac(N, K)$ budget to distribute equally within it. This results in a higher weight for pixels in smaller regions.
  ],
) <figvregionmap>

==== Voronoi Inverse Weighting<secviw>
Voronoi inverse weighting maps $W_"v_iw"$ aim to combine the concept of inverse weighting introduced by Shirokikh et al. @shirokikh2020universal with Voronoi regions, assigning all regions equal budget and dividing that budget equally between the background and foreground pixels within them:

$
  w_n = cases(
    frac(N, 2K|R_k \\ I_k|) quad quad "if" n in R_k "and" y_n = 0,
    frac(N, 2K|I_k|) quad quad quad quad "if" n in R_k "and" y_n = 1
  )
$<eqviw>

@figviwmap demonstrates an example $W_"v_iw"$ map, even though the entire budget is split equally among regions, the Voronoi regions are not as apparent as in @figvregionmap, this is due to the much higher weight foground instances receive, making the background across regions close, but not equal.

This aims to be a less aggressive and more equalized approach than @iw and although the two maps are mathematically equal if an image contains only a single instance, it inhibits very small connected components and possible single-pixel annotation errors from dominating the weights since they are always bound by the equalized region budget.

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_iw.png", width: 70%),
  ),
  caption: [A sample of the $W_"v_iw"$ weight map. Like in $W_"v_region"$, every Voronoi region receives the same share of the budget, however within a region, the region budget $frac(N, K)$ is split equally among the background and foreground, with the foreground typically having a smaller volume, resulting in higher pixel-wise weight.
  ],
) <figviwmap>

==== Voronoi Mountains<secvmountains>
The Voronoi mountains map $W_"v_mountains"$ utilizes the euclidean distance function $"dist"$ which returns the distance from a given pixel to the surface of an instance. Furthermore a hyperparameter $sigma_m = 2$ scales an exponential weight decay as distance to an instance increases. For any region $R_k$, this gives rise to $S_k = sum_(j in R_k \\ I_k) exp(-"dist"(j, I_k)/sigma_m)$, the sum of background decay in the region. This is used in the construction of each weight map pixel:

$
  w_n = cases(
    frac(N, K(|I_k| + S_k)) * exp(-"dist"(n, I_k) / sigma_m) quad quad & "if" n in R_k "and" y_n = 0,
    frac(N, K(|I_k| + S_k)) quad quad & "if" n in R_k "and" y_n = 1
  )
$<eqvmountains>

@figvmountainsmap Shows a sample of such a weight map, the high instance weights and the decaying weight that increases with distance can be intuitively visualized topographically and takes on a shape akin to a mountain range.

$W_"v_mountains"$ is intended to produce predictions that are highly accurate around the borders of instances, since @fp:pl immediately outside the instance perimeter are punished harshly while still incentivizing the model to discover the highly-weighted instances.

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_mountains.png", width: 70%),
  ),
  caption: [$W_"v_mountains"$ sample showing a radiating effect around the foreground instances with weight values decaying with distance from the foreground instance. The highest weight within a region is typically inside the instance.
  ],
) <figvmountainsmap>

==== Voronoi Islands<secvislands>
Voronoi islands are a concept similar, yet also inverse of the $W_"v_mountains"$ map. All regions again receive the same budget, weighing smaller regions higher. The weights now also scale with the euclidean distance from an instance $"dist"$. $sigma_i=5$ is a scaling factor that determines the sum of the background growth $Z_k$ in a given region $Z_k = sum_(j in R_k \\ I_k) 1-exp(-"dist"(j, I_k)/sigma_i)$ and provides a balance between instance weight and background accumulation.

$
  w_n = cases(
    frac(N, K(|I_k| + Z_k)) * (1 - exp(-"dist"(n, I_k) / sigma_i)) quad quad & "if" n in R_k "and" y_n = 0,
    frac(N, K(|I_k| + Z_k)) quad quad & "if" n in R_k "and" y_n = 1
  )
$<eqvislands>

$W_"v_islands"$ prioritizes instance discovery, if $hat(Y)$ contains foreground far away from a label instance, it is "punished" more harshly. The closer the foreground is to the instance border, the lower the punishment. @figvislandsmap shows how this produces a topographical effect of instances as islands with moats close to them and shores at the border between Voronoi regions. This also leads to an effect in the 2D case where instances close to the border of the image receive a higher weight disproportionate to their size as the available region weight is higher. In the 3D datasets considered, this effect is not noticeable due to the high distance between any foreground instance and the image border.

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_islands.png", width: 70%),
  ),
  caption: [A sample of $W_"v_islands"$ as opposed to $W_"v_mountains"$ decreases weight values close to instance borders, increasing weight exponentially with distance from the foreground.
  ],
) <figvislandsmap>

==== Adaptive Voronoi Weighting<secvadaptive>
Adaptive weighting is a novel Voronoi-based weight concept that can not be precomputed, but is computed on-the-fly based on model behaviour and predictions. Before loss values are calculated, if a region with a visible instance contains at least 1 @tp, it is deemed recognized, with each pixel receiving a weight of 1. If foreground pixels are visible, but no @tp was predicted, the region's pixels receive a weight of $beta = 4$. This makes regions where the model failed to find the foreground $beta$-times more important.

Let $R_k$ be the Voronoi region that contains the instance $I_k$, if the prediction $hat(Y)$ contains no foreground pixels/voxels, the pixels of the region are assigned the weight of $beta$:
$
  v_n = cases(
    beta quad quad "if" n in R_k "," |I_k| > 0", and" sum_(j in I_k) hat(y)_j = 0,
    1 quad quad "otherwise"
  )
$<eqvadaptive_unscaled>

After this is calculated for all regions in the map, the voxels $w$ in $W_"v_adaptive"$ are scaled to keep the unit weight constraint.

$
  w_n = frac(N, sum_(j=1)^N v_j) v_n
$

@figvadaptive Shows a sample of the weight map that contains prediction outputs from a classifier and how these predictions impact the construction of the weight map. In this case, the model failed to predict 4 instances, meaning that the regions to which these instances belong receive a higher weight. After the specific map has been calculated for all regions in the prediction, it is incorporated into the loss function.

#figure(
  image("../figures/weight_maps/v_adaptive.png", width: 45%),
  caption: [An overlay of the $"W"_"v_adaptive"$ map over a prediction map of canalicular vessels. If a Voronoi region contains a single #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(0), stroke: 0.1pt)) TP, the weights are set to 1. If all pixels in a regions instance are #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(1), stroke: 0.1pt)) FN, the weights of the region are set to $beta=4$. After all regions receive their relative weight, the entire map is normalized to make sure its sum is equal to the number of pixels. #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(2), stroke: 0.1pt)) FP pixels have no impact on the weight map.
  ],
) <figvadaptive>

== Model Architecture<sec_modelarchitecture>
This section describes the technical setup used in the construction of the training pipeline and the architecture of the adaptive neural network used in experiments #footnote([The network implementation and additional resources are freely available at #link("https://github.com/ossner/VoronoiLoss", "github.com/ossner/VoronoiLoss")]).

=== Adaptive U-Net
The model architecture used in all experiments is based on the U-Net architecture introduced by Ronneberger et al. @ronneberger2015u specifically for the use in biomedical image segmentation. The implementation from MONAI @cardoso2022monai was parametrized based on the dataset to change the spatial dimenstion (2D vs. 3D) and the number of input channels available.

Since the 3D datasets provide additional co-registered MRI imaging procedures of the same sample, both T1-weighted images as well as @flair images were used as inputs for the 3D network, with the 2D network receiving only the single-channel intensity image provided by @em.

=== Precomputation and Image Patching<sec_precomputation_and_patching>
Since the label files used in loss calculations are static and do not change, efficient precomputation of the connected components, their Voronoi regions and most weight maps significantly speeds up training. @figprecomputation shows the construction of all precomputed information available during training.


#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/precomputation.png", width: 90%),
  ),
  caption: [Demonstration of the preprocessing pipeline. Labels from the dataset are used for computation of instances, Voronoi maps and weight maps and then combined with the accompanying image through a patching process. This results in the total batch information available during training.],
) <figprecomputation>

The introduction of image patching, a common method in segmentation to divide individual samples into many smaller regions of interest, makes precomputation necessary, since calculation of these tensors on-the-fly can introduce several artifacts that do not represent the original data. An example of such an artifact could be an instance that is split on the edges of the patch, resulting in two Voronoi regions from the same component. Image patching extracts multiple sub-images from a larger original sample, diversifying training data when combined with augmentations.

@tabpatching shows the patching parameters used for the training on the different datasets. The overall patching algorithm is based on a positive and negative label approach implemented in the popular MONAI library for medical machine learning @cardoso2022monai, in which the patch location is randomly centered on foreground or background pixels with a ratio of 2:1. When a patching location has been chosen, the sub-image is cropped from all accompanying precomputed weight maps at the same location.
#figure(
  table(
    columns: (auto, auto, auto, auto),
    stroke: (
      x: none,
      y: 1pt + luma(220),
    ),
    inset: 6pt,
    table.header([*Dataset*], [*Source Image Size*], [*Patch RoI*], [*Number of Patches*]),
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(0), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(0))[METS],
    ),
    [$(256,256,150)$],
    [$(96,96,64)$],
    [20],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(1), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(1))[WMH],
    ),
    [$~(240,240,48)$],
    [$(64,64,48)$],
    [16],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(2), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(2))[CV],
    ),
    [$(800,800)$],
    [$(288, 288)$],
    [25],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(3), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(3))[AG],
    ),
    [$(800,800)$],
    [$(288, 288)$],
    [25],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(4), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(4))[MIT],
    ),
    [$(1024,768)$],
    [$(512, 512)$],
    [16],
  ),
  caption: [An overview of the different patching strategies used per dataset. With the source image size as well as the size and number of extracted patches. The @wmh dataset is the only dataset with slightly inconsistent source image dimensions.
  ],
)<tabpatching>

== Experimental Setup<sec_experimentalsetup>
In addition to the patching parameters in @tabpatching, this section gives a description of the hyperparaters used during experimentation, the generation of their results and further important points that aid in reproducibility.

@tabhparams shows the common hyperparameters like learning rate, batch size and number of training epochs. We use a learning rate scheduler based on cosine decay with a warmup period as implemented in MONAI @cardoso2022monai. For each dataset, the warmup period was set to 5% of the total number of training epochs.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    stroke: (
      x: none,
      y: 1pt + luma(220),
    ),
    inset: 6pt,
    table.header([*Dataset*], [*Learning Rate*], [*Batch Size*], [*Num. Training Epochs*]),
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(0), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(0))[METS],
    ),
    [$0.001$],
    [$8$],
    [$500$],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(1), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(1))[WMH],
    ),
    [$0.001$],
    [$16$],
    [$500$],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(2), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(2))[CV],
    ),
    [$0.001$],
    [$16$],
    [$300$],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(3), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(3))[AG],
    ),
    [$0.001$],
    [$16$],
    [$300$],
    table.cell(
      rowspan: 1,
      align: center + horizon,
      stroke: (right: 2pt + datasetcolors.at(4), y: none), // Pretty blue vertical bar
      text(weight: "bold", fill: datasetcolors.at(4))[MIT],
    ),
    [$0.001$],
    [$16$],
    [$300$],
  ),
  caption: [A summary overview of the dataset hyperparameters used during training for each dataset.],
)<tabhparams>

Data augmentations were used to increase the size of the available training data and make the model more robust and generalizable. These augmentations are also implemented in MONAI and offer an efficient and standardized way to apply both spatial- as well as intensity-based augmentations. All samples are passed through a base transformation pipeline that normalizes image intensities, only data from the train set then goes through additional random spatial augmentations such as rotations, flips and zooms. The images from the training set also go through randomized intensity-based transforms, leaving the additional precomputed information seen in @figprecomputation as-is. @tabaugmentations gives an overview of the train augmentations employed. It is crucial that integer-based maps such as Voronoi (which denotes different regions by assigning their voxels an incrementing integer) use nearest neighbor interpolation to avoid altering the region identifiers.

#figure(
  table(
    columns: (2.2fr, 1.2fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    inset: 8pt,
    stroke: (x: none, y: 0.5pt + luma(220)),
    align: center,

    table.header([*Augmentation*], [*Probability*], [*Image*], [*Label*], [*Voronoi*], [*Weight Map*], [*Instances*]),

    // Spatial transforms
    [Flip (axis = 0)], [0.5],
    [✓], [✓], [✓], [✓], [✓],

    [Flip (axis = 1)], [0.5],
    [✓], [✓], [✓], [✓], [✓],

    [Rotate 90° (k ≤ 3)], [0.5],
    [✓], [✓], [✓], [✓], [✓],

    table.cell(align: horizon)[Zoom (0.9–1.1×)],
    table.cell(align: horizon)[0.3],
    [✓ (bilinear)],
    [✓ (nearest)],
    [✓ (nearest)],
    [✓ (bilinear)],
    [✓ (nearest)],

    // Intensity transforms
    [Gaussian smoothing], [0.3],
    [✓], [–], [–], [–], [–],

    [Gaussian noise ($sigma = 0.25$)], [0.3],
    [✓], [–], [–], [–], [–],

    [Intensity scaling ($25%$)], [0.3],
    [✓], [–], [–], [–], [–],

    [Intensity shift ($0.25$)], [0.3],
    [✓], [–], [–], [–], [–],
  ),
  caption: [A summary of the train augmentations, their parameters and how they were applied to the patched sub-volumes. All augmentations were used as implemented in the MONAI library.],
)<tabaugmentations>

In order to remain metric-agnostic and avoid checkpoints that are biased towards a specific measurement in our evaluation, all models were trained to completion using the configurations described above and the model weights from the last training epoch were used to generate test results. This enables a holistic interpretation of the test results without the possibility of a checkpoint being biased towards its highest-performing validation metric. Validation curves across several metrics showed stable convergence without significant degradation or signs of overfitting.

With this technical setup, we evaluated several modifications of the formula presented in @eqtotalloss including different compound loss functions as well as modifying the global and local weights. We focus our analysis of the weight impact on the global and local $cal(L)_"DiceCE"$ combination and train segmentation models on global-only DiceCE $(hat(alpha)=1, hat(beta)=0)$, region-wise only $cal(L)_"DiceCE"$ $(hat(alpha)=0, hat(beta)=1)$ as well as equalized and scaled weights.

We consider standard $cal(L)_"DiceCE"$ operating globally on the image as a baseline. We further analyze the effect of all presented weight maps on this baseline loss.

To improve readability, the formula $cal(L)_"total" = hat(alpha) * cal(L)_"global" + hat(beta) * cal(L)_"Voronoi"$ is simplified to a tuple with the baseline being represented as (DiceCE, none).
