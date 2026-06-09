#import "../../../utils.typ": *
#let cvresults-table_loss_combos() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 8),
  align: (left, center, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 0.4pt + luma(220),
  ),
  inset: 8pt,

  table.header(
    [],
    [DiceCE, none],
    [none, DiceCE],
    [DiceCE, DiceCE],
    [2*DiceCE, DiceCE],
    [DiceCE, 2*DiceCE],
    [DiceCE, DiceTversky],
    [CETversky, DiceTversky],
  ),

  // test/global/dice
  [DSC],
  [0.804],
  [#delta(+0.009)],
  [#delta(+0.007)],
  [#delta(+0.008)],
  [#delta(+0.014)],
  [#delta(+0.011)],
  [#text(size: 10.5pt)[*#delta(+0.018)*]],

  // test/global/F2
  [$F_2$],
  [0.777],
  [#delta(+0.019)],
  [#delta(+0.009)],
  [#delta(+0.010)],
  [#delta(+0.021)],
  [#delta(+0.028)],
  [#text(size: 10.5pt)[*#delta(+0.043)*]],

  // test/instance/f1
  [RQ],
  [0.875],
  [#delta(+0.001)],
  [#delta(+0.002)],
  [#delta(+0.002)],
  [#text(size: 10.5pt)[*#delta(+0.008)*]],
  [#delta(+0.005)],
  [#delta(-0.000)],

  // test/instance/dice
  [SQDSC],
  [0.812],
  [#delta(+0.025)],
  [#delta(+0.012)],
  [#delta(+0.015)],
  [#delta(+0.016)],
  [#delta(+0.018)],
  [#text(size: 10.5pt)[*#delta(+0.028)*]],

  // test/instance/assd
  [SQASSD],
  [0.392],
  [#text(size: 10.5pt)[*#deltainv(-0.079)*]],
  [#deltainv(-0.020)],
  [#deltainv(-0.040)],
  [#deltainv(-0.055)],
  [#deltainv(-0.026)],
  [#deltainv(-0.072)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.913],
  [#delta(-0.002)],
  [#delta(-0.001)],
  [#delta(-0.003)],
  [#text(size: 10.5pt)[*#delta(+0.011)*]],
  [#delta(+0.006)],
  [#delta(-0.002)],

  // test/instance/recall_Q1
  [$"recall"_"inst"_"Q1"$],
  [0.733],
  [#delta(+0.041)],
  [#delta(-0.001)],
  [#delta(+0.001)],
  [#delta(+0.036)],
  [#text(size: 10.5pt)[*#delta(+0.058)*]],
  [#delta(+0.033)],

  // test/instance/recall_Q2
  [$"recall"_"inst"_"Q2"$],
  [0.955],
  [#delta(+0.003)],
  [#delta(-0.015)],
  [#delta(-0.030)],
  [#text(size: 10.5pt)[*#delta(+0.004)*]],
  [#text(size: 10.5pt)[*#delta(+0.004)*]],
  [#delta(-0.013)],

  // test/instance/recall_Q3
  [$"recall"_"inst"_"Q3"$],
  [0.943],
  [#delta(-0.011)],
  [#delta(-0.002)],
  [#delta(-0.002)],
  [#delta(+0.006)],
  [#text(size: 10.5pt)[*#delta(+0.007)*]],
  [#delta(-0.001)],

  // test/instance/recall_Q4
  [$"recall"_"inst"_"Q4"$],
  [#text(size: 10.5pt)[*0.983*]],
  [#delta(-0.021)],
  [#delta(-0.003)],
  [#delta(-0.005)],
  [#delta(-0.003)],
  [#delta(-0.009)],
  [#delta(-0.008)],

  // test/instance/SQDSC_Q1
  [SQDSC_Q1],
  [0.692],
  [#text(size: 10.5pt)[*#delta(+0.072)*]],
  [#delta(+0.055)],
  [#delta(+0.036)],
  [#delta(+0.042)],
  [#delta(+0.027)],
  [#delta(+0.061)],

  // test/instance/SQDSC_Q2
  [SQDSC_Q2],
  [0.797],
  [#delta(+0.004)],
  [#delta(-0.005)],
  [#text(size: 10.5pt)[*#delta(+0.022)*]],
  [#delta(+0.014)],
  [#delta(+0.009)],
  [#delta(+0.009)],

  // test/instance/SQDSC_Q3
  [SQDSC_Q3],
  [0.837],
  [#delta(+0.015)],
  [#delta(+0.006)],
  [#delta(+0.006)],
  [#delta(+0.003)],
  [#delta(-0.000)],
  [#text(size: 10.5pt)[*#delta(+0.019)*]],

  // test/instance/SQDSC_Q4
  [SQDSC_Q4],
  [0.851],
  [#text(size: 10.5pt)[*#delta(+0.029)*]],
  [#delta(+0.013)],
  [#delta(+0.015)],
  [#delta(+0.025)],
  [#delta(+0.027)],
  [#delta(+0.029)],

  // test/cc/dice
  [CCDice],
  [0.726],
  [#delta(+0.021)],
  [#delta(+0.009)],
  [#delta(+0.010)],
  [#delta(+0.019)],
  [#delta(+0.019)],
  [#text(size: 10.5pt)[*#delta(+0.025)*]],

  // test/global/precision
  [precision],
  [0.847],
  [#delta(-0.007)],
  [#delta(+0.003)],
  [#text(size: 10.5pt)[*#delta(+0.005)*]],
  [#delta(+0.002)],
  [#delta(-0.019)],
  [#delta(-0.027)],

  // test/global/recall
  [recall],
  [0.762],
  [#delta(+0.024)],
  [#delta(+0.010)],
  [#delta(+0.011)],
  [#delta(+0.025)],
  [#delta(+0.038)],
  [#text(size: 10.5pt)[*#delta(+0.059)*]],

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.843],
  [#delta(+0.002)],
  [#delta(+0.004)],
  [#text(size: 10.5pt)[*#delta(+0.006)*]],
  [#delta(+0.004)],
  [#delta(+0.003)],
  [#delta(+0.001)],
)