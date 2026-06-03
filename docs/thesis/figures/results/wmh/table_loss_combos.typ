#import "../../../utils.typ": *
#let wmhresults-table_loss_combos() = table(
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
  [0.451],
  [#delta(-0.043)],
  [#delta(-0.012)],
  [#text(size: 10.5pt)[*#delta(+0.032)*]],
  [#delta(-0.018)],
  [#delta(-0.013)],
  [#delta(-0.018)],

  // test/global/F2
  [F2],
  [0.365],
  [#delta(-0.084)],
  [#delta(-0.029)],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],
  [#delta(-0.026)],
  [#delta(-0.018)],
  [#delta(-0.022)],

  // test/instance/f1
  [RQ],
  [0.427],
  [#delta(+0.071)],
  [#delta(+0.026)],
  [#text(size: 10.5pt)[*#delta(+0.086)*]],
  [#delta(+0.052)],
  [#delta(+0.073)],
  [#delta(+0.072)],

  // test/instance/dice
  [SQDSC],
  [0.429],
  [#text(size: 10.5pt)[*#delta(+0.077)*]],
  [#delta(+0.018)],
  [#delta(+0.067)],
  [#delta(+0.017)],
  [#delta(+0.054)],
  [#delta(+0.032)],

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
  [recall_inst],
  [0.315],
  [#delta(+0.105)],
  [#delta(+0.052)],
  [#delta(+0.097)],
  [#delta(+0.071)],
  [#delta(+0.095)],
  [#text(size: 10.5pt)[*#delta(+0.113)*]],

  // test/instance/recall_q0
  [recall_inst_Q1],
  [0.103],
  [#text(size: 10.5pt)[*#delta(+0.142)*]],
  [#delta(+0.065)],
  [#delta(+0.093)],
  [#delta(+0.077)],
  [#delta(+0.121)],
  [#delta(+0.132)],

  // test/instance/recall_q1
  [recall_inst_Q2],
  [0.199],
  [#delta(+0.165)],
  [#delta(+0.107)],
  [#delta(+0.124)],
  [#delta(+0.106)],
  [#delta(+0.178)],
  [#text(size: 10.5pt)[*#delta(+0.181)*]],

  // test/instance/recall_q2
  [recall_inst_Q3],
  [0.339],
  [#delta(+0.104)],
  [#delta(+0.059)],
  [#delta(+0.142)],
  [#delta(+0.125)],
  [#delta(+0.132)],
  [#text(size: 10.5pt)[*#delta(+0.160)*]],

  // test/instance/recall_q3
  [recall_inst_Q4],
  [0.685],
  [#delta(+0.024)],
  [#delta(-0.003)],
  [#text(size: 10.5pt)[*#delta(+0.047)*]],
  [#delta(+0.003)],
  [#delta(+0.008)],
  [#delta(+0.011)],

  // test/cc/dice
  [CCDice],
  [0.180],
  [#delta(+0.065)],
  [#delta(+0.037)],
  [#delta(+0.070)],
  [#delta(+0.045)],
  [#delta(+0.071)],
  [#text(size: 10.5pt)[*#delta(+0.080)*]],

  // test/global/precision
  [precision],
  [#text(size: 10.5pt)[*0.877*]],
  [#delta(-0.030)],
  [#delta(-0.033)],
  [#delta(-0.007)],
  [#delta(-0.023)],
  [#delta(-0.036)],
  [#delta(-0.051)],

  // test/global/recall
  [recall],
  [0.318],
  [#delta(-0.078)],
  [#delta(-0.026)],
  [#text(size: 10.5pt)[*#delta(+0.003)*]],
  [#delta(-0.024)],
  [#delta(-0.016)],
  [#delta(-0.019)],

  // test/instance/precision
  [precision_inst],
  [#text(size: 10.5pt)[*0.899*]],
  [#delta(-0.077)],
  [#delta(-0.063)],
  [#delta(-0.045)],
  [#delta(-0.053)],
  [#delta(-0.046)],
  [#delta(-0.076)],
)