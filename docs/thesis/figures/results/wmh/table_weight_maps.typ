#import "../../../utils.typ": *
#let wmhresults-table_weight_maps() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 7),
  align: (left, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 1pt + luma(220),
  ),
  inset: 5pt,
  table.vline(start: 0, stroke: 1.5pt + datasetcolors.at(1)),
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
  [0.451],
  [#delta(-0.046)],
  [#delta(+0.051)],
  [#delta(-0.015)],
  [#text(size: 9pt)[*#delta(+0.065)*]],
  [#delta(+0.025)],

  // test/global/F2
  [$F_2$],
  [0.365],
  [#text(size: 9pt)[*#delta(+0.146)*]],
  [#delta(+0.008)],
  [#delta(-0.023)],
  [#delta(+0.022)],
  [#delta(+0.029)],

  // test/global/precision
  [precision],
  [#text(size: 9pt)[*0.877*]],
  [#delta(-0.473)],
  [#delta(-0.036)],
  [#delta(-0.019)],
  [#delta(-0.050)],
  [#delta(-0.219)],

  // test/global/recall
  [recall],
  [0.318],
  [#text(size: 9pt)[*#delta(+0.228)*]],
  [#delta(+0.009)],
  [#delta(-0.021)],
  [#delta(+0.023)],
  [#delta(+0.039)],

  // test/instance/f1
  [RQ],
  [0.427],
  [#delta(-0.272)],
  [#text(size: 9pt)[*#delta(+0.103)*]],
  [#delta(+0.070)],
  [#delta(-0.058)],
  [#delta(+0.081)],

  // test/instance/dice
  [SQDSC],
  [0.429],
  [#delta(+0.010)],
  [#delta(+0.079)],
  [#delta(+0.029)],
  [#text(size: 9pt)[*#delta(+0.158)*]],
  [#delta(+0.066)],

  // test/instance/assd
  [SQASSD$arrow.b$],
  [1.173],
  [#deltainv(-0.234)],
  [#deltainv(-0.356)],
  [#deltainv(+0.236)],
  [#text(size: 9pt)[*#deltainv(-0.665)*]],
  [#deltainv(+0.141)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [#text(size: 9pt)[*0.899*]],
  [#delta(-0.804)],
  [#delta(-0.089)],
  [#delta(-0.070)],
  [#delta(-0.613)],
  [#delta(-0.107)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.315],
  [#delta(+0.228)],
  [#delta(+0.124)],
  [#delta(+0.086)],
  [#text(size: 9pt)[*#delta(+0.361)*]],
  [#delta(+0.103)],

  // test/cc/dice
  [CCDice],
  [0.180],
  [#delta(+0.082)],
  [#delta(+0.078)],
  [#delta(+0.051)],
  [#text(size: 9pt)[*#delta(+0.186)*]],
  [#delta(+0.074)],
)