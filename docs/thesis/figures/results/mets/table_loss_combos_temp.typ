#import "../../../utils.typ": *
#let metsresults-table_loss_combos() = table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, ).slice(0, 8),
  align: (left, center, center, center, center, center, center, center, ),
  stroke: (
    x: none,
    y: 0.4pt + luma(220),
  ),
  inset: 8pt,

  table.header(
    [],
    [DiceCE, none],
    [none, DiceCE],
    [DiceCE, DiceCE],
    [2*DiceCE, DiceCE],
    [DiceCE, 2*DiceCE],
    [DiceCE, DiceTversky],
    [CETversky, DiceTversky],
  ),

  // test/global/dice
  [DSC],
  [0.465],
  [#delta(+0.026)],
  [#text(size: 10.5pt)[*#delta(+0.089)*]],
  [#delta(+0.070)],
  [#delta(+0.044)],
  [#delta(+0.075)],
  [#delta(+0.064)],

  // test/global/F2
  [$F_2$],
  [0.479],
  [#delta(+0.101)],
  [#text(size: 10.5pt)[*#delta(+0.130)*]],
  [#delta(+0.007)],
  [#delta(+0.049)],
  [#delta(+0.109)],
  [#delta(+0.062)],

  // test/instance/f1
  [RQ],
  [0.685],
  [#delta(-0.044)],
  [#text(size: 10.5pt)[*#delta(+0.116)*]],
  [#delta(+0.086)],
  [#delta(+0.029)],
  [#delta(+0.060)],
  [#delta(+0.036)],

  // test/instance/dice
  [SQDSC],
  [0.458],
  [#delta(+0.114)],
  [#delta(+0.084)],
  [#delta(+0.091)],
  [#delta(+0.099)],
  [#delta(+0.111)],
  [#text(size: 10.5pt)[*#delta(+0.137)*]],

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

  // test/instance/recall_Q1
  [$"recall"_"inst"_"Q1"$],
  [0.250],
  [#text(size: 10.5pt)[*#delta(+0.188)*]],
  [#delta(+0.125)],
  [#delta(+0.000)],
  [#delta(+0.000)],
  [#delta(+0.000)],
  [#delta(+0.000)],

  // test/instance/recall_Q2
  [$"recall"_"inst"_"Q2"$],
  [0.444],
  [#text(size: 10.5pt)[*#delta(+0.370)*]],
  [#delta(+0.306)],
  [#delta(+0.139)],
  [#delta(+0.324)],
  [#delta(+0.287)],
  [#delta(+0.324)],

  // test/instance/recall_Q3
  [$"recall"_"inst"_"Q3"$],
  [0.758],
  [#text(size: 10.5pt)[*#delta(+0.179)*]],
  [#delta(+0.142)],
  [#delta(+0.072)],
  [#delta(+0.103)],
  [#delta(+0.093)],
  [#delta(+0.142)],

  // test/instance/recall_Q4
  [$"recall"_"inst"_"Q4"$],
  [0.980],
  [#text(size: 10.5pt)[*#delta(+0.010)*]],
  [#text(size: 10.5pt)[*#delta(+0.010)*]],
  [#delta(+0.000)],
  [#delta(+0.000)],
  [#text(size: 10.5pt)[*#delta(+0.010)*]],
  [#delta(+0.000)],

  // test/instance/SQDSC_Q1
  [SQDSC_Q1],
  [0.181],
  [#delta(+0.106)],
  [#text(size: 10.5pt)[*#delta(+0.127)*]],
  [#delta(-0.026)],
  [#delta(+0.073)],
  [#delta(-0.035)],
  [#delta(-0.053)],

  // test/instance/SQDSC_Q2
  [SQDSC_Q2],
  [0.293],
  [#delta(+0.165)],
  [#delta(+0.121)],
  [#delta(+0.072)],
  [#delta(+0.129)],
  [#delta(+0.127)],
  [#text(size: 10.5pt)[*#delta(+0.191)*]],

  // test/instance/SQDSC_Q3
  [SQDSC_Q3],
  [0.376],
  [#delta(+0.206)],
  [#delta(+0.175)],
  [#delta(+0.132)],
  [#delta(+0.188)],
  [#delta(+0.208)],
  [#text(size: 10.5pt)[*#delta(+0.211)*]],

  // test/instance/SQDSC_Q4
  [SQDSC_Q4],
  [0.636],
  [#delta(+0.033)],
  [#delta(+0.012)],
  [#delta(-0.004)],
  [#delta(+0.022)],
  [#delta(+0.020)],
  [#text(size: 10.5pt)[*#delta(+0.045)*]],

  // test/cc/dice
  [CCDice],
  [0.358],
  [#delta(+0.096)],
  [#delta(+0.101)],
  [#delta(+0.071)],
  [#delta(+0.092)],
  [#delta(+0.096)],
  [#text(size: 10.5pt)[*#delta(+0.109)*]],

  // test/global/precision
  [precision],
  [0.709],
  [#delta(-0.163)],
  [#delta(-0.084)],
  [#text(size: 10.5pt)[*#delta(+0.028)*]],
  [#delta(-0.030)],
  [#delta(-0.100)],
  [#delta(-0.068)],

  // test/global/recall
  [recall],
  [0.443],
  [#delta(+0.146)],
  [#text(size: 10.5pt)[*#delta(+0.162)*]],
  [#delta(+0.005)],
  [#delta(+0.057)],
  [#delta(+0.140)],
  [#delta(+0.077)],

  // test/instance/precision
  [$"precision"_"inst"$],
  [#text(size: 10.5pt)[*0.875*]],
  [#delta(-0.333)],
  [#delta(-0.071)],
  [#delta(-0.046)],
  [#delta(-0.190)],
  [#delta(-0.128)],
  [#delta(-0.205)],
)