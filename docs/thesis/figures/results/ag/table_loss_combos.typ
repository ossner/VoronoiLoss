#import "../../../utils.typ": *
#let agresults-table_loss_combos() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 8),
  align: (left, center, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 1pt + luma(220),
  ),
  inset: 5pt,
  table.vline(start: 0, stroke: 1.5pt + datasetcolors.at(3)),
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

  table.hline(start: 0, stroke: 1.5pt + luma(150)),

  // test/global/dice
  [DSC],
  [0.813],
  [#delta(+0.008)],
  [#text(size: 10.5pt)[*#delta(+0.008)*]],
  [#delta(-0.000)],
  [#delta(-0.004)],
  [#delta(-0.005)],
  [#delta(-0.000)],

  // test/global/F2
  [$F_2$],
  [0.821],
  [#text(size: 10.5pt)[*#delta(+0.030)*]],
  [#delta(+0.010)],
  [#delta(+0.003)],
  [#delta(+0.001)],
  [#delta(+0.012)],
  [#delta(+0.025)],

  // test/global/precision
  [precision],
  [#text(size: 10.5pt)[*0.838*]],
  [#delta(-0.031)],
  [#delta(-0.006)],
  [#delta(-0.012)],
  [#delta(-0.010)],
  [#delta(-0.035)],
  [#delta(-0.050)],

  // test/global/recall
  [recall],
  [0.817],
  [#text(size: 10.5pt)[*#delta(+0.046)*]],
  [#delta(+0.014)],
  [#delta(+0.006)],
  [#delta(+0.004)],
  [#delta(+0.024)],
  [#delta(+0.045)],

  // test/instance/f1
  [RQ],
  [0.746],
  [#delta(-0.010)],
  [#delta(-0.004)],
  [#text(size: 10.5pt)[*#delta(+0.028)*]],
  [#delta(+0.000)],
  [#delta(-0.006)],
  [#delta(+0.005)],

  // test/instance/dice
  [SQDSC],
  [0.850],
  [#delta(-0.001)],
  [#delta(-0.009)],
  [#delta(-0.015)],
  [#text(size: 10.5pt)[*#delta(+0.001)*]],
  [#delta(-0.014)],
  [#delta(-0.007)],

  // test/instance/assd
  [SQASSD],
  [0.386],
  [#deltainv(-0.010)],
  [#deltainv(+0.043)],
  [#deltainv(+0.037)],
  [#text(size: 10.5pt)[*#deltainv(-0.031)*]],
  [#deltainv(+0.083)],
  [#deltainv(+0.093)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [#text(size: 10.5pt)[*0.737*]],
  [#delta(-0.096)],
  [#delta(-0.048)],
  [#delta(-0.001)],
  [#delta(-0.042)],
  [#delta(-0.053)],
  [#delta(-0.044)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.770],
  [#text(size: 10.5pt)[*#delta(+0.105)*]],
  [#delta(+0.050)],
  [#delta(+0.062)],
  [#delta(+0.050)],
  [#delta(+0.062)],
  [#delta(+0.058)],

  // test/cc/dice
  [CCDice],
  [0.630],
  [#text(size: 10.5pt)[*#delta(+0.065)*]],
  [#delta(+0.028)],
  [#delta(+0.030)],
  [#delta(+0.030)],
  [#delta(+0.031)],
  [#delta(+0.040)],
)