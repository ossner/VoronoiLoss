#import "../utils.typ": *
#import "../figures/results/wmh/table_loss_combos.typ": wmhresults-table_loss_combos
#import "../figures/results/mets/table_loss_combos.typ": metsresults-table_loss_combos
#import "../figures/results/cv/table_loss_combos.typ": cvresults-table_loss_combos
#import "../figures/results/ag/table_loss_combos.typ": agresults-table_loss_combos
#import "../figures/results/mit/table_loss_combos.typ": mitresults-table_loss_combos
#import "../figures/results/combinedtableloss_quartiles_3D.typ": importantresults-table_loss_combos_quartiles_3D
#import "../figures/results/combinedtableloss_quartiles_2D.typ": importantresults-table_loss_combos_quartiles_2D

#import "../figures/results/wmh/table_weight_maps.typ": wmhresults-table_weight_maps
#import "../figures/results/mets/table_weight_maps.typ": metsresults-table_weight_maps
#import "../figures/results/cv/table_weight_maps.typ": cvresults-table_weight_maps
#import "../figures/results/ag/table_weight_maps.typ": agresults-table_weight_maps
#import "../figures/results/mit/table_weight_maps.typ": mitresults-table_weight_maps
#import "../figures/results/combinedtableweights_quartiles_3D.typ": importantresults-table_weight_maps_quartiles_3D
#import "../figures/results/combinedtableweights_quartiles_2D.typ": importantresults-table_weight_maps_quartiles_2D


#heading(numbering: "A -")[Supplementary Materials] <Appendix_A>

This appendix provides additional results, tables and charts for deeper examination. All metrics, datasets and abbreviations introduced in the main text are used without modification.

#heading(depth: 2, numbering: "A.1 -")[Loss Combinations]

#figure(
  importantresults-table_loss_combos_quartiles_3D(),
  caption: [3D per-quartile results for @wmh and @mets datasets across global- and region-wise loss combinations, evaluating instance recall and @sqdsc per volume quartile. Q1 represents the smallest instances by voxel volume, Q4 the largest.],
)<taballlosscombosquartiles3D>

#figure(
  importantresults-table_loss_combos_quartiles_2D(),
  caption: [2D per-quartile results for @cv, @ag and @mit datasets across global- and region-wise loss combinations, evaluating instance recall and @sqdsc per area quartile. Q1 represents the smallest instances by pixel area, Q4 the largest.],
)<taballlosscombosquartiles2D>

#figure(
  metsresults-table_loss_combos(),
  caption: [Complete results table of the @mets dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, worsening metrics in red and $arrow.b$ indicates a lower metric value is an improvement. The best result for each metric is emphasized in bold.
  ],
)<tabmetslosscombos>

#figure(
  wmhresults-table_loss_combos(),
  caption: [Complete results table of the @wmh dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, worsening metrics in red and $arrow.b$ indicates a lower metric value is an improvement. The best result for each metric is emphasized in bold.
  ],
)<tabwmhlosscombos>


#figure(
  cvresults-table_loss_combos(),
  caption: [Complete results table of the @cv dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green with $arrow.b$ indicating a lower metric value is an improvement, negligible changes in metrics are shown in gray and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabcvlosscombos>

#figure(
  agresults-table_loss_combos(),
  caption: [Complete results table of the @ag dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green with $arrow.b$ indicating a lower metric value is an improvement, negligible changes in metrics are shown in gray and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabaglosscombos>


#figure(
  mitresults-table_loss_combos(),
  caption: [Complete results table of the @mit dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green with $arrow.b$ indicating a lower metric value is an improvement and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabmitlosscombos>

#heading(depth: 2, numbering: "A.1 -")[Weight Maps]


#figure(
  importantresults-table_weight_maps_quartiles_3D(),
  caption: [3D per-quartile results for @wmh and @mets datasets across weight maps against baseline of $W_"none"$, evaluating instance recall and @sqdsc per volume quartile. Q1 represents the smallest instances by voxel volume, Q4 the largest.],
)<taballweightsquartiles3D>

#figure(
  importantresults-table_weight_maps_quartiles_2D(),
  caption: [2D per-quartile results for @cv, @ag and @mit datasets across weight maps against baseline of $W_"none"$, evaluating instance recall and @sqdsc per area quartile. Q1 represents the smallest instances by pixel area, Q4 the largest.],
)<taballweightsquartiles2D>

#figure(
  metsresults-table_weight_maps(),
  caption: [Complete results table of the @mets dataset across all tested weight maps. All results are evaluated against a global DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, worsening metrics in red and $arrow.b$ indicating a lower metric value is an improvement. The best result for each metric is emphasized in bold.
  ],
)<tabmetsweightmaps>

#figure(
  wmhresults-table_weight_maps(),
  caption: [Complete results table of the @wmh dataset across all tested weight maps. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, worsening metrics in red and $arrow.b$ indicating a lower metric value is an improvement. The best result for each metric is emphasized in bold.
  ],
)<tabwmhweightmaps>


#figure(
  cvresults-table_weight_maps(),
  caption: [Complete results table of the @cv dataset across all tested weight maps. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligible changes in metrics are shown in gray and worsening metrics in red and $arrow.b$ indicating a lower metric value is an improvement. The best result for each metric is emphasized in bold.
  ],
)<tabcvweightmaps>

#figure(
  agresults-table_weight_maps(),
  caption: [Complete results table of the @ag dataset across all tested weight maps. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligible changes in metrics are shown in gray and worsening metrics in red and $arrow.b$ indicating a lower metric value is an improvement. The best result for each metric is emphasized in bold.
  ],
)<tabagweightmaps>


#figure(
  mitresults-table_weight_maps(),
  caption: [Complete results table of the @mit dataset across all tested weight maps. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligible changes in metrics are shown in gray and worsening metrics in red and $arrow.b$ indicating a lower metric value is an improvement. The best result for each metric is emphasized in bold.
  ],
)<tabmitweightmaps>
