#import "../../../utils.typ": *
#let mitresults-table_weight_maps() = table(
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
  [0.944],
  [#delta(-0.013)],
  [#delta(-0.003)],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],
  [#delta(-0.007)],
  [#delta(-0.017)],

  // test/global/F2
  [$F_2$],
  [0.943],
  [#text(size: 10.5pt)[*#delta(+0.018)*]],
  [#delta(-0.004)],
  [#delta(+0.001)],
  [#delta(-0.002)],
  [#delta(+0.015)],

  // test/instance/f1
  [RQ],
  [0.907],
  [#delta(-0.062)],
  [#delta(-0.004)],
  [#text(size: 10.5pt)[*#delta(+0.021)*]],
  [#delta(-0.047)],
  [#delta(+0.012)],

  // test/instance/dice
  [SQDSC],
  [0.939],
  [#delta(-0.014)],
  [#delta(-0.007)],
  [#text(size: 10.5pt)[*#delta(+0.002)*]],
  [#delta(-0.001)],
  [#delta(-0.021)],

  // test/instance/assd
  [SQASSD],
  [0.151],
  [#deltainv(+0.013)],
  [#deltainv(+0.018)],
  [#text(size: 10.5pt)[*#deltainv(-0.016)*]],
  [#deltainv(-0.006)],
  [#deltainv(+0.046)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.873],
  [#delta(-0.119)],
  [#delta(-0.014)],
  [#text(size: 10.5pt)[*#delta(+0.027)*]],
  [#delta(-0.091)],
  [#delta(+0.013)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.962],
  [#text(size: 10.5pt)[*#delta(+0.027)*]],
  [#delta(+0.006)],
  [#delta(+0.008)],
  [#delta(+0.021)],
  [#delta(+0.005)],

  // test/instance/recall_q0
  [$"recall"_"inst"_"Q1"$],
  [0.863],
  [#text(size: 10.5pt)[*#delta(+0.091)*]],
  [#delta(+0.031)],
  [#delta(+0.023)],
  [#delta(+0.077)],
  [#delta(+0.008)],

  // test/instance/recall_q1
  [$"recall"_"inst"_"Q2"$],
  [0.997],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],
  [#delta(-0.008)],
  [#delta(-0.004)],
  [#delta(-0.004)],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],

  // test/instance/recall_q2
  [$"recall"_"inst"_"Q3"$],
  [#text(size: 10.5pt)[*1.000*]],
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

  // test/cc/dice
  [CCDice],
  [0.896],
  [#delta(+0.007)],
  [#delta(-0.002)],
  [#delta(+0.010)],
  [#text(size: 10.5pt)[*#delta(+0.013)*]],
  [#delta(-0.012)],

  // test/global/precision
  [precision],
  [0.948],
  [#delta(-0.064)],
  [#delta(-0.001)],
  [#text(size: 10.5pt)[*#delta(+0.005)*]],
  [#delta(-0.012)],
  [#delta(-0.067)],

  // test/global/recall
  [recall],
  [0.942],
  [#text(size: 10.5pt)[*#delta(+0.041)*]],
  [#delta(-0.004)],
  [#delta(+0.000)],
  [#delta(+0.000)],
  [#delta(+0.038)],
)