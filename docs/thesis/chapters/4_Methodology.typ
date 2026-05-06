#import "../utils.typ": todo
#import "@preview/glossarium:0.5.9": gls

= Methodology <chapter_methodology>
This section will devote itself to outlining the structure of the implementation of the thesis, the datasets used as well as some notions on their fidelity and subsequent consequences. It will also cover the details of the neural network architecture used and outlines of experiments that were run.

== Datasets <datasets>
The practical implementation of this thesis was evaluated against multiple datasets that span dimensionality (2D as well as 3D), modality (MRIs, electron microscopy) and various inherent anatmoical features and pathologies that result in varied segmentation instance properties.

Due to the diverse nature of the underlying data, it was imperative to gather dataset metrics that encapsulate these varied instance properties not only to properly evaluate our fundamental hypotheses, but also to deal with noise and errors during training. In order to investigate why certain approaches worked better than others, concrete information on the size, morphology, distribution, and number of instances must be reported and taken into consideration before conclusions can be drawn. This subsection contains a description of the datasets used, their properties and calculated metrics as well as a comprehensive overview on the estimation of their fidelity that could serve as a basis for future research in multi-instance segmentation.

=== Metrics and Fidelity of Multi-Instance Segmantation Datasets <dataset_fidelity>
Since this thesis concerns itself with bianry semantic segmentation, all datasets can be abstracted into their constituent components as follows:
An image of shape $h*w$ ($h*w*d$ in the case of 3D) and a binarized label file of the same shape as its corresponding image. The label file is therefore partitioned into background pixels/voxels and $n gt.eq 0$ foreground pixels/voxels. The $n$ foreground pixels/voxels then undergo a process of labeling based on their local neighborhood, in which they are split into $m gt.eq 0$ foreground instances (typically $n gt.double m$). In 2D, this is based on 8-connectivity while 3D instances are labeled using the higher-dimensional equivalent of 26-connectivity.

The resulting instances have inherent properties that are important to examine both when formulating hypotheses as well as investigating noise and segmentation errors. As these properties are of such importance, prior works in the fields of #gls("miqa") and #gls("tda") have provided comprehensive frameworks for identifying the properties of segmentation data and how these impact performance reporting @kofler2023panoptica @maier2022metrics. While these works place substantial focus on the selection and calculation of quantitative segmentation metrics, this section provides a more holistic interpretation of multi-instance dataset attributes that shall aid in the interpretation of results.

#todo("Description of removal of small annotation errors and what theoretical effects these instances would have and a link to the evaluation of intact vs cleaned datasets")

=== Brain Metastases
The Stanford brainmetshare dataset @brainmetshare consists of 105 labeled MRI scans with multiple co-registered channels of the human head, with binary labels indicating metastatic cancer lesions. The dataset has been split into (train, validation, test) sets with proportions $(0.7, 0.15, 0.15)$.

#todo("Split description, instance distribution, sizes and variance, etc.")
=== White Matter Hyperintensities
The @wmh dataset @wmhdataset contains 170 MRI scans with labels indicating the presence of @wmh:pl which manifest as especially morphologically diverse instances.

#todo("Split description, instance distribution, sizes and variance, etc.")
=== Platelet Organelles
In the platelet organelles dataset @plateletdataset, @em was used to image multiple human blood platelet cells and expert labels were created indicating multiple types of organelles. Of particular interest to this work were the canalicular vessels and alpha granules as they are present in high numbers and varied shapes and sizes in each platelet cell.
The 72 individual 2D slices were extracted from the original .tiff files and split into (train, val, test) with proportions $(0.6, 0.2, 0.2)$ from each file. This served as a means to gather data more generalized data since intensities between scans can vary greatly.

#todo("Split description, instance distribution, sizes and variance, etc.")
=== Mitochondria
The EPFL mitochondria dataset introduced by Lucchi et al. @epflmitochondria is another @em dataset that shows images taken from the hippocampus region of the brain with segmentations of mitochondrial organelles and serves as a common benchmark for certain segmentation tasks. 2D slices were again extracted from the 3D volume and used as independent image samples.

#todo("Split description, instance distribution, sizes and variance, etc.")

== Segmentation Evaluation Metrics
Many works have previously discussed the importance of the choice of metrics and the need to adapt to the specific task at hand, @maier2022metrics have provided concrete guidance in the choice of instance-wise metrics in segmentation problems and @kofler2023panoptica provide a tool to calculate these metrics.

Additionally, @jaus2025every proposed a family of metrics that are of particular interest to us since they also use voronoi tesselation and aggregate metrics on each region separately to address instance volume imbalance during evaluation.

This subsection will provide a comprehensive overview of the metrics of interest, the rationales behind this choice and supplementary information on how predicted segmentations were evaluated.

#todo("Relatively metrics-agnostic implementation: No checkpointing, training to completion, mirror sentiment from nnUNet")
=== Global Metrics
Standard Dice, F2
=== Instance-wise Metrics
Instance-wise metrics are of particular interest to us since they give us a measure of how well a model performs on each instance in the image. A lot of these metrics are implemented in @kofler2023panoptica which tries to match predicted instances to ground truth instances using an approximation algorithm. Once a matching instance has been identified, metrics such as @assd or @cedi can be calculated and are averaged over the image.

Instance F1, Instance Dice, CCDice, Instance Recall by volume

== Loss Formulation and Weighted Combination
#todo("Tested Losses, Global vs. Local splits and weight distribution and normalization as potential shortcombing of previous studies")
Why does everyone combine local and global losses?
Why didn't anyone account for potential absolute value inconsistency when doing so?
== Weight Maps
#todo("A description and formulation of tested weight maps and their impact on segmentation results")
A special note of instance cleaning and weight maps
inverse weighting as previously implemented.
Voronoi-based maps as novel and precomputed due to image patching

== Model Architecture
=== Adaptive U-Net
#todo("A description of a somewhat adaptive UNet that can handle 2D and 3D data")
=== Precomputation and Image Patching
#todo("Instance information, voronoi maps, and weight maps can be precomputed and patched alongside images and labels.")
This can lead to artifacts in train patches that are devoid of instances, but are still tesselated as a region and therefore punish FPs more harshly than in LTLC.

== Experimental Setup