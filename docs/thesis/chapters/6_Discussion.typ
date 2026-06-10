#import "../utils.typ": *

= Discussion <chap_discussion>
This chapter analyzes the results presented in @chap_results and provides interpretations of our approaches to improving multi-instance semantic segmentation. We take a holistic look at several criteria that go beyond interpreting single metrics, analyzing their implications as well as potential methodological shortcomings and possible improvements.

== Loss Combinations<sec_losscombos_discussion>
The increase in training time of region-wise models presented in @figtimeperepoch shows that region-wise losses incur a sometimes significant overhead as in the case of @wmh, this must be weighed against the presented benefits in segmentation performance.

The results presented in @sec_losscombos_results show several significant improvements over the current standard of a global-only DiceCE loss function in multi-instance segmentation datasets. Notably, on the @mets dataset, only instance precision dropped with none of the other presented metrics including @rq:long decreasing when a model was trained with both a global and region-wise loss, showing that the introduction of such a loss component offers a way to increase #todo("Which metrics to mention here") segmentation metrics at the cost of computational complexity.

The introduction of region-wise losses to a segmentation network shows increased detection performance across five diverse multi-instance datasets and tasks.

Particularly @figmetsrecallbyquartile and @figwmhrecallbyquartile show that region-wise losses improve recall especially of smaller instances that the baseline loss misses more often.

2D datasets were improved marginally, but consistently in many metrics with the Voronoi loss paradigm, with @cv segmentation taking only minimal reduction in instance recall while improving all other metrics. The small reduction in instance recall in canalicular vessels stands out as this metric generally improves across all other datasets. This, together with the already high baseline instance recall, points to the small variations being noise.

The consistent gains across various loss combinations indate the main driver of improvements is the incorporation of region-wise losses into the training pipeline rather than the exact loss formulation.

== Weight Maps<sec_weightmaps_discussion>

The presented results for @mets show that the weight map $"W"_"v_iw"$ increases instance recall drastically, while at the same time decreasing @rq, since this metric is computed using both $"recall"_"inst"$ and $"precision"_"inst"$, it points towards a stark decrease in instance precision and a stark increase in $"FP"_"inst"$. @figsbmviwsample shows one test case as predicted by a model trained with $"W"_"v_iw"$. While the predictions are clustered more closely around the label instance, showing some learned behaviour, the clear overprediction implies that the model failed to make relevant connections about this dataset and goes beyond any clinical usability. 

Even though the weight map has similar effect on @wmh, increasing instance recall while reducing @rq, it is much less pronounced. This can be explained by the higher number of instances per sample in the dataset since they act as a regularization, distributing the large weight budget of 3D images across more Voronoi regions.

#figure(
  image("../figures/results/mets/qualitative_viw/sbmsampleviw.png", width: 100%),

  caption: [Slices of a prediction output of a model trained with $"W"_"v_iw"$ on a test image of the brain metastases dataset. An annotated metastasis is shown in white with prediction shown in red.
  ],
) <figsbmviwsample>

While the benefit of $"W"_"v_region"$ on @wmh segmentation is questionable due to a similar effect, reducing @rq while increasing instance recall, the effect is much less severe, even increasing the region-wise dice. This can be explained by be number of instances per image in both datasets. Since most @mets samples contain relatively few instances compared to @wmh, the weights an individual instance receives is much higher, which leads to almost no punishment of false positives.

Another important point of discussion is the impact $"W"_"v_mountains"$ has on the segmentation performance of the 3D datsets, since it drastically improves most key metrics in @wmh, but it fails to reliably generalize to @mets, reducing the @rq drastically, in part likely due to a difference in the instance distribution and morphology between the pathologies.

Overall, weight maps appear to be highly dataset-dependent, resulting in scattered improvements without a unifying pattern making them sensitive to instance morphology and less robust than region-wise losses as a generalizable strategy.

== General Observations<sec_general_discussion>
#todo([Reference qualitative Mets sample with Hendrik comment: put this statement as objective observation (example shows more FPs) into the result section as well, but then leave it phrased similarly to this in the discussion])

#todo([Hendrik Comment: need a reference for that. do Bouteille et al.  state this? - What does he mean, I think they they do. Generally, how do I cite this if I compare it repeatedly?])
The relatively low baseline on 3D datasets compared to other works shows that our network is not entirely optimized for all use-cases with nnU-Net achieving higher baselines. The Voronoi-based nnU-Net modification proposed by Bouteille et al. @bouteille2025learning, for instance, presents higher baseline values. It is, however, unable to precompute Voronoi regions, instead computing the masks on-the-fly on sub-patches of the image. This fundamentally distorts the global spatial context and sets arbitrary tessellation boundaries. And while the use of nnU-Net achieves higher baseline performance across both @wmh and @mets, it also leads to overfitting @bouteille2025learning. Additionally, nnU-Net computes metrics on the average validation performance across multiple folds and while this is a sound approach, it results in an increase in training samples due to the lack of a test set.

Importantly, the authors of nnU-Net make a case against the use of customized U-Net implementations to claim algorithmic innovation and provide reasoning why the standardized, self-configuring framework is still the state-of-the-art @isensee2024nnu. While we go against this recommendation by developing a custom pipeline, we incorporated the concrete recommendations presented in their work to provide a fair comparison and validation of our methodology.