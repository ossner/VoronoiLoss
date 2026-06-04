#import "../utils.typ": *
#import "../figures/results/combinedtable.typ": importantresults-table_loss_combos

= Results <sec_results>
== Loss Combinations <sec_losscombinations>

#context text(size: 10pt)[
  #figure(importantresults-table_loss_combos(),
  caption: [All datasets loss combos
  ],
)<taballlosscombos>]


=== Brain Metastases <sec_metslossresults>

=== Canalicular Vessels <sec_cvlossresults>

=== Alpha Granules <sec_aglossresults>

=== Mitochondria <sec_mitlossresults>

== Weight Maps <sec_weightmaps_results>

=== Canalicular Vessels <sec_cvwmapresults>
=== Alpha Granules <sec_agwmapresults>

=== Mitochondria <sec_mitwmapresults>

#todo("An instance-based analysis of segmentation, analyse instance metadata like morphology and voronoi regions in results")

#todo("Dataset noise and coeff. of covariance per dataset and how the random seed in deterministic training influences results")

#todo("Global vs instance vs mixed with a focus on global vs mixed due to earlier established literature")

#todo("Global vs. local weight distribution")

#todo("Analysis of runtimes and relative efficiency")

#todo("Weight maps")

#todo("The effect of false instance removal on partitioning and weight maps in 2D")

#todo("Adaptive Weighting")