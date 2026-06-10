#import "../../../utils.typ": *
#let mitresults-table_weight_maps() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 7),
  align: (left, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 1pt + luma(220),
  ),
  inset: 5pt,
  table.vline(start: 0, stroke: 1.5pt + datasetcolors.at(4)),
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
  [0.944],
  [#delta(-0.013)],
  [#delta(-0.003)],
  [#text(size: 9pt)[*#delta(+0.000)*]],
  [#delta(-0.007)],
  [#delta(-0.017)],

  // test/global/F2
  [$F_2$],
  [0.943],
  [#text(size: 9pt)[*#delta(+0.018)*]],
  [#delta(-0.004)],
  [#delta(+0.003)],
  [#delta(-0.002)],
  [#delta(+0.015)],

  // test/global/precision
  [precision],
  [#text(size: 9pt)[*0.948*]],
  [#delta(-0.064)],
  [#delta(-0.001)],
  [#delta(-0.003)],
  [#delta(-0.012)],
  [#delta(-0.067)],

  // test/global/recall
  [recall],
  [0.942],
  [#text(size: 9pt)[*#delta(+0.041)*]],
  [#delta(-0.004)],
  [#delta(+0.004)],
  [#delta(+0.000)],
  [#delta(+0.038)],

  // test/instance/f1
  [RQ],
  [0.907],
  [#delta(-0.062)],
  [#delta(-0.004)],
  [#delta(-0.025)],
  [#delta(-0.047)],
  [#text(size: 9pt)[*#delta(+0.012)*]],

  // test/instance/dice
  [SQDSC],
  [0.939],
  [#delta(-0.014)],
  [#delta(-0.007)],
  [#text(size: 9pt)[*#delta(+0.006)*]],
  [#delta(-0.001)],
  [#delta(-0.021)],

  // test/instance/assd
  [SQASSD],
  [0.151],
  [#deltainv(+0.013)],
  [#deltainv(+0.018)],
  [#text(size: 9pt)[*#deltainv(-0.033)*]],
  [#deltainv(-0.006)],
  [#deltainv(+0.046)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [0.873],
  [#delta(-0.119)],
  [#delta(-0.014)],
  [#delta(-0.053)],
  [#delta(-0.091)],
  [#text(size: 9pt)[*#delta(+0.013)*]],

  // test/cc/dice
  [CCDice],
  [0.896],
  [#delta(+0.007)],
  [#delta(-0.002)],
  [#text(size: 9pt)[*#delta(+0.019)*]],
  [#delta(+0.013)],
  [#delta(-0.012)],
)