#import "../utils.typ": *
#import "../figures/results/wmh/table_loss_combos.typ": wmhresults-table_loss_combos
#import "../figures/results/mets/table_loss_combos.typ": metsresults-table_loss_combos
#import "../figures/results/cv/table_loss_combos.typ": cvresults-table_loss_combos
#import "../figures/results/ag/table_loss_combos.typ": agresults-table_loss_combos
#import "../figures/results/mit/table_loss_combos.typ": mitresults-table_loss_combos
#import "../figures/results/cv/table_weight_maps.typ": cvresults-table_weight_maps
#import "../figures/results/ag/table_weight_maps.typ": agresults-table_weight_maps
#import "../figures/results/mit/table_weight_maps.typ": mitresults-table_weight_maps

#heading(numbering: "A - ")[Supplementary Materials] <Appendix_A>

This appendix provides additional results, tables and charts for deeper examination. All metrics, datasets and abbreviations introduced in the main text are used without modification.

  #figure(metsresults-table_loss_combos(),
  caption: [Complete results table of the @mets dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligeable changes in metrics are shown in gray and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabmetslosscombos>

#figure(
    image("../figures/results/mets/lollipop/loss_combos/quartile_SQDSC_comparison.png", width: 95%),
  caption: [Loss combination lollipop charts of @mets dataset measuring @sqdsc by instance volume quartiles. Baseline values for each quartile are given by dashed lines. Improvements are shown in green over the baseline loss of standard global DiceCE.
  ],
) <figmetsresultslollipopsqdsc>

// #figure(
//     grid(
//     columns: 2,
//     align: center + horizon,
//     column-gutter: -15mm,

//     // Top row
//     image("../figures/results/mets/lollipop/loss_combos/DSC.png", width: 80%),
//     image("../figures/results/mets/lollipop/loss_combos/F2.png", width: 80%),
//     image("../figures/results/mets/lollipop/loss_combos/RQ.png", width: 80%),
//     image("../figures/results/mets/lollipop/loss_combos/CCDice.png", width: 80%),
//     image("../figures/results/mets/lollipop/loss_combos/SQDSC.png", width: 80%),
//     image("../figures/results/mets/lollipop/loss_combos/SQASSD.png", width: 80%),
//   ),
//   caption: [Loss combination lollipop charts of @mets dataset. Improvements are shown in green over the baseline loss of standard global DiceCE.
//   ],
// ) <figmetsresultslollipoplosscombos>

  #figure(wmhresults-table_loss_combos(),
  caption: [Complete results table of the @wmh dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligeable changes in metrics are shown in gray and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabwmhlosscombos>

#figure(
    image("../figures/results/wmh/lollipop/loss_combos/quartile_SQDSC_comparison.png", width: 95%),
  caption: [Loss combination lollipop charts of @wmh dataset measuring @sqdsc by instance volume quartiles. Baseline values for each quartile are given by dashed lines. Improvements are shown in green over the baseline loss of standard global DiceCE.
  ],
) <figwmhresultslollipopsqdsc>

// #figure(
//     grid(
//     columns: 2,
//     align: center + horizon,
//     column-gutter: -15mm,

//     // Top row
//     image("../figures/results/wmh/lollipop/loss_combos/DSC.png", width: 80%),
//     image("../figures/results/wmh/lollipop/loss_combos/F2.png", width: 80%),
//     image("../figures/results/wmh/lollipop/loss_combos/RQ.png", width: 80%),
//     image("../figures/results/wmh/lollipop/loss_combos/CCDice.png", width: 80%),
//     image("../figures/results/wmh/lollipop/loss_combos/SQDSC.png", width: 80%),
//     image("../figures/results/wmh/lollipop/loss_combos/SQASSD.png", width: 80%),

//     grid.cell(
//       colspan: 2,
//       align: center,
//     image("../figures/results/wmh/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
//     ),
//   ),
//   caption: [Loss combination lollipop charts of @wmh dataset. Improvements are shown in green over the baseline loss of standard global DiceCE.
//   ],
// ) <figwmhresultslollipoplosscombos>


  #figure(cvresults-table_loss_combos(),
  caption: [Complete results table of the @cv dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligeable changes in metrics are shown in gray and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabcvlosscombos>

#figure(
    image("../figures/results/cv/lollipop/loss_combos/quartile_SQDSC_comparison.png", width: 95%),
  caption: [Loss combination lollipop charts of @cv dataset measuring @sqdsc by instance volume quartiles. Baseline values for each quartile are given by dashed lines. Improvements are shown in green over the baseline loss of standard global DiceCE.
  ],
) <figcvresultslollipopsqdsc>

// #figure(
//     grid(
//     columns: 2,
//     align: center + horizon,
//     column-gutter: -15mm,

//     // Top row
//     image("../figures/results/cv/lollipop/loss_combos/DSC.png", width: 80%),
//     image("../figures/results/cv/lollipop/loss_combos/F2.png", width: 80%),
//     image("../figures/results/cv/lollipop/loss_combos/RQ.png", width: 80%),
//     image("../figures/results/cv/lollipop/loss_combos/CCDice.png", width: 80%),
//     image("../figures/results/cv/lollipop/loss_combos/SQDSC.png", width: 80%),
//     image("../figures/results/cv/lollipop/loss_combos/SQASSD.png", width: 80%),

//     grid.cell(
//       colspan: 2,
//       align: center,
//     image("../figures/results/cv/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
//     ),
//   ),
//   caption: [Loss combination lollipop charts of @cv dataset. Improvements are shown in green over the baseline loss of standard global DiceCE.
//   ],
// ) <figcvresultslollipoplosscombos>

  #figure(agresults-table_loss_combos(),
  caption: [Complete results table of the @ag dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligeable changes in metrics are shown in gray and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabaglosscombos>


#figure(
    image("../figures/results/ag/lollipop/loss_combos/quartile_SQDSC_comparison.png", width: 95%),
  caption: [Loss combination lollipop charts of @ag dataset measuring @sqdsc by instance volume quartiles. Baseline values for each quartile are given by dashed lines. Improvements are shown in green over the baseline loss of standard global DiceCE.
  ],
) <figagresultslollipopsqdsc>

// #figure(
//     grid(
//     columns: 2,
//     align: center + horizon,
//     column-gutter: -15mm,

//     // Top row
//     image("../figures/results/ag/lollipop/loss_combos/DSC.png", width: 80%),
//     image("../figures/results/ag/lollipop/loss_combos/F2.png", width: 80%),
//     image("../figures/results/ag/lollipop/loss_combos/RQ.png", width: 80%),
//     image("../figures/results/ag/lollipop/loss_combos/CCDice.png", width: 80%),
//     image("../figures/results/ag/lollipop/loss_combos/SQDSC.png", width: 80%),
//     image("../figures/results/ag/lollipop/loss_combos/SQASSD.png", width: 80%),

//     grid.cell(
//       colspan: 2,
//       align: center,
//     image("../figures/results/ag/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
//     ),
//   ),
//   caption: [Loss combination lollipop charts of @ag dataset. Improvements are shown in green over the baseline loss of standard global DiceCE.],
// ) <figagresultslollipoplosscombos>

  #figure(mitresults-table_loss_combos(),
  caption: [Complete results table of the @mit dataset across various loss and weight combinations. All results are evaluated against a global-only DiceCE loss and their relative changes are reported. Improvements over the baseline are shown in green, negligeable changes in metrics are shown in gray and worsening metrics in red. The best result for each metric is emphasized in bold.
  ],
)<tabmitlosscombos>


#figure(
    image("../figures/results/mit/lollipop/loss_combos/quartile_SQDSC_comparison.png", width: 95%),
  caption: [Loss combination lollipop charts of @mit dataset measuring @sqdsc by instance volume quartiles. Baseline values for each quartile are given by dashed lines. Improvements are shown in green over the baseline loss of standard global DiceCE.
  ],
) <figmitresultslollipopsqdsc>


// #figure(
//     grid(
//     columns: 2,
//     align: center + horizon,
//     column-gutter: -15mm,

//     // Top row
//     image("../figures/results/mit/lollipop/loss_combos/DSC.png", width: 80%),
//     image("../figures/results/mit/lollipop/loss_combos/F2.png", width: 80%),
//     image("../figures/results/mit/lollipop/loss_combos/RQ.png", width: 80%),
//     image("../figures/results/mit/lollipop/loss_combos/CCDice.png", width: 80%),
//     image("../figures/results/mit/lollipop/loss_combos/SQDSC.png", width: 80%),
//     image("../figures/results/mit/lollipop/loss_combos/SQASSD.png", width: 80%),

//     grid.cell(
//       colspan: 2,
//       align: center,
//     image("../figures/results/mit/lollipop/loss_combos/quartile_recall_comparison.png", width: 90%),
//     ),
//   ),
//   caption: [Loss combination lollipop charts of @mit dataset. Improvements are shown in green over the baseline loss of standard global DiceCE.
//   ],
// ) <figmitresultslollipoplosscombos>
