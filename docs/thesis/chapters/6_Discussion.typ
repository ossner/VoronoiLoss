#import "../utils.typ": *

= Discussion <chap_discussion>
This chapter analyzes the results presented in @chap_results and provides interpretations of our approaches to improving multi-instance semantic segmentation. We take a hollistic look at several criteria that go beyond interpreting single metrics, analyzing their implications as well as potential methodological shortcomings and possible improvements.

== Loss Combinations<sec_losscombos_discussion>
The results presented in @sec_losscombos_results show several significant improvements over the current standard of a global-only DiceCE loss function in multi-instance segmentation datasets. Notably, on the @mets dataset, none of the presented metrics decreased in the 

In high-stakes applications it is hard to argue against the benefit of manageable overprediction and additional false positive instances when these can be dismissed quickly if it carries with it an increase of true positive detection and instance recall. We believe that the results for region-wise losses show that their introduction to a segmentation network results in increased detection performance across the board. @figsbmgloballocal depicts a qualitative evaluation sample from both the (DiceCE, none) and (none, DiceCE) combinations. The label contains 13 metastases with the global DiceCE identifying 6 as true positive instances and no $"FP""_inst"$. The Voronoi-region-wise DiceCE, however, found 11 label instances, predicting 5 false instances. This shows that forcing the loss function to compute gradients over local Voronoi regions rather than the global volume makes the model more sensitive, leading to false positives.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    image("../figures/results/mets/qualitativegloballocal/110000.png", width: 80%),
    image("../figures/results/mets/qualitativegloballocal/000110.png", width: 80%),
  ),
  caption: [Two test samples of the @mets dataset with an instance-based evaluation overlay. Left shows the prediction of global-only DiceCE, right shows the region-only DiceCE. #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(0), stroke: 0.1pt)) $"TP"_"inst"$ instances taken from the label are shown in green if the prediction overlaps on at least 1 voxel, #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(2), stroke: 0.1pt)) $"FP"_"inst"$ and #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(1), stroke: 0.1pt)) $"FN"_"inst"$ instances are taken from the prediction and label respectively if they do not overlap.
  ],
) <figsbmgloballocal>

2D datasets were improved marginally, but consistently in many metrics with the Voronoi loss paradigm, with @cv segmentation taking only minimal reduction in instance recall while improving all other metrics. The small reduction in instance recall in canalicular vessels stands out as this metric generally improves across all other datasets. This, together with the already high baseline instance recall, points to the small variations being noise.

== Weight Maps<sec_weightmaps_discussion>

The presented results for @mets show that the weight map $"W"_"v_iw"$ increases instance recall drastically, while at the same time decreasing @rq, since this metric is computed using both $"recall"_"inst"$ and $"precision"_"inst"$, it points towards a stark decrease in instance precision and a stark increase in $"FP"_"inst"$. @figsbmviwsample shows one test case as predicted by a model trained with $"W"_"v_iw"$. While the predictions are clustered more closely around the label instance, showing some learned behaviour, the clear overprediction implies that the model failed to learn relevant information about this dataset. 

#figure(
  image("../figures/results/mets/qualitative_viw/sbmsampleviw.png", width: 100%),

  caption: [Slices of a prediction output of a model trained with $"W"_"v_iw"$ on a test image of the brain metastases dataset. An annotated metastasis is shown in white with prediction shown in red.
  ],
) <figsbmviwsample>

While $"W"_"v_region"$'s benefit on @wmh segmentation is questionable due to a similar effect, reducing @rq while increasing intsance recall, the effect is much less severe, even increasing the region-wise dice. This can be explained by be number of instances per image in both datasets. Since most @mets samples contain relatively few instances compared to @wmh, the weights an individual instance receives is much higher, which leads to almost no punishment of false positives.

Another important point of discussion is the impact $"W"_"v_mountains"$ has on the segmentation performance of the 3D datsets, since it drastically improves most key metrics in @wmh, but it fails to reliably generalize to @mets, reducing the @rq drastically, in part likely due to a difference in the instance distribution and morphology between the pathologies.

== General Observations<sec_general_discussion>

The relatively low baseline on 3D datasets compared to other works shows that our network is not entirely optimized for all use-cases with nnU-Net achieving higher baselines. The Voronoi-based nnU-Net modification proposed by Bouteille et al. @bouteille2025learning, however, is unable to precompute Voronoi regions, instead computing the masks on-the-fly on sub-patches of the image. This fundamentally distorts the global spatial context and sets arbitrary tessellation boundaries. And while using nnU-Net results in a higher baseline performance across both @wmh and @mets, it also leads to overfitting. Additionally, nnU-Net computes metrics on the average validation performance across multiple folds and while this is a sound approach, it results in an increase in training samples due to the lack of a test set.

Crucially, the authors of nnU-Net make a case against the use of customized U-Net implementations to claim algorithmic innovation and provide reasoning why the standardized, self-configuring framework is still the state-of-the-art @isensee2024nnu. While we go against this recommendation by developing a custom pipeline, we incorporated the concrete recommendations presented in their work to provide a fair comparison and validation of our methodology.