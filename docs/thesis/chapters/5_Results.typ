#import "../utils.typ": *
#import "../figures/results/combinedtableloss.typ": importantresults-table_loss_combos
#import "../figures/results/combinedtableweights.typ": importantresults-table_weight_maps

= Results <sec_results>
In this section we present the effects of the previously introduced Voronoi-based tessellation approaches on the various datasets introduced in @sec_datasets. We evaluate all approaches using several global- and instance-wise metrics.

In @sec_losscombinations we show the results of different compound loss formulations. Each dataset was trained using the total loss function from @eqtotalloss with different losses for $cal(L)_"global"$ and $cal(L)_"Voronoi"$ or different weights $alpha$, $beta$.

@sec_weightmaps_results shows further evaluations using precomputed weight maps on applied the baseline loss of global DiceCE.

Full tables of several additional metrics evaluated across all datasets is given in the supplementary material @Appendix_A along with additional charts.

== Loss Combinations <sec_losscombinations>

Various metrics from all datasets are combined in @taballlosscombos. Metrics were calculated on the test set with each model trained with a different loss configuration. No weight maps were applied during any training.

Overall, introducing a voronoi-based loss function component improves many metrics across all datasets in both 2D and 3D. Apart from @rq in the mitochondria dataset, the best scores in every other dataset and metric are in a combination that utilizes some form of region-wise loss. Additionally, global metrics such as @dsc as well as instance-wise (e.g. @sqassd) and the region-wise CCDice show improvements across all datsets.

#context text(size: 10pt)[
  #figure(
    importantresults-table_loss_combos(),
    caption: [Results for all datasets across various metrics when changing loss weightings and different compound loss functions using only global DiceCE as a baseline. The first entry of a loss configuration tuple describes $alpha*cal(L)_"global"$, the second $beta*cal(L)_"Voronoi"$. Improvements are shown as relative deltas to the baseline in green, metrics that have worsened are shown in red. The best value in each metric is emphasized in bold. Result rows are grouped by their dataset.],
  )<taballlosscombos>]

Introduction of region-wise losses has, however, a detrimental impact on training performance, increasing the time per train epoch. @figtimeperepoch shows the effect clearly, with the global-only DiceCE requiring the lowest amount of time to train on all 2D and 3D datasets.

#figure(
  image("../figures/results/timeperepoch.png", width: 80%),

  caption: [Average minutes per epoch across datasets and loss combinations. All loss combinations across a given dataset were trained on the same hardware.
  ],
) <figtimeperepoch>
The following sections will provide additional, more granular results of region-wise loss combinations per dataset.
=== Brain Metastases <sec_metslossresults>
This section provides additional relevant test results for the Stanford @mets:long (@mets) dataset.

While @taballlosscombos already shows overall improvements in instance recall, @figmetsrecallbyquartile shows the vast improvements with no decrease in instance recall by volume quartile over all quartiles. The improvement in instance recall is most visible in Q2 with the purely region-wise DiceCE loss being able to identify $37%$ more instances in the quartile.

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

Improvements in instance recall, however, are juxtaposed by worsening of the instance precision metric. @figmetsinstanceprecision shows that all other tested loss combinations worsen the instance precision.

#figure(
  image("../figures/results/mets/lollipop/loss_combos/precision_inst.png", width: 65%),

  caption: [Comparison of @mets dataset instance precision against the global-only DiceCE baseline of 0.875 when trained with region-wise losses with various combinations and weights.
  ],
) <figmetsinstanceprecision>

This notwithstanding, @rq:long, the harmonic mean between $"recall"_"inst"$ and $"precision"_"inst"$, improved in almost all alternative configurations except region-only DiceCE.

Given the high-stakes domain of brain cancer metastses, predicting no cancer lesions at all can be seen as a fatal flaw in any model, it is therefore also important to examine the number of cases where a model evaluated a patient as cancer-free (i.e. the set of all connected components on the prediction $hat(Y)$ is empty, or: $hat(I) = emptyset$). These cases do not exist in the dataset, with each scanned patient exhibiting at least 1 metastasized tumor. Of all tested combinations, only the baseline of the purely global DiceCE failed to predict any cancerous lesions in 2 patients. #todo("Put this in a table or otherwise show this somehow? Or does text suffice?")

=== White Matter Hyperintensities <sec_wmhlossresults>
The @wmh:long (@wmh) datset is the second 3D dataset under evaluation. As with @mets, @taballlosscombos show that key metrics in all categories of global, instance-wise and region-wise are improved when training with the voronoi loss paradigm. @dsc however, only showed improvements over the baseline when the global loss component received double the weight of the the region-wise component.

@sqassd showed the highest improvement across all datasets, decreasing by 0.304 when global DiceCE is combined with region-wise DiceTversky.

@figwmhrecallbyquartile shows changes in the recall of instances based on their volume. It can be seen that @wmh instances are identified more often across all volume quartiles showing the smallest improvement in recall in the largest instances belonging to Q4.

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

=== Platelet Organelles
Both @cv:long and @ag:long are organelles in platelet cells and their segmentation in 2D images provides a comparison how segmentation models perform on the same images given different segmentation targets.

The evaluation results of the @cv dataset remain relatively consistent, showing only relatively small improvements in many metrics present in @taballlosscombos. However, consistent gains can again be seen across all metric categories. Solely instance recall is unable to improve consistently, showing both very slight occasional decreases of up to 0.03% as well as improvements of up to 1%.

Baseline segmentation of alpha granules showed improved @dsc compared to @cv (0.813 vs. 0.804), but lower @rq at 0.746 vs 0.875. The recall of alpha granule instances is also significantly lower with the model being able to predict only 77% of instances compared to the 91.3% of canalicular vessel organelles. However, instance recall of @ag was increased by 0.105 when training with region-wise DiceCE instead of global DiceCE.

=== Mitochondria <sec_mitlossresults>
The EPFL mitochondria (@mit) dataset shows the highest baseline performance across all metrics and datasets in @taballlosscombos, showing that the baseline model is already able to provide a highly accurate segmentation both pixel- and instance-wise. This notwithstanding, region-wise losses are still able to improve several key metrics such as instance recall and CCDice. @Sqassd was also consistently decreased, reducing segmentation boundary errors in the configuration (DiceCE, DicecE).


== Weight Maps<sec_weightmaps_results>
In addition to evaluating several combinations of region-wise losses, all weight maps introduced in @sec_weight_maps_method were compared against the same baseline of global DiceCE without region-wise loss. As with the comparison of the loss combinations, @taballweightmaps shows the same metrics across all 5 evaluated datasets.

Over all datasets, weight maps were selectively able to improve several segmentation metrics. The @wmh dataset was improved in almost all metrics when $"W"_"v_mountains"$ was applied during training with instance recall improving by 0.361 over the baseline of 0.315, @sqassd was also improved greatly, reducing the distance of surfaces by 0.665 over the 1.173 baseline. CCDice results were also more than doubled. While $"W"_"v_mountains"$ also improved several metrics in the @mets dataset, @rq drops by 0.193.

The stark differences in evaluation results in the 3D datasets point toward a fundamental difference the effect of weight maps on morphologically diverse instances.

Notably, $"W"_"v_iw"$ improved instance recall on brain metastases by 0.307, for a total value of 0.955, meaning that over 95% of metastases were located. However, all other metrics in the dataset decreased when applying Voronoi inverse weighting with @rq dropping to a total value of 0.03. This is a sign of severe over-prediction, producing a large number of false positive instances.

The 2D datasets already exhibited a higher baseline segmentation performance, with weight maps only being able to marginally improve metrics and often worsening them.

#context text(size: 10pt)[
  #figure(
    importantresults-table_weight_maps(),
    caption: [Results for all datasets across various metrics when training with different weight maps. Baseline values are computed on global-only DiceCE without a weight map, all other maps were applied to the same loss. Improvements are shown as relative deltas to the baseline in green, metrics that have worsened are shown in red. The best value in each metric is emphasized in bold. Result rows are grouped by their dataset.],
  )<taballweightmaps>]

=== Canalicular Vessels <sec_cvwmapresults>
=== Alpha Granules <sec_agwmapresults>

=== Mitochondria <sec_mitwmapresults>

#todo("The effect of false instance removal on partitioning and weight maps in 2D")
