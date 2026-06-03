#import "../../../utils.typ": *
#let agresults-table_loss_combos() = table(
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
  [0.813],
  [#delta(+0.008)],
  [#text(size: 10.5pt)[*#delta(+0.008)*]],
  [#delta(-0.000)],
  [#delta(-0.004)],
  [#delta(-0.005)],
  [#delta(-0.000)],

  // test/global/F2
  [F2],
  [0.821],
  [#text(size: 10.5pt)[*#delta(+0.030)*]],
  [#delta(+0.010)],
  [#delta(+0.003)],
  [#delta(+0.001)],
  [#delta(+0.012)],
  [#delta(+0.025)],

  // test/instance/f1
  [RQ],
  [0.746],
  [#delta(-0.010)],
  [#delta(-0.004)],
  [#text(size: 10.5pt)[*#delta(+0.028)*]],
  [#delta(+0.000)],
  [#delta(-0.006)],
  [#delta(+0.005)],

  // test/instance/dice
  [SQDSC],
  [0.850],
  [#delta(-0.001)],
  [#delta(-0.009)],
  [#delta(-0.015)],
  [#text(size: 10.5pt)[*#delta(+0.001)*]],
  [#delta(-0.014)],
  [#delta(-0.007)],

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
  [recall_inst],
  [0.770],
  [#text(size: 10.5pt)[*#delta(+0.105)*]],
  [#delta(+0.050)],
  [#delta(+0.062)],
  [#delta(+0.050)],
  [#delta(+0.062)],
  [#delta(+0.058)],

  // test/instance/recall_q0
  [recall_inst_Q1],
  [0.360],
  [#text(size: 10.5pt)[*#delta(+0.257)*]],
  [#delta(+0.108)],
  [#delta(+0.177)],
  [#delta(+0.160)],
  [#delta(+0.177)],
  [#delta(+0.141)],

  // test/instance/recall_q1
  [recall_inst_Q2],
  [0.882],
  [#delta(+0.063)],
  [#delta(+0.047)],
  [#delta(+0.024)],
  [#delta(+0.024)],
  [#text(size: 10.5pt)[*#delta(+0.074)*]],
  [#delta(+0.068)],

  // test/instance/recall_q2
  [recall_inst_Q3],
  [0.939],
  [#text(size: 10.5pt)[*#delta(+0.043)*]],
  [#delta(+0.042)],
  [#delta(+0.031)],
  [#delta(+0.021)],
  [#delta(+0.005)],
  [#delta(+0.032)],

  // test/instance/recall_q3
  [recall_inst_Q4],
  [0.983],
  [#text(size: 10.5pt)[*#delta(+0.017)*]],
  [#delta(+0.000)],
  [#delta(-0.017)],
  [#delta(-0.047)],
  [#delta(-0.008)],
  [#delta(+0.008)],

  // test/cc/dice
  [CCDice],
  [0.630],
  [#text(size: 10.5pt)[*#delta(+0.065)*]],
  [#delta(+0.028)],
  [#delta(+0.030)],
  [#delta(+0.030)],
  [#delta(+0.031)],
  [#delta(+0.040)],

  // test/global/precision
  [precision],
  [#text(size: 10.5pt)[*0.838*]],
  [#delta(-0.031)],
  [#delta(-0.006)],
  [#delta(-0.012)],
  [#delta(-0.010)],
  [#delta(-0.035)],
  [#delta(-0.050)],

  // test/global/recall
  [recall],
  [0.817],
  [#text(size: 10.5pt)[*#delta(+0.046)*]],
  [#delta(+0.014)],
  [#delta(+0.006)],
  [#delta(+0.004)],
  [#delta(+0.024)],
  [#delta(+0.045)],

  // test/instance/precision
  [precision_inst],
  [#text(size: 10.5pt)[*0.737*]],
  [#delta(-0.096)],
  [#delta(-0.048)],
  [#delta(-0.001)],
  [#delta(-0.042)],
  [#delta(-0.053)],
  [#delta(-0.044)],
)