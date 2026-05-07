#import "../utils.typ": todo, class_colors

= Background <chapter_background>
This section is dedicated to the knowledge required for the understanding and evaluation of the concepts and themes explored in this thesis.
It will aim to preserve the most common definitions in the field as they currently stand.  @semanticsegmentation will introduce the topic of semantic segmentation as well as general principles of deep learning and @connectedcomponents will aim to differentiate and formalize specific concepts in the domain and how these concepts give rise to the problem space introduced in @multi-instance-semantic-segmentation at the core of this thesis. @voronoi_tessellation gives an overview and a definition of the separation of that space into distance-based regions that aims to address a problem introduced in @instance_imbalance that is often encountered in biomedical imaging.

== Semantic Segmentation <semanticsegmentation>
Semantic Segmentation is a subset of mainly supervised learning problems in which a neural network is trained to assign a class label to every pixel in an image. This is an aged and important problem in many domains such as medical imaging and autonomous driving among others and much research has been devoted to improving the detection and delineation of objects in images. This section will cover the basics especially with respect to binary segmentation.

=== Binary Pixel Classification

Binary semantic segmentation can be seen as the base case wherein a model is given an image with shape $(h,w)$ ($(h,w,d)$ in the case of 3D#footnote[A 2D image is said to be composed of discrete pixels, while a 3D image is composed of voxels.]) with accompanying binary labels of the same shape indicating "foreground" (pixels where the label is $1$) and "background" (where the label is $0$). From this, the model is then asked to learn meaningful features to generalize to unseen data. @figsemanticinput shows a sample of information provided to a network in a binary semantic segmentation problem. In the image domain $Omega$, the label can be seen as a map $Y: Omega mapsto {0,1}$ operating on discrete pixels or voxels $p$:

$
  Y(p) = cases(
    1 "if" p "is foreground",
    0 "else"
  )
$<labelfunction>

This is also called the *ground truth* segmentation of the accompanying image. The ground truth in segmentation problems is usually obtained through domain experts meticulously identifying and delineating the different classes in the input images.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/epfl_sample_image.png", width: 65%), image("../figures/epfl_sample_label.png", width: 65%),
  ),
  caption: [
    The input of a binary semantic segmentation problem. A neural network is given an image (left) with an accompanying binary label $Y$ (right) that indicates the belonging of certain pixels in the image to certain classes. In the shown case, it differentiates between background (black) and foreground mitochondria (white).
  ],
) <figsemanticinput>


The aim of semantic segmentation is to train a classifier that can approximate $Y$ and generalize to unseen data, we'll call the output of the classifier the *prediction* $hat(Y): Omega mapsto {0,1}$. This classifier is given an input image and it will produce a binary output image corresponding to the predicted label map.

During the training phase of the classifier, a function is needed that quantifies the deviation of the prediction to the ground truth to provide a learning signal to the classifier, ensuring it can adjust its parameters to minimize this error. This is done through the accumulation of each pixel into one of 4 sets that can be seen in @taberrorclassification based on its predicted and ground truth class. The classifications are considered to be natural numbers, denoting the number of pixels in their set.

#figure(
  table(
    columns: (auto, auto, auto),
    inset: 10pt,
    align: horizon,
    table.header([], [$hat(Y)(p)=1$], [$hat(Y)(p)=0$]),
    [$Y(p)=1$],
    table.cell(fill: class_colors.at(0))[True positive (TP)],
    table.cell(fill: class_colors.at(1))[False negative (FN)],
    [$Y(p)=0$],
    table.cell(fill: class_colors.at(2))[False positive (FP)],
    table.cell(fill: class_colors.at(3))[True Negative (TN)],
  ),
  caption: [
    A table showing the classification of predicted pixels into sets describing their relation to the ground truth label. Each pixel is necessarily part of one of the above classifications. Thus forming a partition of the image. Colors represent an intuitive visual guide for later reference.
  ],
)<taberrorclassification>

=== Loss Functions

Clasically, the number of pixels in each category are used in a formula that describes how well the classifier can predict the label map, this is called the loss function of a neural network. Loss functions will be described in greater detail in later chapters. For now, a general definition of a function that takes the ground truth label $Y$ and the predicted segmentation $hat(Y)$ to produce a scalar value quantifying prediction quality $L: Y times hat(Y) mapsto RR$ will suffice. #todo("technically should be Omega, but does this work too?")

A common choice for this loss function is based on the dice metric:

$
  "DSC"=frac(2 times "TP",2times"TP"+"FP"+"FN")
$
The closer the value of $"DSC"$ is to $1$, the "better" the segmentation result is said to be. Which is why minimizing $L_("Dice")=1-"DSC"$ is a commonly used training goal for the classifier. Other formulations of loss functions are to follow in @related_work.

=== Network Optimization
The network classifier described above is trained in discrete steps that incorporate the loss function as well as a scaling learning rate parameter $alpha_"lr"$ in the *optimization rule*
$
  theta_(k+1)=theta_k+alpha_("lr") gradient cal(L)(theta_k)
$

== Connected Components <connectedcomponents>
Connected components describe a notion in computer vision which provides a way to differentiate between subsets of a space. These subsets in our case of binary segmentation are instances determined by the previously described binary label map and a connectivity parameter. In the application of pixelated images, interconnectedness of components is determined by the neighborhood $N$ of a pixel $p$.

Formally, the labels can be decomposed into @I:short: @I:long, the set of $n$ spatially separate components (also called instances). Each instance $I_i in I$ contains a set of pixels (in 2D) or voxels (in 3D) such that $I_i = {p_1, p_2, dots}$ and:
#list(
  [For every pair of points $p,q in I_i$, there exists a sequence of points $(v_1, v_2, dots, v_k)$ such that $v_1=p$, $v_k=q "and" forall q lt.eq m lt k, v_m in I_i$ and $v_(m+1) in N(v_m)$. This ensures that between two pixels of the same instance, there exists a path that travels strictly within that same instance.],
  [For any point $p in I_i$ and any point $q in.not I_i$ if $Y(q)=1$, then $q in.not N(p)$: A pixel can not belong to multiple instances.],
  [For all $i eq.not j, I_i inter I_j eq emptyset$, meaning each pixel belongs to exactly one instance.],
)

The neighborhood $N(p)$ is defined by the connectivity parameter $k$. This typically refers to the number of adjacent elements considered. @figneighborhood shows a visual overview of several common neighborhood concepts. Different connectivity parameters need to be chosen based on the dimension of the space (2D vs. 3D).

Using this formulation, it becomes apparent that a partition is formed such that all instances comprise the set of foreground pixels:
$
  S = union.big_(i=1)^(n)I_i
$

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/neighborhood.png", width: 90%),
  ),
  caption: [
    Several common neighborhood principles are shown. A red square denotes the pixel/voxel $p$, green squares are squares for which $N(p) = 1$. The remaining pixels/voxels are outside the neighborhood and therefore $N(p)=0$. Both a) and b) show the 2D case of 4- and 8-connectivity respectively. c) and d) with connectivity 6 and 26 show a 3D volume in which the neighborhood extends to voxels in an additional dimension.
  ],
) <figneighborhood>

== Multi-Instance Semantic Segmentation <multi-instance-semantic-segmentation>
This section combines the topics introduced previously into the domain of multi-instance semantic segmentation. This is a special subset of problems in semantic segmentation in which the number of connected component foreground instances $|L|$ is especially large. While there exists no formal definition of the number of instances required to classify a given segmentation problem as multi-instance, there are many cases in which this delineation makes sense.

It is important to differentiate between multi-instance semantic segmentation and instance segmentation. Though they carry similar names, they are fundamentally different topics in machine learning. @figinstancevssemantic shows the difference between these two approaches: Instance segmentation aims to train networks to differentiate between thematically separate objects in an image though they might be connected in the sense described in @connectedcomponents. To achieve this, the thematically seperated objects are distinguished during the labeling process, assigning separate labels to each instance. This is fundamentally incompatible with binary segmentation, as can be gathered from @labelfunction.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    image("../figures/EM_instances_zoomed.png", width: 100%), image("../figures/connected_components.png", width: 75%),
  ),
  caption: [
    Left: An annotated sample of an instance segmentation dataset depicting individual labels for excitatory neurons. An image portion has been enlarged to show how the base labels are differentiated even tough the cells are connected. Right: Distinct connected components identified on a sample image of mitochondria. Each individual connected component is assigned a unique color based on spatial separation.
  ],
) <figinstancevssemantic>

== Voronoi tessellation <voronoi_tessellation>
The Voronoi tessellation algorithm is a fundamental building block of the approach outlined in this thesis. It describes a method of partitioning a space into regions based on certain points within the space.

This algorithm is especially suited to multiple spatially separate instances which are used to define the regions and their borders.

In the simple case of the 2D image plane ($Omega subset ZZ^2$), a finite set of pixels $P = {p_1, p_2, ..., p_n | p_i in ZZ^2}$ must be given to "seed" the set of regions (also called cells) $R = {R_1, R_2, dots, R_n | R_i subset Omega}$. All other points $x in Omega$ in the plane are assigned the region that minimizes some distance function $"d": Omega times Omega mapsto RR$#footnote[Though Voronoi tessellation does not specify a distance function, euclidean distance is most commonly used.].

$
  R_i = {x in Omega | "d"(x, p_i) lt.eq "d"(x, p_j), forall j in [n]}
$

This definition can be analogously expanded to higher dimensional metric spaces (in our case 3D images with voxels instead of pixels). There lies a nuance in the discrete image space, where $"d"(x, p_i) = "d"(x, p_j)$, i.e. distances between two seeds is equal and the assignemt tie needs to be broken. There are many potential solutions, however the most common approach is arbitrary yet deterministic assignment.

In our case of image segmentation, there are not single seed points, but rather seed instances @I:short, which are modeled as sets. This gives rise to the generalized Voronoi diagram, where the distance function $"d"$ defines the distance from a pixel $x$ to a non-empty set of pixels/voxels $I_i$:
$
  "d"(x, I_i) = min_(y in I_i)d(x,y)
$

The Voronoi region $R_i$ associated with the seed instance $I_i$ is then:
$
  R_i = {x in Omega | d(x, I_i) lt.eq d(x,I_j) forall j in [n]}
$

These distances can be efficiently computed using the @edt algorithm. @figvoronoi shows the output of a 2D Voronoi tessellation on an image with seed instances. Each region is assigned its own color and contains no instances other than the one that seeded it.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/voronoi_regions.png", width: 65%),
  ),
  caption: [
    A tessellated sample image showing both the voronoi regions and the foreground instances that gave rise to them. It can be plainly seen that each region contains precisely one instance.
  ],
) <figvoronoi>

#todo("Figure: An additional example of Voronoi partitioning in 3D")

== The Instance Imbalance Problem <instance_imbalance>
The eponymous multiple instances in multi-instance segmentation stem from the specific problem domain wherein images can be said to generally contain many of these spatially separate instances. Biomedical imaging is a domain which contains many such problem cases. Anatomies or pathologies can manifest as many spatially separate instances of the same class. Examples of these include many cancers such as liver tumors or brain metastases, but also anatomical features such as cells or their organelles. Specific examples of such applications will be discussed in @datasets.

Particular problems arise when considering such cases, especially where instance size disparaties and other variations can influence computational algorithms in ways that are not always true to clinical reality. In the case of many cancers for example, lesion size does not always correspond to clinical relevance and smaller cancer lesions can be malignant while larger ones might be benign. In such cases, assigning a higher importance to larger instances, whether it be implicit or explicit, can lead to undesirable outcomes.

This phenomenon can be plainly seen in exemplary loss function values shown in @figinstanceimbalance where the commonly used dice loss provides the same training signal for both segmentations whereas the smaller instance is missed entirely. This can lead to implicit prioritization of the larger instance during training, as the models tend to prioritize "expanding" existing true positives over identifying missed instances.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    image("../figures/DSC075_1.png", width: 65%), image("../figures/DSC075_2.png", width: 65%),
  ),
  caption: [Two visualization of a predicted segmentation overlapped with a ground truth label. In both cases $"DSC"=0.75$, which means during training, dice loss would provide the same scalar signal to adjust the parameters of the classifier.],
) <figinstanceimbalance>

The issue arises because the used loss function is inherently not instance-aware, since it simply operates on the number of pixels classified as @tp:short, @fp:short, @fn:short. 