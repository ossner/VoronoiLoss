#import "../utils.typ": class_colors, todo

= Background <chapter_background>
This section introduces the knowledge required to understand and evaluate the concepts and themes explored in this thesis.
@semanticsegmentation introduces the topic of semantic segmentation as well as general principles of deep learning. @sec_connectedcomponents formalizes the concept of connected components in the domain and how they give rise to the instance imbalance problem introduced in @multi-instance-semantic-segmentation. @voronoi_tessellation gives an overview of distance-based Voronoi regions that we will use to address a problem often encountered in biomedical imaging described more closely in @instance_imbalance.

== Semantic Segmentation <semanticsegmentation>
Semantic segmentation is a subset of machine learning problems in which a neural network is trained to assign a class label to every pixel in an image. This is a long-standing and important problem in many domains, such as medical imaging and autonomous driving, among others and much research has been devoted to improving the detection and delineation of objects in images. This section will cover the basics, especially with respect to binary segmentation.

=== Binary Pixel Classification

Binary semantic segmentation can be seen as the base case wherein a model is given an image with shape $(N_x,N_y)$ consisting of $N=N_x*N_y$ pixels ($(N_x,N_y,N_z)$ in the case of 3D, where the $N=N_x*N_y*N_z$ discrete units are called voxels) and accompanying binary label maps of the same shape indicating "foreground" (pixels where the label is $1$) and "background" (where the label is $0$). For simplicity, the terms pixels and voxels are used interchangeably in the remainder of this work. From these inputs, the model is then asked to learn meaningful features to generalize to unseen data. @figsemanticinput shows a sample of information provided to a network in a binary semantic segmentation problem. The label $Y$ can be seen as an ordered sequence of discrete pixels or voxels $y_i$:

$
  Y: {y_1, y_2, dots, y_N | y_n in {0,1}}
$<eq_label>

This is also called the reference annotation of the accompanying image. This annotation in segmentation problems is usually obtained through domain experts meticulously identifying and delineating the different classes in the input images.

#figure(
  grid(
    columns: 3,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/epfl_sample_image.png", width: 95%), image("../figures/epfl_sample_label.png", width: 95%), image("../figures/mito_semantic.png", width: 95%),
  ),
  caption: [An example of a binary semantic segmentation problem. A neural network is given an image (left) with an accompanying binary label $Y$ (center) that indicates the belonging of certain pixels in the image to certain classes. In the shown case, it differentiates between background (black) and mitochondria (white). The right image shows how the label overlaps with the image.
  ],
) <figsemanticinput>

The aim of semantic segmentation is to train a classifier that can approximate $Y$ and generalize to unseen data. We will refer to the output of the classifier as the prediction $hat(Y)$:

$
  hat(Y): {hat(y)_1, hat(y)_2, dots, hat(y)_N | hat(y)_n in {0,1}}
$<eq_pred>

This classifier is given an input image and produces a binary output image corresponding to the predicted label map.

During the training phase of the classifier, a function is needed that quantifies the deviation of the prediction $hat(Y)$ to the label $Y$ to provide a learning signal to the classifier, ensuring it can adjust its parameters to minimize this error.

This signal can be calculated through the accumulation of each pixel into one of 4 sets based on its predicted and ground truth class. These sets can be seen in @taberrorclassification. The shorthands @tp:short, @fp:short, @fn:short and @tn:short for @tp:long, @fp:long, @fn:long and @tn:long respectively are used as natural numbers, denoting the number of pixels in their set.

#figure(
  table(
    columns: (auto, auto, auto),
    inset: 10pt,
    align: horizon,
    table.header([], [$hat(y)_n=1$], [$hat(y)_n=0$]),
    [$y_n=1$],
    table.cell(fill: class_colors.at(0))[True positive (TP)],
    table.cell(fill: class_colors.at(1))[#text(fill: white)[False negative (FN)]],
    [$y_n=0$],
    table.cell(fill: class_colors.at(2))[False positive (FP)],
    table.cell(fill: class_colors.at(3))[True Negative (TN)],
  ),
  caption: [A table showing the classification of predicted pixels into sets describing their relation to the ground truth label. Each pixel is necessarily part of one of the above classifications. Colors represent an intuitive visual guide for later reference.
  ],
)<taberrorclassification>

=== Loss Functions<sec_lossfunctionsbg>

Typically, the number of pixels in each category is used in a formula that describes how well the classifier can predict the label map. This is called the loss function of a neural network. A starting definition for a loss function is a function $cal(L)$ that takes as arguments the ground truth label $Y$ and the predicted binary segmentation $hat(Y)$. From this, it calculates a scalar value quantifying prediction quality. A common choice for this loss function is based on the @dsc, a popular segmentation metric that quantifies the overlap of the prediction and label and returns a value from 0 to 1:

$
  "DSC"=frac(2 times "TP", 2times"TP"+"FP"+"FN")
$<eqDSC>

The closer the value of @dsc is to $1$, the better the segmentation result is said to be. Therefore, minimizing $cal(L)_"DSC"=1-"DSC"$ would be a simple training objective for a segmentation network.

However, $cal(L)_"DSC"$ (also known as the hard dice) is not differentiable, as it operates on the binary prediction map obtained through a thresholding step. In soft dice $cal(L)_"Dice"$, the loss does not operate directly on $hat(Y)$, but rather on the sigmoid confidence probabilities $tilde(Y)$. Each element in $tilde(Y)$ describes the continuous probability in $[0,1]$ that the pixel in question belongs to the foreground class:

$
  tilde(Y): {tilde(y)_1, tilde(y)_2, dots, tilde(y)_N | tilde(y)_n in [0,1]}
$

In order to enable network optimization through backpropagation, these probabilities, together with the reference label, are passed to loss functions to compute the differentiable learning signal:

$
  cal(L)_"Dice" (Y,tilde(Y)) =1-frac(2sum_(n=1)^N tilde(y)_(n)y_n, sum_(n=1)^N (tilde(y)_n^2+y_n^2))
$<eqLDiceunweighted>

$cal(L)_"Dice"$ is frequently paired with a pixel-wise error metric based on @bce, which evaluates every pixel's class probability independently based on how close it is to the actual label value.

$
  cal(L)_"BCE" (Y,tilde(Y)) =-frac(1,N) sum_(n=1)^N [y_n log tilde(y)_n+(1-y_n) log(1-tilde(y)_n)]
$<eqLBCEunweighted>

$cal(L)_"Dice"$ and $cal(L)_"BCE"$ are often combined into a compound loss function $cal(L)_"DiceCE"$ in the formulation:

$
  cal(L)_"DiceCE"=cal(L)_"Dice"+cal(L)_"BCE"
$<eqdicece>

This hybrid formula leverages the strengths of both metrics, serving as a robust and flexible learning signal for modern segmentation networks.

Another common loss function — particularly in medical image segmentation — is $cal(L)_"Tversky"$ which introduces hyperparameters $alpha_"T", beta_"T"$ that serve to control the punishment of pixels classified as @fp:short and @fn:short respectively.

$
  cal(L)_"Tversky" (Y,tilde(Y), alpha_"T", beta_"T")=
  \
  1-frac(sum_(n=1)^N tilde(y)_n y_n, sum_(n=1)^N tilde(y)_n y_n + alpha_"T" sum_(n=1)^N tilde(y)_i (1-y_n) + beta_"T" sum_(n=1)^N (1-tilde(y)_n) y_n)
$<eqLTverskyunweighted>
This provides additional control in the model's segmentation behavior. Particularly in medical imaging problems like tumor detection, penalizing false negatives to a higher degree is often desirable @salehi2017tversky.

Similarly to @eqdicece, additional compound loss functions can be composed as $cal(L)_"DiceTversky"$ or $cal(L)_"CETversky"$.

The various modifications to loss functions that we use in this work are described in @sec_loss_functions_method.

=== Network Optimization <sec_networkoptimization>
A segmentation network is trained in discrete steps that incorporates the gradient of the loss function as well as a scaling learning rate parameter $alpha_"lr"$ in the *optimization rule*. The optimization iteratively updates the classifier's parameters $theta$ at a discrete time step $k$ to the next parameters at time $k+1$:
$
  theta_(k+1)=theta_k-alpha_("lr") gradient cal(L)(theta_k)
$
The learning rate parameter $alpha_"lr"$ scales the magnitude of parameter updates. It is often visualized as a step size along the gradient landscape of the model, the higher the learning rate, the larger the steps and the faster the parameters can approach an optimum. However, this can also lead to instability and "overshooting" of optimal parameters.

Because of its high impact on the optimization dynamics, the learning rate is an important experimental variable to determine and control for in comparisons.

=== Weight Maps <sec_weight_maps_bg>
Weight maps are tensors of the same shape as the image and label, utilized in segmentation tasks to introduce biases in order to steer loss behaviour. Individual voxels are assigned a numerical value that determines the importance of that point, resulting in a higher loss in regions that are deemed critical.
They can be formulated similarly to $Y$ and $hat(Y)$:
$
  W : {w_1, w_2, dots, w_N | w_n in RR}
$<eq_weightmap>
In order to maintain consistency in the total theoretical loss magnitude and prevent unintended scaling of the gradients, a constraint is applied to ensure the sum of the weight map is equalized to the number of voxels in the image:
$
  sum_(w in W) w = N
$
Weight maps allow for targeted spatial biases to be manually or algorithmically injected to the loss calculation, punishing the model more if it mis-identifies important areas of the image. A concrete formulation of several weight maps and how they are applied to different loss functions is proposed in @sec_weight_maps_method.

== Connected Components <sec_connectedcomponents>
The connected components algorithm is a procedure in computer vision which provides a way to differentiate between subsets of a space. These subsets, in the context of binary segmentation, are instances determined by the previously described binary label map and a connectivity parameter. In the application of pixelated images, interconnectedness of components is determined by the neighborhood $cal(N)$ of a pixel or voxel $p in [N]$.

Formally, the labels can be decomposed into $I$: the set of $K$ spatially separate components $I:{I_1, I_2, dots, I_K}$ (also called instances). Each instance $I_k in I$ contains a set of pixels (in 2D) or voxels (in 3D) such that $I_k = {p_1, p_2, dots}$ and:
1. For every pair of points $p,q in I_i$, there exists a sequence of points $(v_1, v_2, dots, v_f)$ such that $v_1=p$, $v_f=q "and" 1 lt.eq m lt f, v_m in I_i$ and $v_(m+1) in cal(N)(v_m)$. This ensures that between two pixels of the same instance, there exists a path that travels strictly within that same instance.
2. For any point $p in I_i$ and any point $q in.not I_i$ if $Y(q)=1$, then $q in.not cal(N)(p)$. Therefore $I_i$ is the largest possible set of connected foreground pixels.
3. For all $i, j in [K], i eq.not j: I_i inter I_j eq emptyset$, meaning instances are disjointed and each foreground pixel belongs to exactly one instance.

The neighborhood $cal(N)(p)$ is defined by the connectivity parameter $k$. This typically refers to the number of adjacent elements considered. @figneighborhood shows a visual overview of several common neighborhood concepts. Different connectivity parameters need to be chosen based on the dimension of the space (2D vs. 3D).

Using this formulation, it becomes apparent that a partition is formed such that all instances comprise the set of foreground pixels.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/neighborhood.png", width: 90%),
  ),
  caption: [Several common neighborhood principles are shown. A red square denotes the pixel/voxel $p$, green squares are squares for which $cal(N)(p) = 1$. The remaining pixels/voxels are outside the neighborhood and therefore $cal(N)(p)=0$. Both a) and b) show the 2D case of 4- and 8-connectivity respectively. c) and d) show a 3D volume in which the neighborhoods with connectivity 6 and 26 extend to voxels in an additional dimension.
  ],
) <figneighborhood>

== Multi-Instance Semantic Segmentation <multi-instance-semantic-segmentation>
This section combines the topics introduced previously into the domain of multi-instance semantic segmentation. This is a special subset of problems in semantic segmentation in which the number of connected component foreground instances $K$ is especially large. While there exists no formal definition of the number of instances required to classify a given segmentation problem as multi-instance, there are many cases in which this delineation makes sense.

It is important to differentiate between multi-instance semantic segmentation and instance segmentation. Though they carry similar names, they are fundamentally different topics in machine learning. @figinstancevssemantic shows the difference between these two approaches: Instance segmentation aims to train networks to differentiate between thematically separate objects in an image though they might be connected in the sense described in @sec_connectedcomponents. To achieve this, the thematically distinct objects are distinguished during the labeling process by assigning individual labels to each instance. This is fundamentally incompatible with binary segmentation, as follows from @eq_label.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    image("../figures/EM_instances_zoomed.png", width: 100%), image("../figures/connected_components.png", width: 75%),
  ),
  caption: [Left: An annotated sample of an instance segmentation dataset depicting individual labels for excitatory neurons. An image portion has been enlarged to show how the base labels are differentiated even though the cells are connected. Right: Distinct connected components identified on a sample image of mitochondria. Each individual connected component is assigned a unique color based on spatial separation.
  ],
) <figinstancevssemantic>

== Voronoi Tessellation <voronoi_tessellation>
The Voronoi tessellation algorithm is a fundamental building block of the approach outlined in this thesis. It describes a method of partitioning a space into regions based on certain points within the space.

This algorithm is especially suited to multiple spatially separated instances which are used to define the regions and their borders.

In the simple case of the 2D image plane, a finite set of $K$ pixels $P = {p_1, p_2, ..., p_K | p_i in ZZ^2}$ must be given to "seed" the set of regions (also called cells) $R = {R_1, R_2, dots, R_K | R_k subset ZZ^2}$. All other points $x in ZZ^2$ in the plane are assigned the region that minimizes a distance function $"d": ZZ^2 times ZZ^2 mapsto RR$.


$
  R_k = {x in ZZ^2 | "d"(x, p_k) lt.eq "d"(x, p_j), forall j in [K]}
$

Although Voronoi tessellation does not specify a distance function, Euclidean distance is most commonly used.

This definition can be analogously expanded to higher dimensional metric spaces (in our case 3D images with voxels instead of pixels). There lies a nuance in the discrete image space, where $"d"(x, p_i) = "d"(x, p_j)$, i.e. distances between two seeds are equal and the assignment tie needs to be broken. There are many potential solutions, however the most common approach is arbitrary yet deterministic assignment @virtanen2020scipy.

In our case of image segmentation, there are not single seed points, but rather seed instances $I$, which are modeled as sets. This gives rise to the generalized Voronoi diagram, where the distance function $"d"$ defines the distance from a pixel $x$ to a non-empty set of pixels/voxels $I_k$:
$
  "d"(x, I_k) = min_(p in I_k)"d"(x,p)
$

The Voronoi region $R_k subset {1, dots, N}$ associated with the seed instance $I_k$ is then a subset of the image:
$
  R_k = {x in [N] | "d"(x, I_k) lt.eq "d"(x,I_j) forall j in [K], j eq.not k}
$

These distances can be efficiently computed using the @edt algorithm. @figvoronoi shows the output of a 2D Voronoi tessellation on an image with seed instances. Each region is assigned its own color and contains no instances other than the one that seeded it.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/voronoi_regions.png", width: 70%), image("../figures/voronoi3D.png", width: 80%),
  ),
  caption: [Tessellated sample images showing both the voronoi regions and the foreground instances that gave rise to them in 2D as well as 3D. Each region $R_k$ contains precisely one instance $I_k$. Voronoi regions are based on the euclidean distance.
  ],
) <figvoronoi>

== The Instance Imbalance Problem <instance_imbalance>
The eponymous multiple instances in multi-instance segmentation stem from the specific problem domain wherein images contain many of these spatially separate components. Biomedical imaging is a domain which contains many such problem settings. Anatomies or pathologies can manifest as many spatially separate instances of the same class. Examples of these include many types of cancers such as liver tumors or brain metastases, but also anatomical features such as cells or their organelles. Specific examples of such applications are shown in @sec_datasets.

These cases often contain instances of diverse shapes, sizes, and numbers. Since the data implicitly steers the behaviour of the neural network through the loss function, a phenomenon occurs in which loss functions implicitly prioritize larger instances to improve the segmentation loss signal @kofler2023blobloss @jaus2025every.

When considering such cases, instance size disparities and other variations can influence computational algorithms in ways that are not always true to clinical reality. In the case of many cancers for example, lesion size does not always correspond to clinical relevance and smaller cancer lesions can be malignant, while larger ones might be benign. In such cases, assigning a higher importance to larger instances, whether it be implicit or explicit, can lead to undesirable outcomes.

This phenomenon can be seen in exemplary loss function values shown in @figinstanceimbalance where the commonly used dice loss provides the same training signal for both segmentations whereas the smaller instance is missed entirely. This can lead to implicit prioritization of the larger instance during training, as the models tend to focus on refining existing true positives over identifying missed instances.

#figure(
  grid(
    columns: 3,
    row-gutter: 2mm,
    column-gutter: -15mm,
    align: center + horizon,
    image("../figures/DSC075_1.png", width: 65%), image("../figures/DSC075_2.png", width: 65%), image("../figures/DSC075_3.png", width: 70%),
  ),
  caption: [Two visualizations of a predicted segmentation overlapped with a ground truth label. Colors correspond to the error classification:  #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(0), stroke: 0.1pt)) TP, #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(1), stroke: 0.1pt)) FN, #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(2), stroke: 0.1pt)) FP, #box(inset: 0pt, rect(width: 0.8em, height: 0.8em, fill: class_colors.at(3), stroke: 0.1pt)) TN. In both cases $"DSC"=0.75$. During training, $cal(L)_"DSC"$ would provide the same signal to adjust the parameters of the classifier.],
) <figinstanceimbalance>

The issue arises because the loss function used is inherently not instance-aware, since it simply operates on the number of pixels classified as @tp:short, @fp:short, @fn:short.
