#import "../utils.typ": todo

= Background <chapter_background>
This section is dedicated to the knowledge required for the understanding and evaluation of the concepts and themes explored in this thesis.
It will aim to preserve the most common definitions in the field as they currently stand.  @semanticsegmentation will introduce the topic of semantic segmentation and @connectedcomponents will aim to differentiate and formalize specific concepts in the domain and how these concepts give rise to the problem space introduced in @multi-instance-semantic-segmentation at the core of this thesis. @voronoi_tesselation gives an overview and a definition of the separation of that space into distance-based regions that aims to address a problem introduced in @instance_imbalance that is often encountered in biomedical imaging.

== Semantic Segmentation <semanticsegmentation>
Semantic Segmentation is a subset of mainly supervised learning problems in which a neural network is trained to assign a class label to every pixel in an image. This is an aged and important problem in many domains such as medical imaging and autonomous driving among others and much research has been devoted to improving the detection and delineation of objects in images.

Binary semantic segmentation can be seen as the base case wherein a model is given an image with accompanying binary labels of the same shape indicating "foreground" and "background". From this, the model is then asked to learn meaningful features to generalize to unseen data. @semanticinput shows a sample of information provided to a network in a binary semantic segmentation problem. In the image domain $Omega$, the label can be seen as a function $"L": Omega mapsto {0,1}$ operating on discrete pixels or voxels:

$
  "L"(p) = cases(
    1 "if" p "is foreground",
    0 "else"
  )
$<labelfunction>

This gives rise to the set of all foreground pixels $S={p in Omega | L(p) = 1}$.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/epfl_sample_image.png", width: 65%),
    image("../figures/epfl_sample_label.png", width: 65%),
  ),
  caption: [
    The input of a binary semantic segmentation problem. A neural network is given an image (left) with an accompanying binary label (left) that indicates the belonging of certain pixels in the image to certain classes. In the shown case, it differentiates between background (black) and foreground mitochondria (white).
  ],
) <semanticinput>

== Connected Components <connectedcomponents>
Connected components describe a notion in computer vision which provides a way to differentiate between subsets of a space. These subsets in our case of binary segmentation are instances determined by the previously described binary label map and a connectivity parameter. In the application of pixelated images, interconnectedness of components is determined by the neighborhood $N$ of a pixel $p$.

Formally, the labels can be decomposed into @I:short: @I:long, the set of $n$ spatially separate components (also called instances). Each instance $I_i in I$ contains a set of pixels (in 2D) or voxels (in 3D) such that $I_i = {p_1, p_2, dots}$ and:
#list(
  [For every pair of points $p,q in I_i$, there exists a sequence of points $(v_1, v_2, dots, v_k)$ such that $v_1=p$, $v_k=q "and" forall q lt.eq m lt k, v_m in I_i$ and $v_(m+1) in N(v_m)$. This ensures that between two pixels of the same instance, there exists a path that travels strictly within that same instance.],
  [For any point $p in I_i$ and any point $q in.not I_i$ if $L(q)=1$, then $q in.not N(p)$: A pixel can not belong to multiple instances.],
  [For all $i eq.not j, I_i inter I_j eq emptyset$, meaning each pixel belongs to exactly one instance.]
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
    Several common neighborhood principles are shown. A red square denotes the pixel/voxel $p$, green squares are squares for which $N(p) = 1$. The remaining pixels/voxels are outside the neighborhood and therefore $N(p)=0$. Both a) and b) show the 2D case of 4- and 8-connectivity respectively. c) and d) with connectivity 6 and 26 show a 3D volume in which the neighborhood contains voxels in an additional dimension.
  ],
) <figneighborhood>

== Multi-Instance Semantic Segmentation <multi-instance-semantic-segmentation>
This section combines the topics introduced previously into the domain of multi-instance semantic segmentation. This is a special subset of problems in semantic segmentation in which the number of connected component foreground instances $|L|$ is especially large. While there exists no formal definition of the number of instances required to classify a given segmentation problem as multi-instance, there are many cases in which this delineation makes sense.

It is important to differentiate between multi-instance semantic segmentation and instance segmentation. Though they carry similar names, they are fundamentally different topics in machine learning. @instancevssemantic shows the difference between these two approaches: Instance segmentation aims to train networks to differentiate between thematically separate objects in an image though they might be connected in the sense described in @connectedcomponents. To achieve this, the thematically seperated objects are distinguished during the labeling process, assigning separate labels to each instance. This is fundamentally incompatible with binary segmentation, as can be gathered from @labelfunction.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    image("../figures/EM_instances_zoomed.png", width: 100%),
    image("../figures/connected_components.png", width: 75%),
  ),
  caption: [
    Left: An annotated sample of an instance segmentation dataset depicting individual labels for excitatory neurons. An image portion has been enlarged to show how the base labels are differentiated even tough the cells are connected. Right: Distinct connected components identified on a sample image of mitochondria. Each individual connected component is assigned its own color based on spatial separation.
  ],
) <instancevssemantic>

== Voronoi Tesselation <voronoi_tesselation>
The Voronoi tesselation algorithm is a fundamental building block of the approach outlined in this thesis. It describes a method of partitioning a space into regions based on certain points within the space.

This algorithm is especially suited to multiple spatially separate instances which are used to define the regions and their borders.

In the simple case of the euclidean plane, a finite set of 2D points $P = {p_1, p_2, ..., p_n}, subset.eq RR^2$ must be given to "seed" the set of regions (also called cells) @R:short: @R:long $subset.eq RR^2$. All other points $x in RR^2$ in the plane are assigned the region that minimizes some distance function @d:short: @d:long#footnote[Though Voronoi tesselation does not specify a distance function, euclidean distance is most commonly used.]:

$
  R_i = {x in RR^2 | d(x, p_i) lt.eq d(x, p_j), forall j eq.not i}
$

This definition can be analagously expanded to higher dimensional metric spaces.

In our case of image segmentation, there are not single seed points, but rather seed instances @I:short, the surfaces of which are the points on which the distances are calculated. Any point within the instance boundary trivially has a distance of 0 to the nearest instance. Points outside the instance are assigned based on their distance to the nearest instance boundary. @voronoifigure shows the output of a Voronoi tesselation.

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 2mm,
    image("../figures/voronoi_regions.png", width: 65%),
  ),
  caption: [
    A tesselated sample image showing both the voronoi regions and the foreground instances that gave rise to them. It can be plainly seen that each region contains precisely one instance.
  ],
) <voronoifigure>

#todo("Figure: An example of Voronoi partitioning in 2D and 3D")

#todo("Formalize this and describe the 3D case and instances instead of points")

== The Instance Imbalance Problem <instance_imbalance>
Instance imbalance refers to the issue of certain objects of which there are multiple present in a scene being represented different from other objects of the same type.

These objects are commonly called instances and are of particular interest in certain problems in object detection and segmentation, since many types of objects manifest as spatially separate and morphologically varied. Spatial separation is of particular note, as the content of this work does not concern itself with and should not be confused with instance segmentation. Instance segmentation identifies fundamentally separate objects from spatially overlapping views.

In multi-instance semantic segmentation, no such overlap is considered. Spatial searation is the definition of object differentiation. The eponymous multiple instances stem from the specific problem domain wherein views can be said to generally contain many of these spatially separate instances. Biomedical imaging is a domain which contains many such problem cases. Where anatomies or pathologies manifest as many spatially separate instances. Examples of instance segmentation and multi-instance semantic segmentation can be seein in #todo where annotated sample images from both domains are juxtapositioned.

Particular problems arise when considering such cases, where instance size disparaties and other variations can influence computational algorithms in ways that are not always true to clinical reality. In the case of many cancers for example, lesion size does not always correspond to clinical relevance and smaller cancer lesions can be malignant while larger ones might be benign. In such cases, assigning a higher importance to larger instances, whether it be implicit or explicit, can lead to undesirable outcomes.

This thesis aims to address and explore this issue, evaluating different approaches of compensating for biases in the computed importance of different instances.