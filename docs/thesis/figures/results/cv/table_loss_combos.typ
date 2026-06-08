#import "../../../utils.typ": *
#let cvresults-table_loss_combos() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 8),
  align: (left, center, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 1pt + luma(220),
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

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.843],
  [#delta(+0.002)],
  [#delta(+0.004)],
  [#text(size: 10.5pt)[*#delta(+0.006)*]],
  [#delta(+0.004)],
  [#delta(+0.003)],
  [#delta(+0.001)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.913],
  [#delta(-0.002)],
  [#delta(-0.001)],
  [#delta(-0.003)],
  [#text(size: 10.5pt)[*#delta(+0.011)*]],
  [#delta(+0.006)],
  [#delta(-0.002)],

  // test/cc/dice
  [CCDice],
  [0.726],
  [#delta(+0.021)],
  [#delta(+0.009)],
  [#delta(+0.010)],
  [#delta(+0.019)],
  [#delta(+0.019)],
  [#text(size: 10.5pt)[*#delta(+0.025)*]],
)