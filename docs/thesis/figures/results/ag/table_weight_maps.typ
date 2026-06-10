#import "../../../utils.typ": *
#let agresults-table_weight_maps() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 7),
  align: (left, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 1pt + luma(220),
  ),
  inset: 5pt,
  table.vline(start: 0, stroke: 1.5pt + datasetcolors.at(3)),
  table.header(
    [],
      [$W_"none"$],
     [$W_"v_iw"$],
     [$W_"v_region"$],
     [$W_"v_adaptive"$],
     [$W_"v_mountains"$],
     [$W_"v_islands"$],
  ),

  table.hline(start: 0, stroke: 1.5pt + luma(150)),

  // test/global/dice
  [DSC],
  [0.813],
  [#delta(-0.058)],
  [#delta(-0.003)],
  [#text(size: 9pt)[*#delta(+0.012)*]],
  [#delta(-0.012)],
  [#delta(-0.025)],

  // test/global/F2
  [$F_2$],
  [0.821],
  [#delta(+0.019)],
  [#delta(+0.003)],
  [#delta(+0.005)],
  [#delta(+0.008)],
  [#text(size: 9pt)[*#delta(+0.031)*]],

  // test/global/precision
  [precision],
  [0.838],
  [#delta(-0.163)],
  [#delta(-0.008)],
  [#text(size: 9pt)[*#delta(+0.010)*]],
  [#delta(-0.040)],
  [#delta(-0.129)],

  // test/global/recall
  [recall],
  [0.817],
  [#delta(+0.079)],
  [#delta(+0.006)],
  [#delta(+0.004)],
  [#delta(+0.021)],
  [#text(size: 9pt)[*#delta(+0.080)*]],

  // test/instance/f1
  [RQ],
  [0.746],
  [#delta(-0.107)],
  [#delta(+0.014)],
  [#text(size: 9pt)[*#delta(+0.022)*]],
  [#delta(-0.066)],
  [#delta(-0.030)],

  // test/instance/dice
  [SQDSC],
  [0.850],
  [#delta(-0.044)],
  [#delta(+0.001)],
  [#text(size: 9pt)[*#delta(+0.002)*]],
  [#delta(-0.036)],
  [#delta(-0.069)],

  // test/instance/assd
  [SQASSD],
  [0.386],
  [#deltainv(+0.376)],
  [#text(size: 9pt)[*#deltainv(-0.002)*]],
  [#deltainv(+0.015)],
  [#deltainv(+0.187)],
  [#deltainv(+0.687)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.737],
  [#delta(-0.213)],
  [#delta(+0.005)],
  [#text(size: 9pt)[*#delta(+0.013)*]],
  [#delta(-0.151)],
  [#delta(-0.046)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.770],
  [#text(size: 9pt)[*#delta(+0.073)*]],
  [#delta(+0.016)],
  [#delta(+0.037)],
  [#delta(+0.059)],
  [#delta(-0.016)],

  // test/cc/dice
  [CCDice],
  [0.630],
  [#delta(+0.009)],
  [#delta(+0.005)],
  [#text(size: 9pt)[*#delta(+0.027)*]],
  [#delta(+0.017)],
  [#delta(+0.005)],
)