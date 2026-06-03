#import "../utils.typ": todo, class_colors
#import "@preview/glossarium:0.5.9": gls

= Methodology <chapter_methodology>
This section gives a description outlining the concrete implementation of the thesis. It gives a comprehensive review of the datasets in @sec_datasets as well as some notions on their fidelity and its consequences. @sec_metrics describes and formalizes the metrics used to evaluate the performance of the experiments and the reasoning behind them. In @sec_loss_functions_method, all used loss functions and their combination into global and local components are described. Additionally, different instance-aware weight maps and their incorporation into these losses are proposed. @sec_modelarchitecture describes the adaptive model architecture used for both 2D and 3D data. Finally, @sec_experimentalsetup describes which experiments have been conducted and why they were chosen.

== Datasets <sec_datasets>
The practical implementation of this thesis was evaluated against multiple datasets that span dimensionality (2D as well as 3D), modality (@mri, @em) and various anatmoical features and pathologies that result in varied segmentation instance properties.

Due to the diverse nature of the underlying data, it was imperative to gather dataset statistics that encapsulate these varied instance properties not only to properly evaluate our fundamental hypotheses, but also to deal with noise and errors during training. In order to investigate why certain approaches worked better than others, concrete information on the size, morphology, distribution, and number of instances must be reported and taken into consideration before accurate conclusions can be drawn. This subsection contains a description of the datasets used, their properties and calculated statistics as well as a comprehensive overview on the estimation of their fidelity.

Some reported statistics of interest on multi-instance datasets are:
- Number of instances per sample
- Volume distribution of instances
- Instance dominance (what fraction of the total foreground the largest instance takes up)
- Instance volume as fraction of containing voronoi region volume $(frac(|I_k|,|R_k|-|I_k|))$

Adhering to current methods and standards, all datasets have been partitioned into a train, validation and test set, with the train set being used for algorithmic model optimization, the validation (val) set being used for hyperparameter tuning such as learning rate adjustment and the test set being used only once to report the final metrics of the model.

All statistics were calculated on the train and val set only to remain agnostic to the test set.

=== On Statistics and Fidelity of Multi-Instance Segmantation Datasets <dataset_fidelity>
#todo("Perhaps split this into statistics description and reasoning and later fidelity")
Since this thesis concerns binary semantic segmentation, all datasets can be abstracted into their constituent components as follows:
An image of shape $(n_x,n_y)$ ($(n_x,n_y,n_z)$ in the case of 3D) and a binarized label $Y$ of the same shape for each image.

As introduced in @sec_connectedcomponents, the binary label file can be used to calculate sptially connected instances $I$ using a neighborhood parameter, in this work 2D connected component analysis exclusively used 8-connectivity, whereas 3D connected components used 26-connectivity (see @figneighborhood for a visual interpretation of these neighborhood parameters).

The resulting instances have inherent properties that are important to examine, both when formulating hypotheses, as well as investigating noise and segmentation errors. As these properties are of such importance, prior works in the field have provided comprehensive frameworks for identifying the properties of segmentation masks and how these impact performance reporting @kofler2023panoptica @maier2022metrics. While these works place their focus on the selection and calculation of quantitative segmentation metrics, this section aims to simply describe the attributes of the instances within datasets.

It furthermore analyzes probable annotation errors and how the inclusion of those errors can skew behaviors of instance-aware segmentation implementations.

=== Brain Metastases
The Stanford brainmetshare dataset (@mets:short) @brainmetshare consists of 105 labeled MRI scans with multiple co-registered channels of the human head, with binary labels indicating metastatic cancer lesions. The dataset has been randomly split into (train, validation, test) sets with proportions $(0.7, 0.15, 0.15)$ respectively.

The dataset provides pre- and post-contrast images, which were used as separate channels during training. Labels include at least one brain metastasis. @figsbmmetrics shows a sample of an image with the metastasis as colored instances and several statistical metrics. Most images contain fewer than 20 instances, though some images can contain more than 100 metastases. Morphologically the metastases manifest as relatively uniformly spherical lesions. An instance typically makes up only a small fraction of the voronoi region it gives rise to, likely due to the significant number of voxels that lie outside of the brain. Within images with multiple instances, a significant dominance can be found where the largest instance makes up a high proportion of the total foreground pixels.

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
        width: 60%
      )
    ),

    // Bottom row
    image("../figures/metrics/mets/instance_dominance.png", width: 50%),
    move(dy: -5pt,
    image("../figures/metrics/mets/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Visualizations of several aspects of the brain metastases dataset. Top left shows a sample image with three colored instances in diverse regions of the brain. The next graph shows a histogram of the number of instances per image with most images containing 10 or fewer metastases. 
  ],
) <figsbmmetrics>
=== White Matter Hyperintensities
The @wmh dataset @wmhdataset contains 170 MRI scans with labels indicating the presence of hyperintensities which manifest as especially morphologically diverse instances. @figwmhmetrics shows that images typically contain dozens to hundreds of white matter hyperintensitiy instances. Furthermore, while the average instance is only made up of a few voxels, a single connected component can also span up to 10,000 voxels. The fraction an instance makes up in the voronoi region it is in averages less than 1%. This can be explained similarly to the @mets dataset, since the vast amount of background voxels dominates the relativelyy few foreground voxels in a given region.


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
        width: 60%
      )
    ),

    // Bottom row
    image("../figures/metrics/wmh/instance_dominance.png", width: 50%),
    move(dy: -5pt,
    image("../figures/metrics/wmh/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Top left shows a sample MRI with highlighted and colored connected components of white matter hyperintensity labels.
  ],
) <figwmhmetrics>

=== Platelet Organelles
In the platelet organelles dataset @plateletdataset, @em was used to image multiple human blood platelet cells and expert labels were created indicating multiple types of organelles. Of particular interest to this work were the canalicular vessels and alpha granules as they are present in high numbers and varied shapes and sizes in each platelet cell.
The 72 individual 2D slices of shape (800*800) were extracted from the original .tiff files and split into (train, val, test) with proportions $(0.6, 0.2, 0.2)$ from each file. This served as a means to gather data more generalized data since intensities between scans can vary greatly.

Both @cv and @ag provide a diverse landscape of connected components. @figplateletcvmetrics and @figplateletagmetrics show dataset samples and statistics of these organelles respectively. Comparatively, alpha granule instances are much larger than canalicular vessels, though there are a lot fewer of them in the images. As a fraction of the containing voronoi fraction, they share a similar distribution, since on average both @cv and @ag instances make up $3-5%$ of the region they seeded.
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
        width: 65%
      )
    ),

    // Bottom row
    image("../figures/metrics/cv/instance_dominance.png", width: 50%),
    move(dy: -5pt,
    image("../figures/metrics/cv/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Instance statistics the canalicular vessel labels platelets showing a sample with overlayed connected components, the number of instances in each 800*800 image and their size distribution as well as the fraction of the foreground the largest instance takes up and the distribution of foreground fractions in their voronoi region.
  ],
) <figplateletcvmetrics>
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
        width: 65%
      )
    ),

    // Bottom row
    image("../figures/metrics/ag/instance_dominance.png", width: 50%),
    move(dy: -5pt,
    image("../figures/metrics/ag/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Instance statistics of the alpha granules dataset of human platelet cells showing a sample image with colored instance, the number of instances per image and their size distribution as well as the fraction of the foreground the largest instance takes up and the distribution of foreground fractions in their voronoi region.
  ],
) <figplateletagmetrics>

=== Mitochondria
The EPFL @mit dataset introduced by Lucchi et al. @epflmitochondria is another @em dataset that shows images taken from the hippocampus region of the brain with segmentations of mitochondrial organelles and serves as a common benchmark for certain segmentation tasks. 2D slices were again extracted from the 3D volume and used as independent image samples. The original dataset consists of two annotated volumes of $(1024*768*165)$. As recommended by the authors, one was used as the training volume, the other was split into the validation and test set. This results in a $(0.5, 0.25, 0.25)$ split.

@figepflmetrics shows dataset statistics on the 2D mitochondria dataset. 
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
        width: 60%
      )
    ),

    // Bottom row
    image("../figures/metrics/mit/instance_dominance.png", width: 50%),
    move(dy: -5pt,
    image("../figures/metrics/mit/voronoi_fraction.png", width: 50%)),
  ),
  caption: [Dataset statistics of mitochondria in brain neurons. Top left shows connected components on labels $Y$ as an overlay on a sample image. Top right shows a histogram of the number of instances per image. The center image shows the distribution of instance areas in pixels. Bottom left shows the fraction the largest instance contributes to the total number of foreground pixels. Bottom right is a violin plot displaying the fraction $frac(|I_k|,|R_k|-|I_k|)$ for each instance $I_k$ and region $R_k$.
  ],
) <figepflmetrics>

== Segmentation Evaluation Metrics <sec_metrics>
Many works have previously discussed the importance of the choice of metrics and the need to adapt to the specific task at hand, Maier et al. @maier2022metrics have provided concrete guidance in the choice of instance-wise metrics in segmentation problems and Kofler et al. @kofler2023panoptica provide a tool to calculate many of these metrics.

Additionally, Jaus et al. @jaus2025every proposed a family of metrics that are of particular interest to us since they use voronoi tesselation to aggregate metrics on each region separately and average them to identify learned instance imbalance during evaluation.

This section will provide a comprehensive overview of the metrics of interest, the rationales behind their choice and supplementary information on how predicted segmentations were evaluated.

=== Global Metrics
Global metrics operate simply on the label $Y$ and the prediction $hat(Y)$, they do not take instances or regions into account and are calculated solely on the number of pixels classified as @tp, @tn:short, @fp, @fn.

Two metrics often seen as complementary are precision and recall (which are also known as specificity and sensitivity respectively):
$
  "precision" = frac("TP","TP"+"FP")
$<eqprecision>
$
  "recall" = frac("TP","TP"+"FN")
$<eqrecall>

Many other measurements can be derived from precision and recall, one such metric has already been proposed in @eqDSC, but it can be generalized in the case of binary segmentation as the $F_beta$ metric where $beta$ is a non-negative scalar value acting as a weight:

$
  F_beta=frac((1+beta^2) * "TP",(1+beta^2) * "TP" + beta^2 * "FN" + "FP")
$

$F_1$ is equal to $"DSC"$ and while $beta=1$ is the most commonly chosen value in segmentation, considering alternative values for $beta$ is prudent in certain use cases. $F_1$ is also the harmonic mean between precision and recall, higher values for $beta$ place a higher relevance on recall, while lower ones prioritize precision.

$F_2$ therefore places a higher emphasis on the number of @tp and reduces the importance of @fp values, meaning it results in a higher score if a prediction identifies more positive pixels even if it produces an equal number of false positives. This can be considered as especially important in the high-stakes domain of medical imaging where finding segmentation pixels is often more important than predicting real negatives as positives.
=== Instance-wise Metrics
Instance-wise metrics are of particular interest to us since they give us a measure of how well a model performs at predicting each connected foreground component in the image. A lot of these metrics are formalized and implemented in tha Panoptica library described by Kofler et al. @kofler2023panoptica, which provides an algorithm that tries to match predicted instances to ground truth instances using an approximation algorithm: The predicted segmentation $hat(Y)$ is used in identifying connected components $hat(I)$. With the set of label instances $I$ and the predicted instances $hat(I)$, an overlap-based matching algorithm is performed. Once a match has been identified, metrics such as @rq or @sq can be calculated on the mapping of predicted to label components. Both of these metrics were introduced by Kirillov et al. @kirillov2019panoptic and @sq later extended into @sqassd in Panoptica.

#figure(
  grid(
    columns: 1,
    align: center + horizon,
    image("../figures/instance_matching.png", width: 80%),
  ),
  caption: [Pixel-wise notions of #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(0), stroke: 0.1pt)) TP, #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(1), stroke: 0.1pt)) FN,  #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(2), stroke: 0.1pt)) FP are extended to instances, with the left two instances being identified as TP instances ($"TP"_"inst"$), the top right being a false positive instance ($"FP"_"inst"$) as the model predicted a component not present in the label. The bottom right component is classified as an FN instance ($"FN"_"inst"$) due to the label showing a component without any overlapping prediction pixels.
  ],
) <figinstancematching>

Calculation of these measures is done by extending the notion of segmentaion error classification from pixels (as visualized in @figinstanceimbalance) to instances. A simplified overview of instance matching can be seen in @figinstancematching. Using this as a basis, @rq can be calculated analogously to @eqDSC, but considering only the instance error classifications:

$
  "RQ" = frac(2*"TP"_"inst",2*"TP"_"inst" + "FP"_"inst" + "FN"_"inst")
$<eqrecognitinquality>

Both precision precision (@eqprecision) and recall (@eqrecall) have similar instance-wise counterparts, with instance recall being of particular interest when considering multi-instance datasets in a medical setting. If all label components have a matching predicted component, the instance recall is $1$, if half of them have a matching prediction, the value drops to $0.5$. The label and prediction overlay in @figinstancematching would have an instance recall of $frac(2,3)$ due to 2 of the 3 label instances having matched counterparts.

This can be extended by calculating instance recall by volume. As stated previously in @instance_imbalance, lesion size often has no direct correlation with clinical relevance in many pathologies, but models tend to miss smaller instances and focus on larger ones @kofler2023blobloss @bouteille2025learning. As such, quantifying how well a model can spot instances with lower volume can be especially important when this small instance could be a malignant tumor. Therefore, previous works have proposed instance recall by volume, where all connected components are partitioned into e.g. quartiles based on their volume and $"recall"_"inst"$ is computed on them separately, resulting in $("recall"_"inst"_"Q1", "recall"_"inst"_"Q2", "recall"_"inst"_"Q3","recall"_"inst"_"Q4")$. This gives us a comparable measure how well small instances are recognized compared to larger ones.

@sqassd is a boundary based metric that calculates the average deviation of a prediction instance surface to its matched label surface. This means that the lower this metric is, the closer the prediction adheres to the label. Perfect predictions would naturally have an @sqassd of 0. 

@sqdsc is the last of the truly instance-wise metrics we considered and measures the @Dsc averaged over all $"TP"_"inst"$ instances. In the set of all matched instances $cal(I) = {(I_p, I_g) | I_p in hat(I), I_g in I}$ identified by the matching algorithm, @sqdsc can be calculated as:

$
  "SQDSC"(cal(I)) = frac(1,|"TP"_"inst"|)sum_((I_p, I_g) in cal(I))"DSC"(I_p, I_g)
$

Connected Component Dice Score is a metric introduced by Jaus et al. @jaus2025every that leverages voronoi regions $R$ computed on the labels $Y$ and seeded by the ground truth instances $I$. In an image, each voronoi region $R_k in R$ is considered separately by masking out everything outside the particular region, calculating the dice score ($F_1$) and averaging the scores across all regions:

$
  "CCDice"(Y, hat(Y)) = frac(sum_(k=1)^K F_1(Y inter R_k, hat(Y) inter R_k), K)
$

CCDice is of particular interest as a metric, as it incorporates the notion that all regions and their instances are equally important.

== Loss Formulations and Weighted Combination<sec_loss_functions_method>
This section provides a concrete formulation of the loss functions that were used and compared during the course of our experimentation, since there are many loss functions to choose from and the introduction of hyperparaters makes a complete comparrison untractable, we will limit ourselves to the most common losses in medical image segmentation.

$
  cal(L)_"Dice"=1-frac(2sum_(n=1)^N hat(y)_(n)y_n, sum_(n=1)^N (hat(y)_n^2+y_n^2))
$

$
  cal(L)_"BCE"=-sum_(n=1)^N (y_n log hat(y)_n+(1-y_n) log(1-hat(y)_n))
$

$cal(L)_"Dice"$ and $cal(L)_"BCE"$ are often combined into a compound loss function $cal(L)_"DiceCE"$ using individual weights $lambda_"Dice"$ and $lambda_"BCE"$ (though these are almost always set to $1$) in the formulation:

$
  cal(L)_"DiceCE"=lambda_"Dice"cal(L)_"Dice"+lambda_"BCE"cal(L)_"BCE"
$

This notion of component weighting is mirrored by the instance-aware losses discussed in @sec_instance_losses, where global and local components receive relative weights

$
  cal(L)_"Tversky" (alpha, beta)=1-frac(sum_(n=1)^N hat(y)_n y_n, sum_(n=1)^N hat(y)_n y_n + alpha sum_(i=1)^N hat(y)_i (1-y_n) + beta sum_(n=1)^N (1-hat(y)_n) y_n)
$
Tversky loss includes hyperparameters $alpha, beta$ that serve to control the punishment of pixels classified as @fp and @fn respectively @salehi2017tversky. The higher $alpha$, the more conservative the model's predictions, 

#todo(
  "Tested Losses, Global vs. Local splits and weight distribution and normalization as potential shortcombing of previous studies",
)

Why does everyone combine local and global losses?

=== Voronoi-based Region Wise Loss <voronoi_loss>
We define a voronoi-based loss similarly to CC-Loss introduced by Bouteille et al. @bouteille2025learning as the average 

$
  cal(L)_"CC" = alpha * cal(L)_"global" + beta * cal(L)_"region"
$

with the global loss, being an arbitrary loss function operating on the entire image, $cal(L)_"region"$

=== Weight Maps <sec_weight_maps_method>
Weight maps, as previously described in @sec_weight_maps_bg, provide a way to emphasize different aspects of the segmentation based on the ground truth labels, they can be precomputed and are therefore an efficient way to introduce assumptions and address computational biases.

This section provides several examples of novel weight maps calculated on voronoi regions. As a basis, the "none" weight map $W_"none"$ as the unit tensor can be seen as the normal case, assigning every pixel the same weight, therefore changing nothing in the final calculation when integrated into the loss function:
$
  W_"none" = {w_1, w_2, dots, w_N | w_n = 1}
$

A weight map can therefore be seen as the distribution of a total "budget" of $N$ with $W_"none"$ distributing this budget equally to every pixel.

Any of the subsequently introduced discussed weight maps can be easily incorporated into arbitrary loss functions. The loss functions discussed in @sec_loss_functions_method can be adapted into their weighted counterparts as follows with $w_n$ being the value of the weight map voxel at the same location as $y_n$ and $hat(y)_n$ in the label and prediction respectively:

$
  cal(L)_"Dice"_w=1-frac(2 sum_(n=1)^N w_n hat(y)_(n)y_n, sum_(n=1)^N w_n (hat(y)_n^2+y_n^2))
$

$
  cal(L)_"BCE"_w=-sum_(n=1)^(N) w_n (y_n log hat(y)_n+(1-y_n) log(1-hat(y)_n))
$

$
  cal(L)_"Tversky"_w (alpha, beta)=
  \
  1-frac(sum_(n=1)^N w_n hat(y)_n y_n, sum_(n=1)^N w_n hat(y)_n y_n + alpha sum_(n=1)^N w_n hat(y)_n (1-y_n) + beta sum_(n=1)^N w_n (1-hat(y)_n) y_n)
$

//==== Inverse Weighting
//Inverse weighting maps $W_"iw"$ were introduced by Shirokikh et al. @shirokikh2020universal and are designed to address the instance-imbalance problem by assigning a significantly higher weight to pixels belonging to a foreground instance. The background is treated as an additional instance $I_0$. Each pixel $w_n in W_"iw"$ is assigned a weight depending on the instance it is part of:

//$
//w_n = frac(N,(K + 1) abs(I_k)) quad quad  "if" y_n in {I_0, I_1, dots, I_K}
//$<eqiw>
//
//This has the effect that the background as well as foreground instances, which typically comprise a much smaller fraction of the label compared to the background, all receive the same "budget" that is distributed among all the pixels within the instances.

//The hypothesis behind this map is that the model is punished harshly for missing foreground pixels, even more so if they belong to small instances. @figiwmap shows an example of a $W_"iw"$ map in 2D as an overlay on the accompanying image.

//#figure(
//  grid(
//    align: center + horizon,
//    column-gutter: 0mm,
//    image("../figures/weight_maps/iw.png", width: 70%),
//  ),
//  caption: [A sample of an $W_"iw"$ weight map. All instances including the background receive the same portion of the total weight, with smaller instances therefore having a higher pixel-wise weight.
//  ],
//) <figiwmap>
==== Equal Region Weights
The equal region weights map $W_"v_region"$ is a naive way to equalize the weights around all instances, not just in the foreground pixels $I_k$, but also in the background pixels that belong to the same voronoi region $R_k$.

$
w_n = frac(N,K|R_k|) quad quad  "if" y_n in R_k
$<eqvregion>

 @figvregionmap shows the weight map calculated on the sample image. The tessellation into voronoi regions is apparent and regions with fewer pixels receive a higher pixel-wise weight. The idea behind this map is that all regions and therefore all instances within them are equalized in importance by dividing the budget of $N$ among all regions.

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_region.png", width: 70%),
  ),
  caption: [A sample of the $W_"v_region"$ weight map. The total available budget $N$ is divided by the number of regions $K$. Each region receives this $frac(N,K)$ budget to distribute equally within it. This results in a higher weight for pixels in smaller regions.
  ],
) <figvregionmap>

==== Voronoi Inverse Weighting
Voronoi inverse weighting maps $W_"v_iw"$ aim to combine the concept of inverse weighting introduced by Shirokikh et al. @shirokikh2020universal with voronoi regions, assigning all regions equal budget and within them, dividing that budget equally between the background and foreground pixels:

$
w_n = cases(
  frac(N,2K|R_k|-|I_k|) quad quad  "if" y_n in R_k and y_n = 0, 
  frac(N,2K|I_k|) quad quad  quad quad  "if" y_n in R_k and y_n = 1
)
$<eqviw>

@figviwmap demonstrates an example $W_"v_iw"$ map, even though the entire budget is split equally among regions, the voronoi regions are not as apparent as in @figvregionmap, this is due to the much higher weight foground instances receive, making the background across regions close, but not equal.

This aims to be a less aggressive and more equalized approach than @iw and although the two maps are mathematically equal if an image contains only a single instance, it inhibits very small connected components and possible single-pixel annotation errors from dominating the weights since they are always bound by the equalized region budget.

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_iw.png", width: 70%),
  ),
  caption: [A sample of the $W_"v_iw"$ weight map. Like in $W_"v_region"$, every voronoi region receives the same share of the budget, however within a region, the region budget $frac(N,K)$ is split equally among the background and foreground, with the foreground typically having a smaller volume, resulting in higher pixel-wise weight.
  ],
) <figviwmap>

==== Voronoi Mountains
$
w_n = cases(
  dots quad quad  "if" y_n in R_k and y_n = 0, 
  dots  quad quad  "if" y_n in R_k and y_n = 1
)
$<eqvmountains>

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_mountains.png", width: 70%),
  ),
  caption: [$W_"v_mountains"$ sample showing a radiating effect around the foreground instances. The highest weight within a region is typically inside the instance, decaying around its borders, this can be intuitively visualized topographically and takes on a shape akin to a mountain range.
  ],
) <figvmountainsmap>
#todo("Formula, hypothesis, figure")

==== Voronoi Islands
$
w_n = cases(
  dots quad quad  "if" y_n in R_k and y_n = 0, 
  dots  quad quad  "if" y_n in R_k and y_n = 1
)
$<eqvislands>

#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/weight_maps/v_islands.png", width: 70%),
  ),
  caption: [A sample of $W_"v_islands"$ as opposed to $W_"v_mountains"$ decreases weight values close to instance borders, increasing weight exponentially with distance from the foreground.
  ],
) <figvislandsmap>
#todo("Formula, hypothesis, figure")
==== Adaptive Voronoi Weighting
Adaptive weighting is a novel voronoi-based weight concept that can not be precomputed, but is computed on-the-fly based on model behaviour and predictions. Before loss values are calculated, if a region with a visible instance contains at least 1 @tp, it is deemed as recognized, with each pixel receiving a weight of 1, if foreground pixels are visible, but no @tp was predicted, the region's pixels receive a weight of $4$ (a predetermined hyperparameter). This makes regions where the model failed to find the foreground times more important. After this is calculated for all regions in the map, it is scaled to keep the unit weight constraint.

Let $R_k$ be the voronoi region that 
$
w_n = cases(
  1 quad quad  "if" y_n in R_k and hat(y)_n = 0, 
  4 quad quad  "if" y_n in R_k and hat(y)_n = 1
)
$<eqvadaptive>

#todo("Formula, hypothesis, figure")

== Model Architecture<sec_modelarchitecture>
This section describes the technical setup used in the construction of the training pipeline and the architecture of the adaptive neural network used in experiments.
=== Adaptive U-Net
The model architecture used in all experiments is based on the UNet architecture introduced by Ronneberger et al. @ronneberger2015u specifically for the use in biomedical image segmentation. The implementation from MONAI @cardoso2022monai was parametrized based on the dataset to change the spatial dimenstion (2D vs. 3D) and the nuber of input channels available.

=== Precomputation and Image Patching<sec_precomputation_and_patching>
Since the label files used in loss calculations are static and do not change, efficient precomputation of the connected components, their voronoi regions and any arbitrary weight map significantly speeds up training. @figprecomputation shows the construction of all precomputed information available during training.


#figure(
  grid(
    align: center + horizon,
    column-gutter: 0mm,
    image("../figures/precomputation.png", width: 90%),
  ),
  caption: [Demonstration of the preprocessing pipeline. Labels from the dataset are used for computation of instances, voronoi maps and weight maps and then combined with the accompanying image through a patching process. This results in the total batch information available during training.],
) <figprecomputation>

The introduction of image patching, a common method in segmentation to divide individual samples into many into smaller regions of interest, makes precomputation necessary, since calculation of these tensors on-the-fly can introduce several artifacts that do not represent the original data#footnote([An example of such an artifact could be an instance that is split into on the edges of the patch, resulting in two voronoi regions from the same component.]). Image patching extracts multiple sub-images from a larger original sample, diversifying training data when combined with augmentations.

@tabpatching shows the patching parameters used for the training on the different datasets. The overall patching algorithm is based on a positive and negative label approach implemented in MONAI @cardoso2022monai, in which the patch location is randomly centered on foreground or background pixels with a ratio of 2:1. When a patching location has been chosen, the sub-image is cropped from all accompanying precomputed weight maps at the same location.
#figure(
table(
  columns: (auto, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Dataset*], [*Source Image Size*], [*Patch RoI*], [*Number of Patches*],
  ),
  [@cv],
  [$(800,800)$],
  [$(288, 288)$],
  [25],
  [@ag],
  [$(800,800)$],
  [$(288, 288)$],
  [25],
  [@mit],
  [$(1024,768)$],
  [$(512, 512)$],
  [16],
  [@mets],
  [$(256,256,150)$],
  [$(96,96,64)$],
  [20],
  [@wmh],
  [$~(240,240,48)$],
  [$(64,64,48)$],
  [16],
),
  caption: [An overview of the different patching strategies used per dataset. With the source image size as well as the size and number of extracted patches. The @wmh dataset is the only dataset with slightly inconsistent source image dimensions.
  ],
)<tabpatching>

This can lead to artifacts in train patches that are devoid of instances, but are still tesselated as a region and therefore punish FPs more harshly than in LTLC.
#todo(
  "Relatively metrics-agnostic implementation: No checkpointing, training to completion, mirror sentiment from nnUNet",
)

== Experimental Setup<sec_experimentalsetup>
