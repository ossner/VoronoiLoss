#import "../utils.typ": *
#import "../figures/results/wmh/table_loss_combos.typ": wmhresults-table_loss_combos
#import "../figures/results/mets/table_loss_combos.typ": metsresults-table_loss_combos
#import "../figures/results/cv/table_loss_combos.typ": cvresults-table_loss_combos
#import "../figures/results/ag/table_loss_combos.typ": agresults-table_loss_combos
#import "../figures/results/mit/table_loss_combos.typ": mitresults-table_loss_combos

= Results <sec_results>
== Loss Combinations <sec_losscombinations>

=== Brain Metastases <sec_metslossresults>

#context text(size: 10pt)[
  #figure(metsresults-table_loss_combos(),
  caption: [@mets Loss combos
  ],
)<tabmetslosscombos>]
#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -15mm,

    // Top row
    image("../figures/results/mets/lollipop/loss_combos/DSC.png", width: 80%),
    image("../figures/results/mets/lollipop/loss_combos/F2.png", width: 80%),
    image("../figures/results/mets/lollipop/loss_combos/RQ.png", width: 80%),
    image("../figures/results/mets/lollipop/loss_combos/CCDice.png", width: 80%),
    image("../figures/results/mets/lollipop/loss_combos/SQDSC.png", width: 80%),
    image("../figures/results/mets/lollipop/loss_combos/SQASSD.png", width: 80%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/mets/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
    ),
  ),
  caption: [Loss combination lollipop charts of @mets dataset. Improvements are shown in green over the baseline loss of standard global DiceCE. Bottom right shows instance recall deltas per volume quartile.
  ],
) <figmetsresultslollipoplosscombos>

=== White Matter Hyperintensities <sec_wmhlossresults>

#context text(size: 10pt)[
  #figure(wmhresults-table_loss_combos(),
  caption: [@wmh Loss combos
  ],
)<tabwmhlosscombos>]

#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -15mm,

    // Top row
    image("../figures/results/wmh/lollipop/loss_combos/DSC.png", width: 80%),
    image("../figures/results/wmh/lollipop/loss_combos/F2.png", width: 80%),
    image("../figures/results/wmh/lollipop/loss_combos/RQ.png", width: 80%),
    image("../figures/results/wmh/lollipop/loss_combos/CCDice.png", width: 80%),
    image("../figures/results/wmh/lollipop/loss_combos/SQDSC.png", width: 80%),
    image("../figures/results/wmh/lollipop/loss_combos/SQASSD.png", width: 80%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/wmh/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
    ),
  ),
  caption: [Loss combination lollipop charts of @wmh dataset. Improvements are shown in green over the baseline loss of standard global DiceCE. Bottom right shows instance recall deltas per volume quartile.
  ],
) <figwmhresultslollipoplosscombos>


=== Canalicular Vessels <sec_cvlossresults>

#context text(size: 10pt)[
  #figure(cvresults-table_loss_combos(),
  caption: [@cv Loss combos
  ],
)<tabcvlosscombos>]

#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -15mm,

    // Top row
    image("../figures/results/cv/lollipop/loss_combos/DSC.png", width: 80%),
    image("../figures/results/cv/lollipop/loss_combos/F2.png", width: 80%),
    image("../figures/results/cv/lollipop/loss_combos/RQ.png", width: 80%),
    image("../figures/results/cv/lollipop/loss_combos/CCDice.png", width: 80%),
    image("../figures/results/cv/lollipop/loss_combos/SQDSC.png", width: 80%),
    image("../figures/results/cv/lollipop/loss_combos/SQASSD.png", width: 80%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/cv/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
    ),
  ),
  caption: [Loss combination lollipop charts of canalicular vessel dataset. Improvements are shown in green over the baseline loss of standard global DiceCE. Bottom right shows instance recall deltas per volume quartile.
  ],
) <figcvresultslollipoplosscombos>

=== Alpha Granules <sec_aglossresults>

#context text(size: 10pt)[
  #figure(agresults-table_loss_combos(),
  caption: [@ag Loss combos
  ],
)<tabaglosscombos>]

#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -15mm,

    // Top row
    image("../figures/results/ag/lollipop/loss_combos/DSC.png", width: 80%),
    image("../figures/results/ag/lollipop/loss_combos/F2.png", width: 80%),
    image("../figures/results/ag/lollipop/loss_combos/RQ.png", width: 80%),
    image("../figures/results/ag/lollipop/loss_combos/CCDice.png", width: 80%),
    image("../figures/results/ag/lollipop/loss_combos/SQDSC.png", width: 80%),
    image("../figures/results/ag/lollipop/loss_combos/SQASSD.png", width: 80%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/ag/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
    ),
  ),
  caption: [Loss combination lollipop charts of alpha granule dataset. Improvements are shown in green over the baseline loss of standard global DiceCE. Bottom right shows instance recall deltas per volume quartile. #box(circle(
    width: 0.8em,
    height: 0.8em,
    fill: improvement_colors.at(0),
    stroke: 0.1pt,
  )) show improvements,
  #box(circle(
    width: 0.8em,
    height: 0.8em,
    fill: improvement_colors.at(1),
    stroke: 0.1pt,
  )) show worsening metrics. Neglegiable or no changes are displayed as 
  #box(circle(
    width: 0.8em,
    height: 0.8em,
    fill: improvement_colors.at(2),
    stroke: 0.1pt,
  )).
  ],
) <figagresultslollipoplosscombos>

=== Mitochondria <sec_mitlossresults>


#context text(size: 10pt)[
  #figure(mitresults-table_loss_combos(),
  caption: [@mit Loss combos
  ],
)<tabmitlosscombos>]

#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -15mm,

    // Top row
    image("../figures/results/mit/lollipop/loss_combos/DSC.png", width: 80%),
    image("../figures/results/mit/lollipop/loss_combos/F2.png", width: 80%),
    image("../figures/results/mit/lollipop/loss_combos/RQ.png", width: 80%),
    image("../figures/results/mit/lollipop/loss_combos/CCDice.png", width: 80%),
    image("../figures/results/mit/lollipop/loss_combos/SQDSC.png", width: 80%),
    image("../figures/results/mit/lollipop/loss_combos/SQASSD.png", width: 80%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/mit/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
    ),
  ),
  caption: [Loss combination lollipop charts of mitochondria dataset. Improvements are shown in green over the baseline loss of standard global DiceCE. Bottom right shows instance recall deltas per volume quartile. #box(circle(
    width: 0.8em,
    height: 0.8em,
    fill: improvement_colors.at(0),
    stroke: 0.1pt,
  )) show improvements,
  #box(circle(
    width: 0.8em,
    height: 0.8em,
    fill: improvement_colors.at(1),
    stroke: 0.1pt,
  )) show worsening metrics. Neglegiable or no changes are displayed as 
  #box(circle(
    width: 0.8em,
    height: 0.8em,
    fill: improvement_colors.at(2),
    stroke: 0.1pt,
  )).
  ],
) <figmitresultslollipoplosscombos>

== Weight Maps <sec_weightmaps_results>

=== Canalicular Vessels <sec_cvwmapresults>

#context text(size: 10pt)[
  #figure(
  table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 7),
  align: (left, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 0.4pt + luma(220),
  ),
  inset: 8pt,

  table.header(
    [],
    [none],
    [v_iw],
    [v_region],
    [v_adaptive],
    [v_mountains],
    [v_islands],
  ),

  // test/global/dice
  [DSC],
  [0.804],
  [#delta(-0.032)],
  [#delta(-0.005)],
  [*#delta(+0.005)*],
  [#delta(+0.004)],
  [#delta(-0.019)],

  // test/global/F2
  [F2],
  [0.777],
  [*#delta(+0.075)*],
  [#delta(-0.009)],
  [#delta(+0.007)],
  [#delta(+0.014)],
  [#delta(+0.067)],

  // test/instance/dice
  [SQDSC],
  [0.812],
  [#delta(-0.033)],
  [#delta(-0.003)],
  [#delta(+0.004)],
  [*#delta(+0.007)*],
  [#delta(-0.024)],

  // test/instance/f1
  [RQ],
  [*0.875*],
  [#delta(-0.081)],
  [#delta(-0.005)],
  [#delta(-0.002)],
  [#delta(-0.030)],
  [#delta(-0.031)],

  // test/instance/assd
  [SQASSD],
  [0.392],
  [#deltainv(+0.201)],
  [#deltainv(+0.011)],
  [#deltainv(-0.000)],
  [*#deltainv(-0.027)*],
  [#deltainv(+0.178)],

  // test/instance/recall_q0
  [inst_recall_q1],
  [0.733],
  [*#delta(+0.065)*],
  [#delta(-0.009)],
  [#delta(-0.009)],
  [#delta(+0.029)],
  [#delta(+0.015)],

  // test/instance/recall_q1
  [inst_recall_q2],
  [*0.955*],
  [#delta(-0.004)],
  [#delta(-0.045)],
  [#delta(-0.022)],
  [#delta(-0.009)],
  [#delta(-0.038)],

  // test/instance/recall_q2
  [inst_recall_q3],
  [0.943],
  [#delta(-0.006)],
  [#delta(+0.005)],
  [*#delta(+0.016)*],
  [#delta(+0.005)],
  [#delta(-0.024)],

  // test/instance/recall_q3
  [inst_recall_q4],
  [0.983],
  [*#delta(+0.003)*],
  [#delta(-0.008)],
  [#delta(-0.003)],
  [#delta(+0.001)],
  [#delta(-0.008)],

  // test/cc/dice
  [CCDice],
  [0.726],
  [#delta(-0.020)],
  [#delta(-0.012)],
  [#delta(+0.001)],
  [*#delta(+0.006)*],
  [#delta(-0.018)],
),
  caption: [Canalicular vessels weight maps
  ],
)<tabsomething>
]
#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -25mm,

    // Top row
    image("../figures/results/cv/lollipop/weight_maps/DSC.png", width: 70%),
    image("../figures/results/cv/lollipop/weight_maps/F2.png", width: 70%),
    image("../figures/results/cv/lollipop/weight_maps/RQ.png", width: 70%),
    image("../figures/results/cv/lollipop/weight_maps/CCDice.png", width: 70%),
    image("../figures/results/cv/lollipop/weight_maps/SQDSC.png", width: 70%),
    image("../figures/results/cv/lollipop/weight_maps/SQASSD.png", width: 70%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/cv/lollipop/weight_maps/quartile_recall_comparison.png", width: 83%),
    ),

  ),
  caption: [Weight map lollipop charts of canalicular vessels dataset. #todo("Ask about scaling and presentation on this one, how much should this take up?")
  ],
) <figcvresultslollipopweightmaps>

=== Alpha Granules <sec_agwmapresults>

#context text(size: 10pt)[
  #figure(
  table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 7),
  align: (left, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 0.4pt + luma(220),
  ),
  inset: 8pt,

  table.header(
    [],
    [none],
    [v_iw],
    [v_region],
    [v_adaptive],
    [v_mountains],
    [v_islands],
  ),

  // test/global/dice
  [DSC],
  [0.813],
  [#delta(-0.058)],
  [#delta(-0.003)],
  [*#delta(+0.013)*],
  [#delta(-0.012)],
  [#delta(-0.025)],

  // test/global/F2
  [F2],
  [0.821],
  [#delta(+0.019)],
  [#delta(+0.003)],
  [#delta(+0.008)],
  [#delta(+0.008)],
  [*#delta(+0.031)*],

  // test/instance/dice
  [SQDSC],
  [0.850],
  [#delta(-0.044)],
  [*#delta(+0.001)*],
  [#delta(-0.005)],
  [#delta(-0.036)],
  [#delta(-0.069)],

  // test/instance/f1
  [RQ],
  [0.746],
  [#delta(-0.107)],
  [#delta(+0.014)],
  [*#delta(+0.032)*],
  [#delta(-0.066)],
  [#delta(-0.030)],

  // test/instance/assd
  [SQASSD],
  [0.386],
  [#deltainv(+0.376)],
  [*#deltainv(-0.002)*],
  [#deltainv(+0.053)],
  [#deltainv(+0.187)],
  [#deltainv(+0.687)],

  // test/instance/recall_q0
  [inst_recall_q1],
  [0.360],
  [*#delta(+0.215)*],
  [#delta(+0.040)],
  [#delta(-0.024)],
  [#delta(+0.133)],
  [#delta(+0.137)],

  // test/instance/recall_q1
  [inst_recall_q2],
  [0.882],
  [*#delta(+0.093)*],
  [#delta(-0.028)],
  [#delta(+0.038)],
  [#delta(+0.084)],
  [#delta(+0.021)],

  // test/instance/recall_q2
  [inst_recall_q3],
  [0.939],
  [*#delta(+0.061)*],
  [#delta(+0.031)],
  [#delta(+0.031)],
  [#delta(+0.051)],
  [#delta(+0.001)],

  // test/instance/recall_q3
  [inst_recall_q4],
  [0.983],
  [#delta(+0.000)],
  [#delta(+0.000)],
  [*#delta(+0.017)*],
  [#delta(+0.000)],
  [#delta(-0.019)],

  // test/cc/dice
  [CCDice],
  [0.630],
  [#delta(+0.009)],
  [#delta(+0.005)],
  [#delta(+0.017)],
  [*#delta(+0.017)*],
  [#delta(+0.005)],
),
  caption: [Alpha Granules weight maps
  ],
)<tabsomething>
]

#figure(
    grid(
    columns: 3,
    align: center + horizon,
    row-gutter: 1mm,

    // Top row
    image("../figures/results/ag/lollipop/weight_maps/DSC.png", width: 100%),
    image("../figures/results/ag/lollipop/weight_maps/F2.png", width: 100%),
    image("../figures/results/ag/lollipop/weight_maps/RQ.png", width: 100%),
    image("../figures/results/ag/lollipop/weight_maps/CCDice.png", width: 100%),
    image("../figures/results/ag/lollipop/weight_maps/SQDSC.png", width: 100%),
    image("../figures/results/ag/lollipop/weight_maps/SQASSD.png", width: 100%),
    image("../figures/results/ag/lollipop/weight_maps/inst_precision.png", width: 100%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/ag/lollipop/weight_maps/quartile_recall_comparison.png", width: 100%),
    ),

  ),
  caption: [Weight map lollipop charts of alpha granule dataset.
  ],
) <figagresultslollipopweightmaps>

#todo("An instance-based analysis of segmentation, analyse instance metadata like morphology and voronoi regions in results")

#todo("Dataset noise and coeff. of covariance per dataset and how the random seed in deterministic training influences results")

#todo("Global vs instance vs mixed with a focus on global vs mixed due to earlier established literature")

#todo("Global vs. local weight distribution")

#todo("Analysis of runtimes and relative efficiency")

#todo("Weight maps")

#todo("The effect of false instance removal on partitioning and weight maps in 2D")

#todo("Adaptive Weighting")