#let inwriting = true
#let draft = true

#assert(not(inwriting and not(draft)), message: "If inwriting is true, draft should be true as well.")

#let todo(it) = [
  #if inwriting [
    #text(size: 0.8em)[#emoji.pencil]  #text(it, fill: red, weight: 600)
  ]
]

#let silentheading(level, body) = [
  #heading(outlined: false, level: level, numbering: none, bookmarked: true)[#body]
]

#let class_colors = (
  rgb(34, 197, 94),  // TP
  rgb(59,130,246),  // FN
  rgb(239,68,68),  // FP
  rgb(248,250,252),  // TN
)