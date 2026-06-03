= Symbols and Notation
#align(center)[
  #table(
    columns: (2fr, 2fr),    // Allocates 25% width to symbols and 75% to descriptions
    stroke: none,           // Removes all borders for a clean look
    row-gutter: 11pt,       // Adds consistent, breathing space between rows
    align: (left, left),    // Aligns both columns to the left

    // Table Headers
    
    // Horizontal line under the header for a professional, publication-ready look
    table.hline(stroke: 0.5pt), 

    // Your Notation Entries
    $N in NN$, [Number of pixels/voxels in an image.],
    $Y: {y_1, y_2, dots, y_N | y_n in {0,1}}$, [The binary label map of a segmentation problem. It contains $N$ pixels.],
    $hat(Y): {hat(y)_1, hat(y)_2, dots, hat(y)_N | y_n in {0,1}}$, [The binary prediction map of a segmentation classifier. It contains $N$ pixels.],
    $K in NN$, [Number of connected components/instances in an image.],
    $cal(N): p mapsto {v_1, v_2, dots}$, [The neighborhood of a pixel $p$ in an image returning the set of neighboring "connected" pixels.],
    $I: {I_1, I_2, dots, I_K}$, [The set of $K$ instances in a label $Y$.],
    $R: {R_1, R_2, dots, R_K}$, [The set of voronoi regions in an image with some $R_k$ being seeded by $I_k$],
    $W: {w_1, w_2, dots, w_N | w_n in RR}$, [A weight map of the same shape as $Y$ and $hat(Y)$.],
    $cal(L):Y times hat(Y) mapsto RR$, [A loss function serving as a learning signal of a segmentation classifier.],
    $cal(I) = {(I_p, I_g) | I_p in hat(I), I_g in I}$, [The set of all matched instances from connected label components $I$ and prediction components $hat(I)$.]
  )
]