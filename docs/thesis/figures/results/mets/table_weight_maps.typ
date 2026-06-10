#import "../../../utils.typ": *
#let metsresults-table_weight_maps() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 7),
  align: (left, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 1pt + luma(220),
  ),
  inset: 5pt,

  table.vline(start: 0, stroke: 1.5pt + datasetcolors.at(0)),
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

  // test/cc/dice
  [CCDice],
  [0.358],
  [#delta(-0.314)],
  [#delta(-0.028)],
  [#delta(-0.007)],
  [#text(size: 10.5pt)[*#delta(+0.025)*]],
  [#delta(+0.015)],
)