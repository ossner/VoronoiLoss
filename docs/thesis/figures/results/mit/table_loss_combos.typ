#import "../../../utils.typ": *
#let mitresults-table_loss_combos() = table(
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
  [0.944],
  [#text(size: 10.5pt)[*#delta(+0.001)*]],
  [#delta(-0.000)],
  [#delta(-0.005)],
  [#delta(+0.001)],
  [#delta(+0.000)],
  [#delta(-0.003)],

  // test/global/F2
  [$F_2$],
  [0.943],
  [#delta(+0.009)],
  [#delta(+0.005)],
  [#delta(-0.001)],
  [#delta(+0.007)],
  [#delta(+0.009)],
  [#text(size: 10.5pt)[*#delta(+0.014)*]],

  // test/instance/f1
  [RQ],
  [#text(size: 10.5pt)[*0.907*]],
  [#delta(-0.023)],
  [#delta(-0.006)],
  [#delta(-0.022)],
  [#delta(-0.036)],
  [#delta(-0.008)],
  [#delta(-0.026)],

  // test/instance/dice
  [SQDSC],
  [0.939],
  [#text(size: 10.5pt)[*#delta(+0.010)*]],
  [#delta(+0.009)],
  [#delta(+0.006)],
  [#delta(+0.008)],
  [#delta(+0.007)],
  [#delta(+0.007)],

  // test/instance/assd
  [SQASSD],
  [0.151],
  [#deltainv(-0.057)],
  [#text(size: 10.5pt)[*#deltainv(-0.058)*]],
  [#deltainv(-0.049)],
  [#deltainv(-0.055)],
  [#deltainv(-0.033)],
  [#deltainv(-0.033)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [#text(size: 10.5pt)[*0.873*]],
  [#delta(-0.053)],
  [#delta(-0.018)],
  [#delta(-0.042)],
  [#delta(-0.068)],
  [#delta(-0.026)],
  [#delta(-0.053)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.962],
  [#text(size: 10.5pt)[*#delta(+0.025)*]],
  [#delta(+0.014)],
  [#delta(+0.011)],
  [#delta(+0.020)],
  [#delta(+0.017)],
  [#delta(+0.018)],

  // test/instance/recall_q0
  [$"recall"_"inst"_"Q1"$],
  [0.863],
  [#text(size: 10.5pt)[*#delta(+0.087)*]],
  [#delta(+0.046)],
  [#delta(+0.043)],
  [#delta(+0.072)],
  [#delta(+0.053)],
  [#delta(+0.066)],

  // test/instance/recall_q1
  [$"recall"_"inst"_"Q2"$],
  [0.997],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],
  [#delta(-0.004)],
  [#delta(-0.006)],
  [#delta(-0.004)],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],
  [#delta(-0.004)],

  // test/instance/recall_q2
  [$"recall"_"inst"_"Q3"$],
  [#text(size: 10.5pt)[*1.000*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],

  // test/instance/recall_q3
  [$"recall"_"inst"_"Q4"$],
  [#text(size: 10.5pt)[*1.000*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],

  // test/cc/dice
  [CCDice],
  [0.896],
  [#text(size: 10.5pt)[*#delta(+0.027)*]],
  [#delta(+0.017)],
  [#delta(+0.011)],
  [#delta(+0.021)],
  [#delta(+0.018)],
  [#delta(+0.018)],

  // test/global/precision
  [precision],
  [#text(size: 10.5pt)[*0.948*]],
  [#delta(-0.011)],
  [#delta(-0.006)],
  [#delta(-0.008)],
  [#delta(-0.007)],
  [#delta(-0.013)],
  [#delta(-0.027)],

  // test/global/recall
  [recall],
  [0.942],
  [#delta(+0.015)],
  [#delta(+0.008)],
  [#delta(+0.001)],
  [#delta(+0.010)],
  [#delta(+0.015)],
  [#text(size: 10.5pt)[*#delta(+0.024)*]],
)