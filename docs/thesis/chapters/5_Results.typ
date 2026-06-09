#import "../utils.typ": *
#import "../figures/results/combinedtableloss.typ": importantresults-table_loss_combos
#import "../figures/results/combinedtableweights.typ": importantresults-table_weight_maps
#import "../figures/results/combinedtableloss_quartiles.typ": importantresults-table_loss_combos_quartiles

= Results <chap_results>
In this section we present the effects of the previously introduced Voronoi-based tessellation approaches on the various datasets introduced in @sec_datasets. We evaluate all approaches using several global-, region-wise- and instance-wise metrics previously introduced in @sec_metrics.

In @sec_losscombos_results we show the results of different global- and region-wise loss combinations using several different compound losses.

@sec_weightmaps_results shows further evaluations using precomputed weight maps on applied the baseline loss of global DiceCE.

Full tables of several additional metrics evaluated across all datasets is given in the supplementary material @Appendix_A along with additional charts.

== Loss Combinations <sec_losscombos_results>
Introducing a Voronoi-based loss function component improves many metrics across all datasets in both 2D and 3D as shown in @taballlosscombos. Apart from @rq in the mitochondria dataset, the best models in each datasets and metric combination utilize some form of region-wise loss. Additionally, global metrics such as @dsc as well as instance-wise (e.g. @sqassd) and the region-wise CCDice show improvements across all datsets.

#context text(size: 10pt)[
  #figure(
    importantresults-table_loss_combos(),
    caption: [Results for all datasets across various metrics when changing loss weightings and different compound loss functions using only global DiceCE as a baseline. The first entry of a loss configuration tuple describes $hat(alpha)*cal(L)_"global"$, the second $hat(beta)*cal(L)_"Voronoi"$. Improvements are shown as relative deltas to the baseline in green, metrics that have worsened are shown in red. The best value in each metric is emphasized in bold. Result rows are grouped by their dataset.],
  )<taballlosscombos>]

Introduction of region-wise losses has, however, a detrimental impact on training time, increasing the average minutes per train epoch. @figtimeperepoch shows this effect, with the global-only DiceCE requiring the lowest amount of time to train on all 2D and 3D datasets. The @wmh dataset shows the highest difference, with baseline training taking 345 minutes and region-wise DiceCE taking 625 minutes to train the full 500 epochs.

#figure(
  image("../figures/results/timeperepoch.png", width: 80%),

  caption: [Average minutes per epoch across datasets and loss combinations. All loss combinations across a given dataset were trained on the same hardware.
  ],
) <figtimeperepoch>
The following sections will provide additional, more granular results of region-wise loss combinations per dataset.

Specifically for the @mets:long (@mets) dataset, @taballlosscombos shows overall improvements in instance recall. @figmetsrecallbyquartile shows the vast improvements with no decrease in instance recall by volume quartile over all quartiles. The improvement in instance recall is most visible in Q2 with the purely region-wise DiceCE loss being able to identify $84%$ more instances in the quartile over the baseline. Across other loss combinations, Q2 improvements are slightly lower, but consistently increased.

#figure(
  image("../figures/results/mets/lollipop/loss_combos/quartile_recall_comparison.png", width: 100%),

  caption: [Lollipop chart of Stanford @mets:long (@mets) dataset showing the relative change in instance recall by volume quartile against a baseline. All instances were separated into their respective volume quartiles with Q1 being the smallest 25% of metastases and Q4 being the largest 25%. As a baseline we evaluate against global-only $cal(L)_"DiceCE"$. Baselines for each quartile are given as horizontal dotted lines, improvements over this value are shown in green #box(circle(
      width: 0.8em,
      height: 0.8em,
      fill: improvement_colors.at(0),
      stroke: 0.1pt,
    )), no or neglegiable changes are displayed in gray
    #box(circle(width: 0.8em, height: 0.8em, fill: improvement_colors.at(2), stroke: 0.1pt)).
  ],
) <figmetsrecallbyquartile>

Improvements in instance recall, however, are juxtaposed by worsening of the instance precision metric. @figmetsinstanceprecision shows that all other tested loss combinations worsen the instance precision of the baseline.

#figure(
  image("../figures/results/mets/lollipop/loss_combos/precision_inst.png", width: 65%),

  caption: [Comparison of @mets dataset instance precision against the global-only DiceCE baseline when trained with region-wise losses with various combinations and weights.
  ],
) <figmetsinstanceprecision>

This notwithstanding, @rq:long, the harmonic mean between $"recall"_"inst"$ and $"precision"_"inst"$, improved in almost all alternative configurations except region-only DiceCE.

@figsbmgloballocal depicts a qualitative evaluation sample from both the (DiceCE, none) and (none, DiceCE) combinations. The label contains 13 metastases with the global DiceCE identifying 6 as true positive instances and no $"FP"_"inst"$. The Voronoi-region-wise DiceCE, however, found 11 label instances, predicting 5 false instances. This exemplifies that forcing the loss function to compute gradients over local Voronoi regions rather than the global volume makes the model more sensitive, identifying otherwise missed instances but leading to false positives.

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

Given the high-stakes domain of brain cancer metastses, predicting no cancer lesions at all can be seen as a fatal flaw in any model, it is therefore also important to examine the number of cases where a model evaluated a patient as cancer-free (i.e. the set of all connected components on the prediction $hat(Y)$ is empty, or: $hat(I) = emptyset$). These cases do not exist in the dataset, with each scanned patient exhibiting at least 1 metastasized tumor. Of all tested combinations, only the baseline of the purely global DiceCE failed to predict any cancerous lesions in 2 patients.

The @wmh:long (@wmh) datset is the second 3D dataset under evaluation. As with @mets, @taballlosscombos show that key metrics in all categories of global, instance-wise and region-wise are improved when training with the voronoi loss paradigm. @dsc however, only showed improvements over the baseline when the global loss component received double the weight of the the region-wise component. @sqassd showed the highest improvement across all datasets, decreasing by 0.304 when global DiceCE is combined with region-wise DiceTversky.

@figwmhrecallbyquartile shows changes in the recall of instances based on their volume. It can be seen that @wmh instances are identified more often across all volume quartiles showing the largest improvements in recall for the smallest instances belonging to Q1 and Q2 with all region-wise losses improving this value from 0.1 to >0.17 and 0.2 to >0.33 respectively.

#figure(
  image("../figures/results/wmh/lollipop/loss_combos/quartile_recall_comparison.png", width: 100%),

  caption: [Lollipop chart of the @wmh:long (@wmh) dataset showing the relative change in instance recall by volume quartile against a baseline. All instances were separated into their respective volume quartiles with Q1 being the smallest 25% of metastases and Q4 being the largest 25%. As a baseline we evaluate against global-only $cal(L)_"DiceCE"$. Baselines for each quartile are given as horizontal dotted lines, improvements over this value are shown in green #box(circle(
      width: 0.8em,
      height: 0.8em,
      fill: improvement_colors.at(0),
      stroke: 0.1pt,
    )), no- or neglegiable changes are displayed in gray
    #box(circle(width: 0.8em, height: 0.8em, fill: improvement_colors.at(2), stroke: 0.1pt)).
  ],
) <figwmhrecallbyquartile>

Both @cv:long and @ag:long are organelles in platelet cells and their segmentation in 2D images provides a comparison how segmentation models perform on the same images given different segmentation targets.

The evaluation results of the @cv dataset remain relatively consistent, showing only relatively small improvements in many metrics present in @taballlosscombos. However, consistent gains can again be seen across all metric categories. Solely instance recall is unable to improve consistently, showing both very slight occasional decreases as well improvements.

Baseline segmentation of alpha granules showed improved @dsc compared to @cv (0.813 vs. 0.804), but lower @rq at 0.746 vs 0.875. The recall of alpha granule instances is also significantly lower with the model being able to predict only 77% of instances compared to the 91.3% of canalicular vessel organelles. However, instance recall of @ag was increased by 0.105 when training with region-wise DiceCE instead of global DiceCE.

The EPFL mitochondria (@mit) dataset shows the highest baseline performance across all metrics and datasets in @taballlosscombos, showing that the baseline model is already able to provide a highly accurate segmentation both pixel- and instance-wise. This notwithstanding, region-wise losses are still able to improve several key metrics such as instance recall and CCDice. @Sqassd was also consistently decreased, reducing segmentation boundary errors in the configuration (DiceCE, DiceCE). @rq:long, however, reduces consistently across all region-wise loss combinations.

== Weight Maps<sec_weightmaps_results>
In addition to the evaluation of region-wise loss variations, we proposed several weight maps in @sec_weight_maps_method intended to steer loss behaviour towards instances current models have trouble segmenting. These maps were compared against the same baseline of global DiceCE without region-wise loss. As with the comparison of the loss combinations, @taballweightmaps shows the same metrics across all 5 evaluated datasets when trained with weight maps.

Over all datasets, weight maps were selectively able to improve several segmentation metrics. The @wmh dataset was improved in almost all metrics when $"W"_"v_mountains"$, a map in which weights are highest in instance pixels and exponentially decay with distance from its border, was applied during training. $"W"_"v_mountains"$ improved instance recall by 0.361 over the baseline of 0.315, @sqassd was also improved greatly, reducing the distance of surfaces by 0.665 over the 1.173 baseline. CCDice results were also more than doubled. While $"W"_"v_mountains"$ also improved several metrics in the @mets dataset such as instance recall from 0.648 to 0.866, @rq decreases from 0.685 to 0.193.

The stark differences in evaluation results in the 3D datasets point toward a fundamental difference the effect of weight maps on morphologically diverse instances.

#todo("Hendrik struck out the next two sections. Ask for clarification perhaps")
Strikingly, $"W"_"v_iw"$ improved instance recall on brain metastases by 0.307, for a total value of 0.955, meaning that over 95% of metastases were located. However, all other metrics in the dataset decreased when applying Voronoi inverse weighting with @rq dropping to a total value of 0.03. This is a sign of severe over-prediction, producing a large number of false positive instances.

The 2D datasets already exhibited a higher baseline segmentation performance, with weight maps only being able to marginally improve metrics and often worsening them. However, in @ag adaptive weighting based on the models current prediction showed general increases in @dsc (+0.012), @rq (+0.022), instance recall (+0.037) and CCDice (+0.027), worsening @sqassd slightly (+0.015).

The @dsc of mitochondria segmentation could not be improved upon by the introduction of weight maps, although $"W"_"v_adaptive"$ could match it at 0.944 as well as improve @sqassd (-0.33), instance recall (+0.017) and CCDice (+0.019) at the cost of slighlty decreasing @rq (-0.25).

#context text(size: 10pt)[
  #figure(
    importantresults-table_weight_maps(),
    caption: [Results for all datasets across various metrics when training with different weight maps. Baseline values are computed on global-only DiceCE without a weight map, all other maps were applied to the same loss. Improvements are shown as relative deltas to the baseline in green, metrics that have worsened are shown in red. The best value in each metric is emphasized in bold. Result rows are grouped by their dataset.],
  )<taballweightmaps>]