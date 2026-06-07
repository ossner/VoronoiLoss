#import "../../../utils.typ": *
#let metsresults-table_weight_maps() = table(
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
  [0.465],
  [#delta(-0.422)],
  [#text(size: 10.5pt)[*#delta(+0.011)*]],
  [#delta(+0.002)],
  [#delta(-0.011)],
  [#delta(-0.004)],

  // test/global/F2
  [$F_2$],
  [0.479],
  [#delta(-0.368)],
  [#delta(-0.009)],
  [#delta(-0.040)],
  [#delta(+0.021)],
  [#text(size: 10.5pt)[*#delta(+0.070)*]],

  // test/instance/f1
  [RQ],
  [0.685],
  [#delta(-0.654)],
  [#delta(-0.045)],
  [#delta(+0.034)],
  [#delta(-0.193)],
  [#text(size: 10.5pt)[*#delta(+0.051)*]],

  // test/instance/dice
  [SQDSC],
  [0.458],
  [#delta(-0.224)],
  [#delta(-0.004)],
  [#delta(+0.006)],
  [#delta(+0.055)],
  [#text(size: 10.5pt)[*#delta(+0.057)*]],

  // test/instance/assd
  [SQASSD],
  [0.802],
  [#deltainv(+2.282)],
  [#deltainv(+0.038)],
  [#deltainv(+0.042)],
  [#text(size: 10.5pt)[*#deltainv(-0.004)*]],
  [#deltainv(+0.114)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.875],
  [#delta(-0.858)],
  [#delta(-0.109)],
  [#text(size: 10.5pt)[*#delta(+0.043)*]],
  [#delta(-0.484)],
  [#delta(-0.124)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.648],
  [#text(size: 10.5pt)[*#delta(+0.307)*]],
  [#delta(-0.025)],
  [#delta(+0.011)],
  [#delta(+0.218)],
  [#delta(+0.108)],

  // test/instance/recall_q0
  [$"recall"_"inst"_"Q1"$],
  [0.250],
  [#text(size: 10.5pt)[*#delta(+0.750)*]],
  [#delta(-0.125)],
  [#delta(-0.125)],
  [#delta(+0.438)],
  [#delta(+0.000)],

  // test/instance/recall_q1
  [$"recall"_"inst"_"Q2"$],
  [0.444],
  [#text(size: 10.5pt)[*#delta(+0.519)*]],
  [#delta(-0.028)],
  [#delta(-0.083)],
  [#delta(+0.389)],
  [#delta(+0.157)],

  // test/instance/recall_q2
  [$"recall"_"inst"_"Q3"$],
  [0.758],
  [#text(size: 10.5pt)[*#delta(+0.225)*]],
  [#delta(+0.000)],
  [#delta(+0.024)],
  [#delta(+0.118)],
  [#delta(+0.028)],

  // test/instance/recall_q3
  [$"recall"_"inst"_"Q4"$],
  [0.980],
  [#delta(-0.028)],
  [#text(size: 10.5pt)[*#delta(+0.010)*]],
  [#delta(-0.010)],
  [#delta(+0.000)],
  [#delta(-0.010)],

  // test/cc/dice
  [CCDice],
  [0.358],
  [#delta(-0.314)],
  [#delta(-0.028)],
  [#delta(-0.007)],
  [#text(size: 10.5pt)[*#delta(+0.025)*]],
  [#delta(+0.015)],

  // test/global/precision
  [precision],
  [0.709],
  [#delta(-0.685)],
  [#text(size: 10.5pt)[*#delta(+0.042)*]],
  [#delta(+0.041)],
  [#delta(-0.146)],
  [#delta(-0.267)],

  // test/global/recall
  [recall],
  [0.443],
  [#text(size: 10.5pt)[*#delta(+0.517)*]],
  [#delta(-0.014)],
  [#delta(-0.045)],
  [#delta(+0.044)],
  [#delta(+0.141)],
)