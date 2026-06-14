#import "../utils.typ": *
#import "../figures/results/combinedtableloss.typ": importantresults-table_loss_combos
#import "../figures/results/combinedtableweights.typ": importantresults-table_weight_maps
#import "../figures/results/combinedtableloss_quartiles_3D.typ": importantresults-table_loss_combos_quartiles_3D

= Results <chap_results>
In this section we present the effects of the Voronoi-based tessellation approaches on the various datasets introduced in @sec_datasets. We evaluate all approaches using several global-, region-wise- and instance-wise metrics previously introduced in @sec_metrics.

In @sec_losscombos_results we show the results of different global- and region-wise loss combinations using several different compound losses.

@sec_weightmaps_results shows further evaluations using precomputed weight maps on applied the baseline loss of global DiceCE.

While we present relevant test results across all datasets and experiments, exhaustive tables of our results with several additional metrics evaluated across all datasets are given in the supplementary material @Appendix_A.

== Loss Combinations <sec_losscombos_results>
Introducing a Voronoi-based loss function component improves many metrics across all datasets in both 2D and 3D as shown in @taballlosscombos. Apart from @rq in the mitochondria dataset, the best models in each datasets and metric combination utilize some form of region-wise loss. Additionally, global metrics such as @dsc as well as instance-wise (e.g. @sqassd) and the region-wise CCDice show improvements across all datasets.

#figure(
  importantresults-table_loss_combos(),
  caption: [Results for all datasets across various metrics when changing loss weightings and different compound loss functions using only global DiceCE as a baseline. The first entry of a loss configuration tuple describes $hat(alpha)*cal(L)_"global"$; the second describes $hat(beta)*cal(L)_"Voronoi"$. Improvements are shown as relative deltas to the baseline in green, metrics that have worsened are shown in red, $arrow.b$ indicates a lower metric value is an improvement. The best value in each metric is emphasized in bold. Result rows are grouped by their dataset.],
)<taballlosscombos>

Introduction of region-wise losses has, however, a detrimental impact on training time, increasing the average time per training epoch. @figtimeperepoch shows this effect, with the global-only DiceCE requiring the lowest amount of time to train on all 2D and 3D datasets. The @wmh dataset shows the highest difference, with baseline training taking 345 minutes and region-wise DiceCE taking 625 minutes to train the full 500 epochs.

#figure(
  image("../figures/results/timeperepoch.png", width: 80%),

  caption: [Average minutes per epoch across datasets and loss combinations. All loss combinations across a given dataset were trained on the same hardware.
  ],
) <figtimeperepoch>
The following sections will provide additional, more granular segmentation performance results of region-wise loss combinations per dataset.

Specifically for the @mets:long (@mets) dataset, while @taballlosscombos shows overall increases in instance recall, @figmetsrecallbyquartile shows the vast improvements with no decrease in instance recall by volume quartile over all quartiles. The improvement in instance recall is most visible in Q2 with the purely region-wise DiceCE loss being able to identify more instances in the quartile compared to the baseline $(0.44 -> 0.81)$. Across other loss combinations, Q2 improvements are slightly lower, but consistently present.

#figure(
  image("../figures/results/mets/lollipop/loss_combos/quartile_recall_comparison.png", width: 100%),

  caption: [Lollipop chart of Stanford @mets:long (@mets) dataset showing the relative change in instance recall by volume quartile against a baseline. All instances were separated into their respective volume quartiles with Q1 being the smallest 25% of metastases and Q4 being the largest 25%. As a baseline we evaluate against global-only $cal(L)_"DiceCE"$. Baselines for each quartile are given as horizontal dotted lines, improvements over this value are shown in green #box(circle(
      width: 0.8em,
      height: 0.8em,
      fill: improvement_colors.at(0),
      stroke: 0.1pt,
    )), no or negligible changes are displayed in gray
    #box(circle(width: 0.8em, height: 0.8em, fill: improvement_colors.at(2), stroke: 0.1pt)).
  ],
) <figmetsrecallbyquartile>

Improvements in instance recall, however, are juxtaposed by worsening of the instance precision metric. @figmetsinstanceprecision shows that all other tested loss combinations worsen the instance precision of the baseline.

#figure(
  image("../figures/results/mets/lollipop/loss_combos/precision_inst.png", width: 65%),

  caption: [Comparison of @mets dataset instance precision against the global-only DiceCE baseline when trained with region-wise losses with various combinations and weights.
  ],
) <figmetsinstanceprecision>

The decreases in instance precision notwithstanding, @rq:long, the harmonic mean between $"recall"_"inst"$ and $"precision"_"inst"$, improved in almost all alternative configurations except region-only DiceCE.

In addition to the volume-wise instance recall improvements, we present a similar figure showing @sqdsc based on volume quartile in @figmetsresultslollipopsqdsc. While there are decreases in the lowest quartile for some loss combinations (with global CETversky and region-wise DiceTversky decreasing Q1 values from 0.18 to 0.13), quartiles 2 and 3 showed consistent improvements across all combinations with minimal increases of $0.29 -> 0.36$ and $0.38 -> 0.51$ respectively.

#figure(
  image("../figures/results/mets/lollipop/loss_combos/quartile_SQDSC_comparison.png", width: 95%),
  caption: [Loss combination lollipop charts of @mets dataset measuring @sqdsc by instance volume quartiles. Baseline values for each quartile are given by dashed lines. Improvements are shown in green over the baseline loss of standard global DiceCE.
  ],
) <figmetsresultslollipopsqdsc>

@figsbmgloballocal depicts a qualitative evaluation sample from both the (DiceCE, none) and (none, DiceCE) combinations showing the difference in segmentations when a model is trained globally versus strictly region-wise. The label contains 13 metastases with the global DiceCE identifying 6 as true positive instances and no $"FP"_"inst"$. The Voronoi-region-wise DiceCE found 11 label instances, predicting 5 false instances.

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

Given the high-stakes domain of brain cancer metastases, predicting no cancer lesions at all can be seen as a fatal flaw in any model; it is therefore also important to examine the number of cases where a model evaluated a patient as cancer-free (i.e. the set of all connected components on the prediction $hat(Y)$ is empty, that is: $hat(I) = emptyset$). These cases do not exist in the dataset, with each scanned patient exhibiting at least 1 metastasized tumor. Of all tested combinations, only the baseline of the purely global DiceCE failed to predict any cancerous lesions in 2 patients.

The @wmh:long (@wmh) dataset is the second 3D dataset under evaluation. As with @mets, @taballlosscombos shows that key metrics in all categories of global, instance-wise and region-wise are improved when training with the Voronoi loss paradigm. @dsc however, only showed improvements over the baseline when the global loss component received double the weight of the region-wise component, increasing from 0.451 to 0.488.

@figwmhrecallbyquartile shows changes in the recall of instances based on their volume. It can be seen that @wmh instances are identified more often across all volume quartiles showing the largest improvements in recall for the smallest instances belonging to Q1 and Q2 with all region-wise losses improving this value from 0.1 to at least 0.17 and 0.2 to at least 0.33 respectively.

#figure(
  image("../figures/results/wmh/lollipop/loss_combos/quartile_recall_comparison.png", width: 100%),

  caption: [Lollipop chart of the @wmh:long (@wmh) dataset showing the relative change in instance recall by volume quartile against a baseline. All instances were separated into their respective volume quartiles with Q1 being the smallest 25% of lesions and Q4 being the largest 25%. As a baseline we evaluate against global-only $cal(L)_"DiceCE"$. Baselines for each quartile are given as horizontal dotted lines, improvements over this value are shown in green #box(circle(
      width: 0.8em,
      height: 0.8em,
      fill: improvement_colors.at(0),
      stroke: 0.1pt,
    )), no or negligible changes are displayed in gray
    #box(circle(width: 0.8em, height: 0.8em, fill: improvement_colors.at(2), stroke: 0.1pt)).
  ],
) <figwmhrecallbyquartile>

Both @cv:long and @ag:long are organelles in platelet cells and their segmentation in 2D images provides a comparison of how segmentation models perform on the same images given different segmentation targets.

The evaluation results of the @cv dataset remain relatively consistent, showing only  small improvements in many metrics present in @taballlosscombos. However, consistent gains can again be seen across all metric categories. The best combination in this dataset used DiceCE both globally and locally, but with a doubled weight for the region-wise loss. In this combination, all five metrics show improvements with instance recall ($0.913 -> 0.924$) and @rq ($0.875 -> 0.883$) increasing to their highest value.

Comparing the baseline segmentation of alpha granules against the baseline of canalicular vessels showed improved @dsc (0.813 vs. 0.804), but lower @rq at 0.746 vs 0.875. The recall of alpha granule instances is also significantly lower with the baseline model being able to predict only 77% of instances compared to the 91.3% of canalicular vessel organelles. @figagrecallbyquartile shows that the baseline model struggled most with identifying the smallest granules and region-wise DiceCE increasing the recall of instances in this quartile by from 0.36 to 0.62.

#figure(
  image("../figures/results/ag/lollipop/loss_combos/quartile_recall_comparison.png", width: 100%),

  caption: [Lollipop chart of the @ag:long (@ag) dataset showing the relative change in instance recall by volume quartile against a baseline. All instances were separated into their respective volume quartiles with Q1 being the smallest 25% of organelles and Q4 being the largest 25%. As a baseline we evaluate against global-only $cal(L)_"DiceCE"$. Baselines for each quartile are given as horizontal dotted lines, improvements over this value are shown in green #box(circle(
      width: 0.8em,
      height: 0.8em,
      fill: improvement_colors.at(0),
      stroke: 0.1pt,
    )), no or negligible changes are displayed in gray
    #box(circle(width: 0.8em, height: 0.8em, fill: improvement_colors.at(2), stroke: 0.1pt)).
  ],
) <figagrecallbyquartile>

The EPFL @mit:long (@mit) dataset shows the highest baseline performance across all metrics and datasets in @taballlosscombos, showing that the baseline model is already able to provide a highly accurate segmentation both pixel- and instance-wise. This notwithstanding, region-wise losses are still able to improve several key metrics such as instance recall ($0.962 -> 0.987$) and CCDice ($0.896 -> 0.923$). @rq:long, however, reduces consistently across all region-wise loss combinations, with the baseline of 0.907 not being improved in any combination.

== Weight Maps<sec_weightmaps_results>
In addition to the evaluation of region-wise loss variations, we proposed several weight maps in @sec_weight_maps_method intended to steer loss behaviour towards instances current models struggle segmenting accurately. We compared these maps against the same baseline of global DiceCE without region-wise loss. As with the comparison of the loss combinations, @taballweightmaps shows the same metrics across all 5 evaluated datasets when trained with weight maps.

Over all datasets, weight maps were selectively able to improve several segmentation metrics. Strikingly, $W_"v_iw"$ improved instance recall on brain metastases from 0.648 to 0.955, meaning that over 95% of metastases were located. However, all other metrics in the dataset decreased when applying Voronoi inverse weighting, with @rq dropping from 0.685 to 0.03. This is a sign of severe over-prediction, producing a large number of false positive instances.

#figure(
  importantresults-table_weight_maps(),
  caption: [Results for all datasets across various metrics when trained with different weight maps. Baseline values are computed on global-only DiceCE without a weight map, all other maps were applied to the same loss. Improvements are shown as relative deltas to the baseline in green, metrics that have worsened are shown in red, $arrow.b$ indicates a lower metric value is an improvement. The best value in each metric is emphasized in bold. Result rows are grouped by their dataset.],
)<taballweightmaps>

The @wmh dataset was improved in almost all metrics when $W_"v_mountains"$, a map in which weights are highest in instance pixels and exponentially decay with distance from its border, was applied during training. $W_"v_mountains"$ improved instance recall over the baseline $(0.315 arrow 0.676)$, @sqassd was also improved greatly, reducing the distance of surfaces by 0.665 voxels from the 1.173 baseline. CCDice results were also more than doubled ($0.180 -> 0.366$).

@figwmhquartileresultsweightmaps depicts the results of @wmh instance recall and @sqdsc per volume quartile across all weight maps. $W_"v_iw"$ greatly increases instance recall across all quartiles, improving the detection of the smallest instances in Q1 from 10% to 50%. The inverse weighted map did not, however, significantly increase segmentation quality of the identified instances, remaining relatively consistent with the baseline in all quartiles. $W_"v_mountains"$ had a similar effect on the recall of instances without compromising @sqdsc for any quartile. Additionally, $W_"v_region"$, the map that assigns the same share of the total weight to all Voronoi regions, consistently increased both instance recall as well as @sqdsc, but to a lesser extent.

This, in addition to the results in @taballweightmaps, shows that both $W_"v_mountains"$ and $W_"v_region"$ provide significant improvements, and although the gains of $W_"v_region"$ are lower, the weight map is also not detrimental to any presented metric.

While $W_"v_mountains"$ also improved several metrics in the @mets dataset such as instance recall from 0.648 to 0.866, @rq decreases from 0.685 to 0.193. This indicates a similar but less severe overprediction problem as $W_"v_iw"$.

The stark differences in evaluation results in the 3D datasets point toward a fundamentally different effect of weight maps on numerically and morphologically diverse instances.

#context text(size: 10pt)[
  #figure(
    grid(
      image("../figures/results/wmh/lollipop/weight_maps/quartile_recall_comparison.png", width: 100%),
      image("../figures/results/wmh/lollipop/weight_maps/quartile_SQDSC_comparison.png", width: 100%),
    ),
    caption: [Per-quartile instance recall (top) and @sqdsc (bottom) results for the @wmh dataset across all evaluated weight maps. Q1 includes the smallest 25% of lesions by voxel volume, Q4 the largest 25%. $W_"none"$ baseline results per quartile are given by dotted lines with improvements in green and worsening results in red.],
  )<figwmhquartileresultsweightmaps>]

The 2D datasets exhibit a higher baseline segmentation performance, with weight maps only being able to marginally improve metrics and often worsening them. However, in @ag adaptive weighting based on the model's current prediction showed general increases in @dsc ($0.813 arrow 0.825$), @rq ($0.746 arrow 0.768$), instance recall ($0.770 arrow 0.807$) and CCDice ($0.630 arrow 0.657$), but worsening @sqassd slightly ($0.386 arrow 0.401$).

The @dsc of mitochondria segmentation could not be improved upon by the introduction of weight maps, although $W_"v_adaptive"$ could match it at the baseline of 0.944 as well as improve @sqassd ($0.151 arrow 0.118$), instance recall ($0.962 arrow 0.979$) and CCDice ($0.896 arrow 0.915$) at the cost of slightly decreasing @rq ($0.907 arrow 0.882$).

