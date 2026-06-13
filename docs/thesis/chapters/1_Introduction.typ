#import "../utils.typ": todo

= Introduction <chapter_introduction>

The use of @ai in the medical domain has been one of the most research-intensive areas of the last decade, sparking substantial advancements in the field of healthcare. In particular, medical image analysis has crystallized as a field where the introduction of machine learning shows considerable promise of increasing the standard of care provided to patients while reducing the burden on clinicians. In this discipline, automated identification of abnormalities or pathologies in diverse medical images helps clinicians plan treatments and guide decision making.

Several such pathologies manifest as a collection of spatially separated, morphologically diverse objects, such as tumor metastases or multiple sclerosis brain lesions. The robust and accurate detection of these individual instances is an ongoing challenge in medical image segmentation, a discipline in which neural networks are tasked with identifying and delineating objects of importance in images.

These networks learn to identify diverse patterns between an image and an expert's manual annotation of regions of interest. In binary semantic segmentation, each pixel or voxel is assigned to either foreground or background classes, allowing for the distinction of healthy and pathological tissue. Particularly in medical segmentation tasks, reliable and accurate performance of the network across multiple measures, including the detection and delineation of small and morphologically diverse instances, is required.

Due to the complex optimization dynamics of the neural network learning process, however, unintended inductive biases can be seen in model behaviour. One such bias is the established prioritization that state-of-the-art segmentation algorithms show towards larger individual objects, which can lead to systematic underperformance on the identification of smaller objects @kofler2023blobloss @jaus2025every @rachmadi2024family @rachmadi2024iciloss.

This is a crucial issue in medical image segmentation where smaller tumors can carry the same clinical relevance as larger ones and are critical clues that point clinicians toward early-stage cancer development or metastasization. This problem of a biased performance has attracted several recent studies on possible improvements of segmentation networks.

This thesis presents an investigation of several methods based on Voronoi tessellation to address the issue of size-based biases in the learning process of segmentation networks. In particular, we examine the effect of region-wise loss functions similar to the paradigm proposed by @bouteille2026learning as well as several region-based weight maps as efficient ways to introduce a manual bias into the network in order to steer learning behaviour.

We evaluate our hypotheses across various datasets spanning dimensionality as well as imaging modality and biological scale.