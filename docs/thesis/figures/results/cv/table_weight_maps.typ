#import "../../../utils.typ": *
#let cvresults-table_weight_maps() = table(
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
  [#text(size: 10.5pt)[*#delta(+0.005)*]],
  [#delta(+0.004)],
  [#delta(-0.019)],

  // test/global/F2
  [$F_2$],
  [0.777],
  [#text(size: 10.5pt)[*#delta(+0.075)*]],
  [#delta(-0.009)],
  [#delta(+0.007)],
  [#delta(+0.014)],
  [#delta(+0.067)],

  // test/instance/f1
  [RQ],
  [#text(size: 10.5pt)[*0.875*]],
  [#delta(-0.081)],
  [#delta(-0.005)],
  [#delta(-0.002)],
  [#delta(-0.030)],
  [#delta(-0.031)],

  // test/instance/dice
  [SQDSC],
  [0.812],
  [#delta(-0.033)],
  [#delta(-0.003)],
  [#delta(+0.004)],
  [#text(size: 10.5pt)[*#delta(+0.007)*]],
  [#delta(-0.024)],

  // test/instance/assd
  [SQASSD],
  [0.392],
  [#deltainv(+0.201)],
  [#deltainv(+0.011)],
  [#deltainv(-0.000)],
  [#text(size: 10.5pt)[*#deltainv(-0.027)*]],
  [#deltainv(+0.178)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.843],
  [#delta(-0.127)],
  [#text(size: 10.5pt)[*#delta(+0.000)*]],
  [#delta(-0.000)],
  [#delta(-0.059)],
  [#delta(-0.028)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.913],
  [#delta(-0.017)],
  [#delta(-0.012)],
  [#delta(-0.005)],
  [#text(size: 10.5pt)[*#delta(+0.007)*]],
  [#delta(-0.035)],

  // test/instance/recall_q0
  [$"recall"_"inst"_"Q1"$],
  [0.733],
  [#text(size: 10.5pt)[*#delta(+0.065)*]],
  [#delta(-0.009)],
  [#delta(-0.009)],
  [#delta(+0.029)],
  [#delta(+0.015)],

  // test/instance/recall_q1
  [$"recall"_"inst"_"Q2"$],
  [#text(size: 10.5pt)[*0.955*]],
  [#delta(-0.004)],
  [#delta(-0.045)],
  [#delta(-0.022)],
  [#delta(-0.009)],
  [#delta(-0.038)],

  // test/instance/recall_q2
  [$"recall"_"inst"_"Q3"$],
  [0.943],
  [#delta(-0.006)],
  [#delta(+0.005)],
  [#text(size: 10.5pt)[*#delta(+0.016)*]],
  [#delta(+0.005)],
  [#delta(-0.024)],

  // test/instance/recall_q3
  [$"recall"_"inst"_"Q4"$],
  [0.983],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],
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
  [#text(size: 10.5pt)[*#delta(+0.006)*]],
  [#delta(-0.018)],

  // test/global/precision
  [precision],
  [0.847],
  [#delta(-0.181)],
  [#delta(+0.000)],
  [#text(size: 10.5pt)[*#delta(+0.001)*]],
  [#delta(-0.015)],
  [#delta(-0.145)],

  // test/global/recall
  [recall],
  [0.762],
  [#text(size: 10.5pt)[*#delta(+0.155)*]],
  [#delta(-0.011)],
  [#delta(+0.008)],
  [#delta(+0.020)],
  [#delta(+0.128)],
)