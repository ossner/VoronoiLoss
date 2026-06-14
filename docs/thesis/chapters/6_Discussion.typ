#import "../utils.typ": *

= Discussion <chap_discussion>
This chapter analyzes the results presented in @chap_results and provides interpretations of our approaches to improving multi-instance semantic segmentation. We take a holistic look at several criteria that go beyond interpreting single metrics, analyzing their implications as well as potential methodological shortcomings and possible improvements.

== Loss Combinations<sec_losscombos_discussion>
In general, the introduction of region-wise losses to a segmentation network shows increased detection performance across all five diverse multi-instance datasets and tasks. The increase in training time of region-wise models presented in @figtimeperepoch shows that region-wise losses incur a sometimes significant overhead as in the case of @wmh, this must be weighed against the observed segmentation improvements.

The results presented in @sec_losscombos_results show several significant improvements over the current standard of a global-only DiceCE loss function. Notably, on the @mets dataset, only instance precision dropped with none of the other presented metrics including @rq:long decreasing when a model was trained with both a global and region-wise loss, showing that the introduction of such a loss component offers a way to increase global and instance-wise segmentation metrics at the cost of computational complexity.

The qualitative comparison between purely global and purely local DiceCE in @figsbmgloballocal shows that forcing the loss function to compute gradients over all local Voronoi regions rather than the global volume makes the model more sensitive, identifying otherwise missed instances but leading to false positives.

Particularly @figmetsrecallbyquartile and @figmetsresultslollipopsqdsc show the impact region-wise losses have on the detection and segmentation of tumors based on their volume. While there are stark improvements in the medium quartiles, the models still struggle to identify and segment the smallest instances below 13 voxels in size. This indicates that, while the distribution of model attention across regions aids both instance recall and @sqdsc in quartiles that the baseline struggles to segment reliably, tiny instances are sometimes still hard to segment.

In @figwmhrecallbyquartile the large gap between the baseline recall of @wmh instances in Q3 and Q4 can be explained by the volumetric values of the respective quartiles. Since the lower volumetric quartiles Q1 to Q3 are given by $[3,5,13]$voxels in size and the largest hyperintensities can reach over 10,000 voxels, the range of sizes in top 25% of instances is significant.

2D datasets were improved marginally, but consistently in many metrics with the Voronoi loss paradigm, with @cv segmentation taking only minimal reduction in instance recall while improving all other metrics. The small reduction in instance recall in canalicular vessels stands out as this metric generally improves across all other datasets. This, together with the already high baseline instance recall, points to the small variations being noise.

The consistent gains across various loss combinations indicate the main driver of improvements is the incorporation of region-wise losses into the training pipeline rather than the exact loss formulation. Although scaling the relative importance in a combined formulation like (2*DiceCE, DiceCE) results in the best segmentation of @wmh instances based on the analyzed metrics, the best segmentation of @mets was achieved through equal global- and region-wise weights.

== Weight Maps<sec_weightmaps_discussion>

The presented results for @mets show that the region-wise inverse weighted map $W_"v_iw"$ increases instance recall drastically, while at the same time decreasing @rq. Since @rq is computed using both $"recall"_"inst"$ and $"precision"_"inst"$, it points toward a stark decrease in instance precision and a stark increase in $"FP"_"inst"$. @figsbmviwsample shows one test case as predicted by a model trained with $W_"v_iw"$. While the predictions are clustered more closely around the single label label instance in the image, showing some learned behaviour, the clear overprediction implies that the model failed to make relevant connections about this dataset and renders the model clinically unusable. 

Even though the weight map has similar effect on @wmh, increasing instance recall while reducing @rq, it is much less pronounced. This can be explained by the higher number of instances per sample in the dataset since they act as a regularization, distributing the large weight budget of 3D images across more Voronoi regions.

#figure(
  image("../figures/results/mets/qualitative_viw/sbmsampleviw.jpeg", width: 100%),

  caption: [Slices of a prediction output of a model trained with $W_"v_iw"$ on a test image of the brain metastases dataset. @tp:long voxels in the prediction are marked in green #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(0), stroke: 0.1pt)), @fp:long voxels in red #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(2), stroke: 0.1pt)) and @fn:long voxels in blue #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(1), stroke: 0.1pt)).
  ],
) <figsbmviwsample>

While the benefit of $W_"v_iw"$ on @wmh segmentation is questionable due to a similar effect, reducing @rq while increasing instance recall, the effect is less severe, even increasing the region-wise dice. This can be explained by the number of instances per image in both datasets. Since most @mets samples contain relatively few instances compared to @wmh, the weights an individual instance receives is much higher, which leads to almost no punishment of false positives.

Another important point of discussion is the impact $W_"v_mountains"$ has on the segmentation performance of the 3D datasets, since it drastically improves most key metrics in @wmh, but it fails to reliably generalize to @mets, reducing the @rq severely, in part likely due to a difference in the instance distribution and morphology among the pathologies. 

Overall, weight maps appear to be highly dataset-dependent, resulting in scattered improvements without a unifying pattern making them sensitive to instance morphology and less robust than region-wise losses as a generalizable strategy. While they often did modify loss behaviour in the generally intended direction, with $W_"v_iw"$ generally increasing instance recall and $W_"v_mountains"$ improving border segmentation quality in many cases. These results were not consistent due to the highly diverse nature of the tested multi-instance datasets.

The inconsistency of weight maps has been shown in other works. And while Shirokikh et al. @shirokikh2020universal propose inverse weighting with positive results, later studies have noted that this weight map is also unable to improve multi-instance segmentation reliably @rachmadi2024family @kofler2023blobloss.

== Limitations<sec_limitations>
The relatively low baseline on 3D datasets compared to other works reflects the architectural trade-off made in favor of experimental flexibility over maximized baseline performance, with nnU-Net achieving higher baselines. The Voronoi-based nnU-Net modification proposed by Bouteille et al. @bouteille2026learning, for instance, presents higher baseline values. It is, however, unable to precompute Voronoi regions, instead computing the masks on-the-fly on sub-patches of the image. This fundamentally distorts the global spatial context and sets arbitrary tessellation boundaries. Additionally, while nnU-Net achieves higher baseline performance across both @wmh and @mets, it also leads to overfitting @bouteille2026learning. 

Although the nnU-Net framework operates on image sub-patches like our training pipeline, a precomputation of full-volume Voronoi masks, weight maps, and the changes this requires in the framework introduced an architectural barrier hindering flexible experimentation. Importantly, the authors of nnU-Net make a case against the use of customized U-Net implementations to claim algorithmic innovation and provide reasoning why the standardized, self-configuring framework is still the state-of-the-art @isensee2024nnu. While we deviate from this sentiment by developing a custom pipeline, we incorporated the concrete recommendations presented in their work to ensure our implementation reflects established best practices.

We further acknowledge the lack of an exhaustive search of several hyperparameters including the region-scaling penalty parameter $beta$ in $W_"v_adaptive"$ across all datasets. $beta=4$ was chosen based on limited experimentation as an exploration of the concept of adaptive weighting.