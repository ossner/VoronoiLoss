#import "../utils.typ": *

= Symbols and Notation
#context text(size: 10pt)[
#align(center)[
  #table(
    columns: (1fr, 2fr),    // Allocates 25% width to symbols and 75% to descriptions
    stroke: none,           // Removes all borders for a clean look
    align: (left, left),    // Aligns both columns to the left

    // Table Headers
    
    // Horizontal line under the header for a professional, publication-ready look
    table.hline(stroke: 0.5pt), 

    // Your Notation Entries
    $N in NN$, [Number of pixels/voxels in an image.],
    $n_x, n_y, n_z$, [The number of pixels in the image in x- y- and z- direction.],
    $Y: {y_1, y_2, dots, y_N | y_n in {0,1}}$, [The binary label map of a segmentation problem. It contains $N$ pixels.],
    $hat(Y): {hat(y)_1, hat(y)_2, dots, hat(y)_N | y_n in {0,1}}$, [The binary prediction map of a segmentation classifier. It contains $N$ pixels.],
    $tilde(Y): {tilde(y)_1, tilde(y)_2, dots, tilde(y)_N | y_n in [0,1]}$, [The continuous sigmoid prediction map of a segmentation classifier. It contains $N$ values, each value signifies the confidence of a prediction.],
    $K in NN$, [Number of connected components/instances in an image.],
    $"d": x, I_k mapsto RR$, [A function calculating the minimal distance from a point $x$ to any element in the set $I_k$],
    $cal(N): p mapsto {v_1, v_2, dots}$, [The neighborhood of a pixel $p$ in an image returning the set of neighboring connected pixels.],
    $I: {I_1, I_2, dots, I_K}$, [The set of $K$ connected components (instances) in a label.],
    $R: {R_1, R_2, dots, R_K}$, [The set of voronoi regions in an image with some $R_k$ being seeded by $I_k$],
    $W: {w_1, w_2, dots, w_N}$, [A weight map of the same shape as the label that can be applied pixel-wise to a loss function.],
    $cal(L):Y, tilde(Y) mapsto RR$, [A generic loss function serving as a learning signal of a segmentation classifier.],
    $cal(L)_"global":Y, tilde(Y) mapsto RR$, [An arbitrary loss function operating on the entire prediction and label at once.],
    $cal(L)_"Voronoi":Y, tilde(Y), R mapsto RR$, [An arbitrary loss function calculating region-wise learning signals and averaging them across all Voronoi regions R.],
    $hat(alpha), hat(beta)$, [The pre-normalized weights of the global and region-wise loss respectively in a combined formulation.],
    $cal(I) = {(I_p, I_g) | I_p in hat(I), I_g in I}$, [The set of all matched instances from connected label components $I$ and prediction components $hat(I)$.],
  )
]
]
#todo("Go over everything and ensure this table is complete, which it currently isn't")