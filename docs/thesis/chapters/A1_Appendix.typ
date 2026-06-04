#import "../utils.typ": *
#import "../figures/results/wmh/table_loss_combos.typ": wmhresults-table_loss_combos
#import "../figures/results/mets/table_loss_combos.typ": metsresults-table_loss_combos
#import "../figures/results/cv/table_loss_combos.typ": cvresults-table_loss_combos
#import "../figures/results/ag/table_loss_combos.typ": agresults-table_loss_combos
#import "../figures/results/mit/table_loss_combos.typ": mitresults-table_loss_combos
#import "../figures/results/cv/table_weight_maps.typ": cvresults-table_weight_maps
#import "../figures/results/ag/table_weight_maps.typ": agresults-table_weight_maps
#import "../figures/results/mit/table_weight_maps.typ": mitresults-table_weight_maps

#heading(numbering: none)[Appendix A: Additional Results]

#context text(size: 10pt)[
  #figure(metsresults-table_loss_combos(),
  caption: [Complete results table of the @mets dataset across various loss and weight combinations.
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

#context text(size: 10pt)[
  #figure(wmhresults-table_loss_combos(),
  caption: [Complete results table of the @wmh dataset across various loss and weight combinations.
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


#context text(size: 10pt)[
  #figure(cvresults-table_loss_combos(),
  caption: [Complete results table of the @cv dataset across various loss and weight combinations.
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

#context text(size: 10pt)[
  #figure(agresults-table_loss_combos(),
  caption: [Complete results table of the @ag dataset across various loss and weight combinations.
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

#context text(size: 10pt)[
  #figure(mitresults-table_loss_combos(),
  caption: [Complete results table of the @mit dataset across various loss and weight combinations.
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

#context text(size: 10pt)[
  #figure(cvresults-table_weight_maps(),
  caption: [@cv Weight maps
  ],
)<tabcvweightmaps>]

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

#context text(size: 10pt)[
  #figure(agresults-table_weight_maps(),
  caption: [@ag Weight maps
  ],
)<tabcvweightmaps>]


#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -15mm,

    // Top row
    image("../figures/results/cv/lollipop/weight_maps/DSC.png", width: 80%),
    image("../figures/results/cv/lollipop/weight_maps/F2.png", width: 80%),
    image("../figures/results/cv/lollipop/weight_maps/RQ.png", width: 80%),
    image("../figures/results/cv/lollipop/weight_maps/CCDice.png", width: 80%),
    image("../figures/results/cv/lollipop/weight_maps/SQDSC.png", width: 80%),
    image("../figures/results/cv/lollipop/weight_maps/SQASSD.png", width: 80%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/cv/lollipop/weight_maps/quartile_recall_comparison.png", width: 90%),
    ),
  ),
  caption: [Weight maps lollipop charts of canalicular vessel dataset. Improvements are shown in green over the baseline loss of standard global DiceCE. Bottom right shows instance recall deltas per volume quartile.
  ],
) <figcvresultslollipopweightmaps>

#context text(size: 10pt)[
  #figure(mitresults-table_weight_maps(),
  caption: [@mit Weight maps
  ],
)<tabmitweightmaps>]


#figure(
    grid(
    columns: 2,
    align: center + horizon,
    column-gutter: -15mm,

    // Top row
    image("../figures/results/mit/lollipop/weight_maps/DSC.png", width: 80%),
    image("../figures/results/mit/lollipop/weight_maps/F2.png", width: 80%),
    image("../figures/results/mit/lollipop/weight_maps/RQ.png", width: 80%),
    image("../figures/results/mit/lollipop/weight_maps/CCDice.png", width: 80%),
    image("../figures/results/mit/lollipop/weight_maps/SQDSC.png", width: 80%),
    image("../figures/results/mit/lollipop/weight_maps/SQASSD.png", width: 80%),

    grid.cell(
      colspan: 2,
      align: center,
    image("../figures/results/mit/lollipop/weight_maps/quartile_recall_comparison.png", width: 90%),
    ),
  ),
  caption: [Weight maps lollipop charts of @mit dataset. Improvements are shown in green over the baseline loss of standard global DiceCE. Bottom right shows instance recall deltas per volume quartile.
  ],
) <figcvresultslollipopweightmaps>