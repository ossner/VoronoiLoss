#import "../../utils.typ": *

#let importantresults-table_loss_combos() = table(
  columns: (0.3fr, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr).slice(0, 9),
  align: (center, left, center, center, center, center, center, center, center),
  stroke: (
    x: none,
    y: 0.4pt + luma(220),
  ),
  inset: 6pt,
  table.header(
    [],
    [], // Header space for dataset column
    [DiceCE, none],
    [none, DiceCE],
    [DiceCE, DiceCE],
    [2*DiceCE, DiceCE],
    [DiceCE, 2*DiceCE],
    [DiceCE, DiceTversky],
    [CETversky, DiceTversky],
  ),

  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(0), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(0))[METS])
  ),
  [DSC],
  [0.465],
  [#delta(+0.026)],
  [#text(size: 10.5pt)[*#delta(+0.089)*]],
  [#delta(+0.070)],
  [#delta(+0.044)],
  [#delta(+0.075)],
  [#delta(+0.064)],

  // test/instance/f1
  [RQ],
  [0.685],
  [#delta(-0.044)],
  [#text(size: 10.5pt)[*#delta(+0.116)*]],
  [#delta(+0.086)],
  [#delta(+0.029)],
  [#delta(+0.060)],
  [#delta(+0.036)],

  // test/instance/assd
  [SQASSD],
  [0.802],
  [#deltainv(-0.040)],
  [#deltainv(-0.018)],
  [#deltainv(-0.031)],
  [#text(size: 10.5pt)[*#deltainv(-0.098)*]],
  [#deltainv(-0.093)],
  [#deltainv(-0.088)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.648],
  [#text(size: 10.5pt)[*#delta(+0.246)*]],
  [#delta(+0.204)],
  [#delta(+0.121)],
  [#delta(+0.162)],
  [#delta(+0.166)],
  [#delta(+0.199)],

  // test/cc/dice
  [CCDice],
  [0.358],
  [#delta(+0.096)],
  [#delta(+0.101)],
  [#delta(+0.071)],
  [#delta(+0.092)],
  [#delta(+0.096)],
  [#text(size: 10.5pt)[*#delta(+0.109)*]],
  table.hline(start: 1, stroke: 1.5pt + luma(150)),

  // test/global/dice
  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(1), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(1))[WMH])
  ),
  [DSC],
  [0.451],
  [#delta(-0.043)],
  [#delta(-0.012)],
  [#text(size: 10.5pt)[*#delta(+0.032)*]],
  [#delta(-0.018)],
  [#delta(-0.013)],
  [#delta(-0.018)],

  // test/instance/f1
  [RQ],
  [0.427],
  [#delta(+0.071)],
  [#delta(+0.026)],
  [#text(size: 10.5pt)[*#delta(+0.086)*]],
  [#delta(+0.052)],
  [#delta(+0.073)],
  [#delta(+0.072)],

  // test/instance/assd
  [SQASSD],
  [1.173],
  [#deltainv(+0.006)],
  [#deltainv(-0.090)],
  [#deltainv(-0.264)],
  [#deltainv(-0.216)],
  [#text(size: 10.5pt)[*#deltainv(-0.304)*]],
  [#deltainv(-0.246)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.315],
  [#delta(+0.105)],
  [#delta(+0.052)],
  [#delta(+0.097)],
  [#delta(+0.071)],
  [#delta(+0.095)],
  [#text(size: 10.5pt)[*#delta(+0.113)*]],

  // test/cc/dice
  [CCDice],
  [0.180],
  [#delta(+0.065)],
  [#delta(+0.037)],
  [#delta(+0.070)],
  [#delta(+0.045)],
  [#delta(+0.071)],
  [#text(size: 10.5pt)[*#delta(+0.080)*]],
  table.hline(start: 1, stroke: 1.5pt + luma(150)),

  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(2), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(2))[CV])
  ),
  [DSC],
  [0.804],
  [#delta(+0.009)],
  [#delta(+0.007)],
  [#delta(+0.008)],
  [#delta(+0.014)],
  [#delta(+0.011)],
  [#text(size: 10.5pt)[*#delta(+0.018)*]],

  // test/instance/f1
  [RQ],
  [0.875],
  [#delta(+0.001)],
  [#delta(+0.002)],
  [#delta(+0.002)],
  [#text(size: 10.5pt)[*#delta(+0.008)*]],
  [#delta(+0.005)],
  [#delta(-0.000)],

  // test/instance/assd
  [SQASSD],
  [0.392],
  [#text(size: 10.5pt)[*#deltainv(-0.079)*]],
  [#deltainv(-0.020)],
  [#deltainv(-0.040)],
  [#deltainv(-0.055)],
  [#deltainv(-0.026)],
  [#deltainv(-0.072)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.913],
  [#delta(-0.002)],
  [#delta(-0.001)],
  [#delta(-0.003)],
  [#text(size: 10.5pt)[*#delta(+0.011)*]],
  [#delta(+0.006)],
  [#delta(-0.002)],

  [CCDice],
  [0.726],
  [#delta(+0.021)],
  [#delta(+0.009)],
  [#delta(+0.010)],
  [#delta(+0.019)],
  [#delta(+0.019)],
  [#text(size: 10.5pt)[*#delta(+0.025)*]],
  table.hline(start: 1, stroke: 1.5pt + luma(150)),

  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(3), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(3))[AG])
  ),
  [DSC],
  [0.813],
  [#delta(+0.008)],
  [#text(size: 10.5pt)[*#delta(+0.008)*]],
  [#delta(-0.000)],
  [#delta(-0.004)],
  [#delta(-0.005)],
  [#delta(-0.000)],

  // test/instance/f1
  [RQ],
  [0.746],
  [#delta(-0.010)],
  [#delta(-0.004)],
  [#text(size: 10.5pt)[*#delta(+0.028)*]],
  [#delta(+0.000)],
  [#delta(-0.006)],
  [#delta(+0.005)],

  // test/instance/assd
  [SQASSD],
  [0.386],
  [#deltainv(-0.010)],
  [#deltainv(+0.043)],
  [#deltainv(+0.037)],
  [#text(size: 10.5pt)[*#deltainv(-0.031)*]],
  [#deltainv(+0.083)],
  [#deltainv(+0.093)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.770],
  [#text(size: 10.5pt)[*#delta(+0.105)*]],
  [#delta(+0.050)],
  [#delta(+0.062)],
  [#delta(+0.050)],
  [#delta(+0.062)],
  [#delta(+0.058)],

  // test/cc/dice
  [CCDice],
  [0.630],
  [#text(size: 10.5pt)[*#delta(+0.065)*]],
  [#delta(+0.028)],
  [#delta(+0.030)],
  [#delta(+0.030)],
  [#delta(+0.031)],
  [#delta(+0.040)],
  table.hline(start: 1, stroke: 1.5pt + luma(150)),
  table.cell(
    rowspan: 5, 
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(4), y: none), // Pretty blue vertical bar
    rotate(-90deg, text(weight: "bold", fill: datasetcolors.at(4))[MIT])
  ),
  [DSC],
  [0.944],
  [#text(size: 10.5pt)[*#delta(+0.001)*]],
  [#delta(-0.000)],
  [#delta(-0.005)],
  [#delta(+0.001)],
  [#delta(+0.000)],
  [#delta(-0.003)],

  // test/instance/f1
  [RQ],
  [#text(size: 10.5pt)[*0.907*]],
  [#delta(-0.023)],
  [#delta(-0.006)],
  [#delta(-0.022)],
  [#delta(-0.036)],
  [#delta(-0.008)],
  [#delta(-0.026)],

  // test/instance/assd
  [SQASSD],
  [0.151],
  [#deltainv(-0.057)],
  [#text(size: 10.5pt)[*#deltainv(-0.058)*]],
  [#deltainv(-0.049)],
  [#deltainv(-0.055)],
  [#deltainv(-0.033)],
  [#deltainv(-0.033)],

  // test/instance/recall
  [$"recall"_"inst"$],
  [0.962],
  [#text(size: 10.5pt)[*#delta(+0.025)*]],
  [#delta(+0.014)],
  [#delta(+0.011)],
  [#delta(+0.020)],
  [#delta(+0.017)],
  [#delta(+0.018)],

  // test/cc/dice
  [CCDice],
  [0.896],
  [#text(size: 10.5pt)[*#delta(+0.027)*]],
  [#delta(+0.017)],
  [#delta(+0.011)],
  [#delta(+0.021)],
  [#delta(+0.018)],
  [#delta(+0.018)],

)
