#import "../../../utils.typ": *
#let agresults-table_weight_maps() = table(
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
  [#text(size: 10.5pt)[*#delta(+0.013)*]],
  [#delta(-0.012)],
  [#delta(-0.025)],

  // test/global/F2
  [$F_2$],
  [0.821],
  [#delta(+0.019)],
  [#delta(+0.003)],
  [#delta(+0.008)],
  [#delta(+0.008)],
  [#text(size: 10.5pt)[*#delta(+0.031)*]],

  // test/instance/f1
  [RQ],
  [0.746],
  [#delta(-0.107)],
  [#delta(+0.014)],
  [#text(size: 10.5pt)[*#delta(+0.032)*]],
  [#delta(-0.066)],
  [#delta(-0.030)],

  // test/instance/dice
  [SQDSC],
  [0.850],
  [#delta(-0.044)],
  [#text(size: 10.5pt)[*#delta(+0.001)*]],
  [#delta(-0.005)],
  [#delta(-0.036)],
  [#delta(-0.069)],

  // test/instance/assd
  [SQASSD],
  [0.386],
  [#deltainv(+0.376)],
  [#text(size: 10.5pt)[*#deltainv(-0.002)*]],
  [#deltainv(+0.053)],
  [#deltainv(+0.187)],
  [#deltainv(+0.687)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.737],
  [#delta(-0.213)],
  [#delta(+0.005)],
  [#text(size: 10.5pt)[*#delta(+0.034)*]],
  [#delta(-0.151)],
  [#delta(-0.046)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.770],
  [#text(size: 10.5pt)[*#delta(+0.073)*]],
  [#delta(+0.016)],
  [#delta(+0.024)],
  [#delta(+0.059)],
  [#delta(-0.016)],

  // test/instance/recall_q0
  [$"recall"_"inst"_"Q1"$],
  [0.360],
  [#text(size: 10.5pt)[*#delta(+0.215)*]],
  [#delta(+0.040)],
  [#delta(-0.024)],
  [#delta(+0.133)],
  [#delta(+0.137)],

  // test/instance/recall_q1
  [$"recall"_"inst"_"Q2"$],
  [0.882],
  [#text(size: 10.5pt)[*#delta(+0.093)*]],
  [#delta(-0.028)],
  [#delta(+0.038)],
  [#delta(+0.084)],
  [#delta(+0.021)],

  // test/instance/recall_q2
  [$"recall"_"inst"_"Q3"$],
  [0.939],
  [#text(size: 10.5pt)[*#delta(+0.061)*]],
  [#delta(+0.031)],
  [#delta(+0.031)],
  [#delta(+0.051)],
  [#delta(+0.001)],

  // test/instance/recall_q3
  [$"recall"_"inst"_"Q4"$],
  [0.983],
  [#delta(+0.000)],
  [#delta(+0.000)],
  [#text(size: 10.5pt)[*#delta(+0.017)*]],
  [#delta(+0.000)],
  [#delta(-0.019)],

  // test/cc/dice
  [CCDice],
  [0.630],
  [#delta(+0.009)],
  [#delta(+0.005)],
  [#delta(+0.017)],
  [#text(size: 10.5pt)[*#delta(+0.017)*]],
  [#delta(+0.005)],

  // test/global/precision
  [precision],
  [0.838],
  [#delta(-0.163)],
  [#delta(-0.008)],
  [#text(size: 10.5pt)[*#delta(+0.008)*]],
  [#delta(-0.040)],
  [#delta(-0.129)],

  // test/global/recall
  [recall],
  [0.817],
  [#delta(+0.079)],
  [#delta(+0.006)],
  [#delta(+0.008)],
  [#delta(+0.021)],
  [#text(size: 10.5pt)[*#delta(+0.080)*]],
)