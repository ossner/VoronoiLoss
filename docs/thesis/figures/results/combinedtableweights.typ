#import "../../utils.typ": *

#let importantresults-table_weight_maps() = table(
  columns: (0.3fr, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr).slice(0, 8),
  align: (center, left, center, center, center, center, center, center),
  stroke: (
    x: none,
    y: 1pt + luma(220),
  ),
  inset: 6pt,

  table.header(
    [], // Header space for dataset column
    [],
    [$"W"_"none"$],
     [$"W"_"v_iw"$],
     [$"W"_"v_region"$],
     [$"W"_"v_adaptive"$],
     [$"W"_"v_mountains"$],
     [$"W"_"v_islands"$],
  ),

  // test/global/dice

  table.hline(start: 1, stroke: 1.5pt + luma(150)),
  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(0), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(0))[METS])
  ),

  // test/global/dice
  [DSC],
  [0.465],
  [#delta(-0.422)],
  [#text(size: 9.5pt)[*#delta(+0.011)*]],
  [#delta(+0.002)],
  [#delta(-0.011)],
  [#delta(-0.004)],

  // test/instance/f1
  [RQ],
  [0.685],
  [#delta(-0.654)],
  [#delta(-0.045)],
  [#delta(+0.034)],
  [#delta(-0.193)],
  [#text(size: 9.5pt)[*#delta(+0.051)*]],

  // test/instance/assd
  [SQASSD$arrow.b$],
  [0.802],
  [#deltainv(+2.282)],
  [#deltainv(+0.038)],
  [#deltainv(+0.042)],
  [#text(size: 9.5pt)[*#deltainv(-0.004)*]],
  [#deltainv(+0.114)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.648],
  [#text(size: 9.5pt)[*#delta(+0.307)*]],
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
  [#text(size: 9.5pt)[*#delta(+0.025)*]],
  [#delta(+0.015)],

  table.hline(start: 1, stroke: 1.5pt + luma(150)),
  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(1), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(1))[WMH])
  ),

  // test/global/dice
  [DSC],
  [0.451],
  [#delta(-0.046)],
  [#delta(+0.051)],
  [#delta(-0.015)],
  [#text(size: 9.5pt)[*#delta(+0.065)*]],
  [#delta(+0.025)],

  // test/instance/f1
  [RQ],
  [0.427],
  [#delta(-0.272)],
  [#text(size: 9.5pt)[*#delta(+0.103)*]],
  [#delta(+0.070)],
  [#delta(-0.058)],
  [#delta(+0.081)],

  // test/instance/assd
  [SQASSD$arrow.b$],
  [1.173],
  [#deltainv(-0.234)],
  [#deltainv(-0.356)],
  [#deltainv(+0.236)],
  [#text(size: 9.5pt)[*#deltainv(-0.665)*]],
  [#deltainv(+0.141)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.315],
  [#delta(+0.228)],
  [#delta(+0.124)],
  [#delta(+0.086)],
  [#text(size: 9.5pt)[*#delta(+0.361)*]],
  [#delta(+0.103)],

  // test/cc/dice
  [CCDice],
  [0.180],
  [#delta(+0.082)],
  [#delta(+0.078)],
  [#delta(+0.051)],
  [#text(size: 9.5pt)[*#delta(+0.186)*]],
  [#delta(+0.074)],

  
  table.hline(start: 1, stroke: 1.5pt + luma(150)),
  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(2), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(2))[CV])
  ),

  // test/global/dice
  [DSC],
  [0.804],
  [#delta(-0.032)],
  [#delta(-0.005)],
  [#text(size: 9.5pt)[*#delta(+0.005)*]],
  [#delta(+0.004)],
  [#delta(-0.019)],

  // test/instance/f1
  [RQ],
  [#text(size: 9.5pt)[*0.875*]],
  [#delta(-0.081)],
  [#delta(-0.005)],
  [#delta(-0.012)],
  [#delta(-0.030)],
  [#delta(-0.031)],

  // test/instance/assd
  [SQASSD$arrow.b$],
  [0.392],
  [#deltainv(+0.201)],
  [#deltainv(+0.011)],
  [#deltainv(-0.011)],
  [#text(size: 9.5pt)[*#deltainv(-0.027)*]],
  [#deltainv(+0.178)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.913],
  [#delta(-0.017)],
  [#delta(-0.012)],
  [#delta(-0.010)],
  [#text(size: 9.5pt)[*#delta(+0.007)*]],
  [#delta(-0.035)],

  // test/cc/dice
  [CCDice],
  [0.726],
  [#delta(-0.020)],
  [#delta(-0.012)],
  [#delta(+0.005)],
  [#text(size: 9.5pt)[*#delta(+0.006)*]],
  [#delta(-0.018)],

  
  table.hline(start: 1, stroke: 1.5pt + luma(150)),
  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(3), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(3))[AG])
  ),

  // test/global/dice
  [DSC],
  [0.813],
  [#delta(-0.058)],
  [#delta(-0.003)],
  [#text(size: 9.5pt)[*#delta(+0.012)*]],
  [#delta(-0.012)],
  [#delta(-0.025)],

  // test/instance/f1
  [RQ],
  [0.746],
  [#delta(-0.107)],
  [#delta(+0.014)],
  [#text(size: 9.5pt)[*#delta(+0.022)*]],
  [#delta(-0.066)],
  [#delta(-0.030)],

  // test/instance/assd
  [SQASSD$arrow.b$],
  [0.386],
  [#deltainv(+0.376)],
  [#text(size: 9.5pt)[*#deltainv(-0.002)*]],
  [#deltainv(+0.015)],
  [#deltainv(+0.187)],
  [#deltainv(+0.687)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.770],
  [#text(size: 9.5pt)[*#delta(+0.073)*]],
  [#delta(+0.016)],
  [#delta(+0.037)],
  [#delta(+0.059)],
  [#delta(-0.016)],

  // test/cc/dice
  [CCDice],
  [0.630],
  [#delta(+0.009)],
  [#delta(+0.005)],
  [#text(size: 9.5pt)[*#delta(+0.027)*]],
  [#delta(+0.017)],
  [#delta(+0.005)],

  
  table.hline(start: 1, stroke: 1.5pt + luma(150)),
  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(4), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(4))[MIT])
  ),

  // test/global/dice
  [DSC],
  [#text(size: 9.5pt)[*0.944*]],
  [#delta(-0.013)],
  [#delta(-0.003)],
  [#text(size: 9.5pt)[*#delta(+0.000)*]],
  [#delta(-0.007)],
  [#delta(-0.017)],

  // test/instance/f1
  [RQ],
  [0.907],
  [#delta(-0.062)],
  [#delta(-0.004)],
  [#delta(-0.025)],
  [#delta(-0.047)],
  [#text(size: 9.5pt)[*#delta(+0.012)*]],

  // test/instance/assd
  [SQASSD$arrow.b$],
  [0.151],
  [#deltainv(+0.013)],
  [#deltainv(+0.018)],
  [#text(size: 9.5pt)[*#deltainv(-0.033)*]],
  [#deltainv(-0.006)],
  [#deltainv(+0.046)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.962],
  [#text(size: 9.5pt)[*#delta(+0.027)*]],
  [#delta(+0.006)],
  [#delta(+0.017)],
  [#delta(+0.021)],
  [#delta(+0.005)],

  // test/cc/dice
  [CCDice],
  [0.896],
  [#delta(+0.007)],
  [#delta(-0.002)],
  [#text(size: 9.5pt)[*#delta(+0.019)*]],
  [#delta(+0.013)],
  [#delta(-0.012)],

)