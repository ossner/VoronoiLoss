#import "@local/exzellenz-tum-thesis:0.2.1": exzellenz-tum-thesis

#import "utils.typ": draft, inwriting, todo
#import "glossary.typ": entry-list
#import "@preview/glossarium:0.5.9": *

/** Introduction

  The philosophy of this template is that the template file itself only contains the template of the first pages of the thesis, that are the same for all thesis.

  The formatting for the main part of the thesis is done here in the main.typ file. This looks less clean in the first place but has the advantage that you can easily change the formatting of the thesis, without the need to change the unreachable template file.

**/

/** Drafting

  Set inwriting and draft inside utils.

  The "draft" variable is used to show DRAFT in the header and the title. This should be true until the final version is handed-in.

  The "inwriting" is used to change the appearance of the document for easier writing. Set to true for yourself but false for handing in a draft or so.

**/


// Global Settings //
#set text(lang: "en", size: 12pt)
#set text(ligatures: true)
#set text(font: "New Computer Modern Sans")
#set list(indent: 2em)
#set enum(indent: 2em)
#show table.cell: set text(size: 9pt)
#show figure.caption: set text(size: 11pt)


#show: exzellenz-tum-thesis.with(
  degree: "Master",
  program: "Informatics",
  school: "School of Computation, Information and Technology",
  examiner: "Prof. Dr. Daniel Rückert",
  supervisors: ("Hendrik Möller",),
  author: "Sebastian Oßner",
  title-en: "Addressing Volumetric Bias in Multi-Instance Semantic Segmentation Using Voronoi Tessellation",
  title-de: "Adressierung volumetrischer Befangenheit in Multi-Instanz-Semantischer Segmentierung durch Voronoi-Tessellation",
  abstract-text: [Modern medical image segmentation networks exhibit an inherent bias based on the size of objects they are tasked to segment, which poses a significant problem particularly in high-stakes applications such as cancer segmentation where this can cause a network to prioritize larger tumors and fail to identify smaller ones. We introduce several approaches to address this bias by partitioning the image space into geometric regions in order to spatially equalize the learning signal and counteract this effect. We incorporate this spatial tessellation into loss functions and weight maps and evaluate its effect on five multi-instance datasets that exhibit a diverse range of connected components. On the stanford brain metastasis dataset, the use of an additional Voronoi-region-wise loss function improves the identification of individual tumor metastases from 64.8% to 85.2% over the standard DiceCE baseline, with particularly high gains for below-average sized lesions. This improvement did not have a detrimental effect on the global segmentation, increasing the Dice score by 8.9 percentage points and recognition quality by 11.6 points. The results of this thesis show that a segmentation network's volumetric bias toward larger instances can be mitigated through regional equalization.],
  submission-date: datetime.today().display("[day].[month].[year]"),
  show-title-in-header: true,
  draft: draft,
)

// Settings for Body //
// Set fonts
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show math.equation: set text(font: "New Computer Modern Math")

// Set font size
#show heading.where(level: 3): set text(size: 1.05em)
#show heading.where(level: 4): set text(size: 1.0em)
#show figure: set text(size: 0.9em)
#show figure.caption: set align(left)

// Set spacing
#set par(leading: 0.9em, first-line-indent: 1.8em, justify: true, spacing: 1em)
#set table(inset: 6.5pt)
#show table: set par(justify: false)
#show figure: it => [#v(1em) #it #v(1em)]

#show heading.where(level: 1): set block(above: 1.95em, below: 1em)
#show heading.where(level: 2): set block(above: 1.85em, below: 1em)
#show heading.where(level: 3): set block(above: 1.75em, below: 1em)
#show heading.where(level: 4): set block(above: 1.55em, below: 1em)

// Pagebreak after level 1 headings
#show heading.where(level: 1): it => [
  #pagebreak(weak: true)
  #it
]

// Names for headings
#set heading(supplement: it => {
  if (it.has("depth")) {
    if it.depth == 1 [Chapter] else if it.depth == 2 [Section] else [Subsection]
  } else {
     [Appendix]
  }
})

// Table stroke
#set table(stroke: 0.5pt + black)

// color links and references
#show ref: set text(fill: blue)
#show link: set text(fill: rgb("#238a5c"))

// style table-of-contents
#show outline.entry.where(
  level: 1,
): it => {
  v(1em, weak: true)
  strong(it)
}

// Make and register Glossary //
#show: make-glossary
#register-glossary(entry-list)

// ------ Content ------

// Table of contents.
#outline(
  title: {
    text(1.3em, weight: 700, "Contents")
    v(10mm)
  },
  indent: 2em,
  depth: 3,
)
#pagebreak(weak: false)

// Set numbering mode (and restart for main content)
#set page(numbering: "1")
#counter(page).update(1)
#include "chapters/0_mathnotation.typ"
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.1")
// --- Main Chapters ---

#include "chapters/1_Introduction.typ"
#include "chapters/2_Background.typ"
#include "chapters/3_Related_Work.typ"
#include "chapters/4_Methodology.typ"
#include "chapters/5_Results.typ"
#include "chapters/6_Discussion.typ"
#include "chapters/7_Future_Work.typ"
#include "chapters/8_Conclusion.typ"

// --- Appendices ---

// Restart page numbering using roman numerals
#set page(numbering: "i")
#counter(page).update(1)
#counter(heading).update(0)

// Reset figure/table counters
#counter(figure.where(kind: image)).update(_ => 0)
#counter(figure.where(kind: table)).update(_ => 0)

// Redefine supplement + numbering for appendix
#show figure: set figure(
  numbering: n => "A." + str(n)
)

#show figure.caption: set text(size: 10pt)
#include "chapters/A1_Appendix.typ"

// List of Acronyms.  
#context text(size: 10pt)[
#heading(numbering: none)[Glossary]

#print-glossary(
  entry-list,
)

// List of figures.
#heading(numbering: none)[List of Figures]
#outline(
  title: none,
  target: figure.where(kind: image),
)

// List of tables.
#heading(numbering: none)[List of Tables]
#outline(
  title: none,
  target: figure.where(kind: table),
)

// --- Bibliography ---

#set par(leading: 0.7em, first-line-indent: 0em, justify: true)
#bibliography("items.bib", style: "citestyle.csl")
]
