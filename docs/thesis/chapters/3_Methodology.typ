#import "../utils.typ": todo
= Methodology <chapter_methodology>
== Metrics and Fidelity of Multi-Instance Segmantation Datasets <dataset_fidelity>
The theoretical basis of this thesis was evaluated against multiple datasets that span dimensionality (2D as well as 3D), modality (CTs, electron microscopy) and various inherent anatmoical features and pathologies that result in varied segmentation instance properties. 

Due to the diverse nature of the underlying data, it was imperative to gather dataset metrics that encapsulate these varied instance properties not only to properly evaluate our fundamental hypotheses, but also to deal with noise and errors during training. In order to investigate why certain approaches worked better than others, concrete information on the size, morphology, distribution, and number of instances must be reported and taken into consideration before conclusions can be drawn. This subsection contains a description of the datasets used, their properties and calculated metrics as well as a comprehensive overview on the estimation of their fidelity that could serve as a basis for future research in multi-instance segmentation.

Since this thesis concerns itself with bianry semantic segmentation, all datasets can be abstracted into their constituend components as follows:
An image of shape $h*w$ ($h*w*d$ in the case of 3D) and a binarized label file of the same shape as its corresponding image. The label file is therefore partitioned into background pixels/voxels and $n gt.eq 0$ foreground pixels/voxels. The $n$ foreground pixels/voxels then undergo a process of labeling based on their local neighborhood, in which they are split into $m gt.eq 0$ foreground instances (typically $n gt.double m$). In 2D, this is based on 8-connectivity while 3D instances are labeled using the higher-dimensional equivalent of 26-connectivity.

The resulting instances have inherent properties that are important to examine both when formulating hypotheses as well as investigating noise and segmentation errors. As these properties are of such importance, prior works in the fields of @miqa and @tda have provided comprehensive frameworks for identifying the properties of segmentation data and how these impact performance reporting @kofler2023panoptica @maier2022metrics. While these works place substantial focus on the selection and calculation of quantitative segmentation metrics, this section provides a more holistic interpretation of multi-instance dataset attributes that shall aid in the interpretation of results.

== Segmentation Evaluation Metrics
Many works have previously discussed the importance of the choice of metrics and the need to adapt to the specific task at hand, @maier2022metrics have provided concrete guidance in the choice of instance-wise metrics in segmentation problems and @kofler2023panoptica provide a tool to calculate these metrics.

Additionally, @jaus2025every proposed an additional family of metrics that are of particular interest to us since they also use voronoi tesselation and aggregate metrics on each region separately to address instance volume imbalance during evaluation.

This subsection will provide a comprehensive overview of the metrics of interest, the rationales behind this choice and supplementary information on how predicted segmentations were evaluated.

