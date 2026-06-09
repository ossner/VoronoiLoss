#import "../../utils.typ": *

#let importantresults-table_loss_combos_quartiles() = table(
  columns: (auto, auto, auto, auto, auto, auto).slice(0, 6),
  align: (center, left, center, center, center, center),
  stroke: (
    x: none,
    y: 1pt + luma(220),
  ),
  inset: 6pt,

  // ===== HEADER =====
  table.header(
    [],
    [*Quartile*],

    [#table.cell(
      colspan: 2,
      align: center + horizon,
      [(DiceCE, none)],
    )],
    [#table.cell(
      colspan: 2,
      align: center + horizon,
      [(DiceCE, DiceCE)],
    )],
    [],
  ),
    [],
    [],
    [*Recall*],
    [*SQDSC*],
    [*Recall*],
    [*SQDSC*],

  table.hline(start: 1, stroke: 1.5pt + luma(150)),

  // ===== METS =====
  table.cell(
    rowspan: 4,
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(0), y: none),
    rotate(
      -90deg,
      text(weight: "bold", fill: datasetcolors.at(0))[METS],
    ),
  ),

  [Q1 ($<13$ vx)],
  [0.465],
  [0.392],
  [#strong[0.554]],
  [#strong[0.448]],

  [Q2 ($13$–$29$ vx)],
  [0.482],
  [0.405],
  [#strong[0.571]],
  [#strong[0.460]],

  [Q3 ($29$–$84$ vx)],
  [0.501],
  [0.422],
  [#strong[0.588]],
  [#strong[0.479]],

  [Q4 ($>84$ vx)],
  [0.523],
  [0.441],
  [#strong[0.603]],
  [#strong[0.492]],

  table.hline(start: 1, stroke: 1.5pt + luma(150)),

  // ===== WMH =====
  table.cell(
    rowspan: 4,
    align: center + horizon,
    stroke: (right: 2pt + datasetcolors.at(1), y: none),
    rotate(
      -90deg,
      text(weight: "bold", fill: datasetcolors.at(1))[WMH],
    ),
  ),

  [Q1 ($\leq 3$ vx)],
  [0.421],
  [0.367],
  [#strong[0.497]],
  [#strong[0.412]],

  [Q2 ($4$–$5$ vx)],
  [0.448],
  [0.391],
  [#strong[0.529]],
  [#strong[0.435]],

  [Q3 ($6$–$13$ vx)],
  [0.474],
  [0.415],
  [#strong[0.551]],
  [#strong[0.459]],

  [Q4 ($>13$ vx)],
  [0.506],
  [0.442],
  [#strong[0.587]],
  [#strong[0.487]],

  table.hline(start: 1, stroke: 1.5pt + luma(150)),
)
