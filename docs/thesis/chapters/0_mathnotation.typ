#import "../utils.typ": *

= Symbols and Notation
#align(center)[
  #table(
    columns: (1fr, 2fr),    // Allocates 25% width to symbols and 75% to descriptions
    stroke: none,           // Removes all borders for a clean look
    align: (left, left),    // Aligns both columns to the left
    inset: 7pt,
    table.hline(stroke: 0.5pt), 

    // Your Notation Entries
    $N in NN$, [Number of pixels/voxels in an image.],
    $n in [N]$, [Any particular pixel in the image.],
    $N_x, N_y, N_z$, [The number of pixels in the image in x- y- and z- direction.],
    $Y: {y_1, y_2, dots, y_N | y_n in {0,1}}$, [The ordered binary label map of a segmentation problem.],
    $hat(Y): {hat(y)_1, hat(y)_2, dots, hat(y)_N | hat(y)_n in {0,1}}$, [The binary prediction map of a segmentation classifier.],
    $tilde(Y): {tilde(y)_1, tilde(y)_2, dots, tilde(y)_N | tilde(y)_n in [0,1]}$, [The continuous prediction probability map of a segmentation classifier.],
    $K in NN$, [Number of connected components/instances in a label map.],
    $"d"(x, I_k) mapsto RR$, [A function calculating the minimal distance from a point pixel/voxel $x$ to any pixel/voxel in the set $I_k$.],
    $cal(N)(p) mapsto {v_1, v_2, dots}$, [The neighborhood of a pixel $p$ in an image returning the set of neighboring connected pixels/voxels.],
    $c$, [The connectivity parameter determining the number of adjacent pixels/voxels considered to be neighbors.],
    $I: {I_1, I_2, dots, I_K | I_k subset [N]}$, [The set of $K$ connected components (instances) in a label.],
    $hat(K) in NN$, [Number of predicted instances in a binary prediction map identified using connected component analysis.],
    $hat(I): {hat(I)_1, hat(I)_2, dots, hat(I)_hat(K) | I_hat(k) subset [N]}$, [The set of $hat(K)$ connected components (instances) in a prediction.],
    $R: {R_1, R_2, dots, R_K | R_k subset [N]}$, [The set of voronoi regions in an image with some $R_k$ being seeded by an instance $I_k$.],
    $Y_R_k, hat(Y)_R_k, tilde(Y)_R_k$, [The set of label, binary prediction and continuous prediction pixels/voxels only in the Voronoi region $R_k$ respectively.],
    $W: {w_1, w_2, dots, w_N | w_n in RR}$, [A weight map of the same shape as the label that can be applied a loss function.],
    $cal(L) (Y, tilde(Y)) mapsto RR$, [A generic loss function serving as a learning signal of a segmentation classifier.],
    $cal(L)_"global" (Y, tilde(Y)) mapsto RR$, [An arbitrary loss function operating on the entire prediction and label maps.],
    $cal(L)_"Voronoi" (Y, tilde(Y), R) mapsto RR$, [An arbitrary loss function calculating region-wise learning signals and averaging them across all Voronoi regions R.],
    $hat(alpha), hat(beta)$, [The pre-normalized weights of the global and region-wise loss respectively.],
    $cal(I) = {(hat(I)_hat(k), I_k) | hat(I)_hat(k) in hat(I), I_k in I}$, [The set of all matched instances from connected label components $I$ and prediction components $hat(I)$.],
    $lambda$, [The region-wise penalty in an adaptive weight map based on a missed instance in the prediction.],
  )
]