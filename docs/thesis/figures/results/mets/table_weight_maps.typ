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
  [#text(size: 10.5pt)[*0.465*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/global/F2
  [$F_2$],
  [#text(size: 10.5pt)[*0.479*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/f1
  [RQ],
  [#text(size: 10.5pt)[*0.685*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/dice
  [SQDSC],
  [#text(size: 10.5pt)[*0.458*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/assd
  [SQASSD],
  [#text(size: 10.5pt)[*0.802*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/precision
  [$"precision"_"inst"$],
  [#text(size: 10.5pt)[*0.875*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/recall
  [$"recall"_"inst"$],
  [#text(size: 10.5pt)[*0.648*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/recall_q0
  [$"recall"_"inst"_"Q1"$],
  [#text(size: 10.5pt)[*0.250*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/recall_q1
  [$"recall"_"inst"_"Q2"$],
  [#text(size: 10.5pt)[*0.444*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/recall_q2
  [$"recall"_"inst"_"Q3"$],
  [#text(size: 10.5pt)[*0.758*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/instance/recall_q3
  [$"recall"_"inst"_"Q4"$],
  [#text(size: 10.5pt)[*0.980*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/cc/dice
  [CCDice],
  [#text(size: 10.5pt)[*0.358*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/global/precision
  [precision],
  [#text(size: 10.5pt)[*0.709*]],
  [-],
  [-],
  [-],
  [-],
  [-],

  // test/global/recall
  [recall],
  [#text(size: 10.5pt)[*0.443*]],
  [-],
  [-],
  [-],
  [-],
  [-],
)