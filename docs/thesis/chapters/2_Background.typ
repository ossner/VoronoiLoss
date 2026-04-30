#import "../utils.typ": todo

= Background <chapter_background>
This section is dedicated to the foundational knowledge required for the understanding and evaluation of the concepts and themes explored in this thesis.
It will aim to preserve the most common definitions in the field as they currently stand.

== Addressing the Instance Imbalance Problem <instance_imbalance>
Instance imbalance refers to the issue of certain objects of which there are multiple present in a scene being represented different from other objects of the same type.

These objects are commonly called instances and are of particular interest in certain problems in object detection and segmentation, since many types of objects manifest as spatially separate and morphologically varied. Spatial separation is of particular note, as the content of this work does not concern itself with and should not be confused with instance segmentation. Instance segmentation identifies fundamentally separate objects from spatially overlapping views.

In multi-instance semantic segmentation, no such overlap is considered. Spatial searation is the definition of object differentiation. The eponymous multiple instances stem from the specific problem domain wherein views can be said to generally contain many of these spatially separate instances. Biomedical imaging is a domain which contains many such problem cases. Where anatomies or pathologies manifest as many spatially separate instances. Examples of instance segmentation and multi-instance semantic segmentation can be seein in #todo("Add figure with cellular instance segmentation and mitochondria as multiple instance semantic segmentation")

Particular problems arise when considering such cases, where instance size disparaties and other variations can influence computational algorithms in ways that are not always true to clinical reality. In the case of many cancers for example, lesion size does not always correspond to clinical relevance and smaller cancer lesions can be malignant while larger ones might be benign. In such cases, assigning a higher importance to larger instances, whether it be implicit or explicit, can lead to undesirable outcomes.

This thesis aims to address and explore this issue, evaluating different approaches of compensating for biases in the computed importance of different instances.

@rachmadi2024family @kofler2023blobloss @zhang2021lesloss @rachmadi2024iciloss


== Connected Components
Connected components are a well-established notion in topology and computer vision and a way to differentiate between non-empty disjointed subsets of a space. These subsets in our case are instances determined by a binary label map and a connectivity parameter. In the application of pixelated images, interconnectedness of components is determined by the neighborhood of a pixel within the component.

#todo("Connectivity, formal definition")

Different connectivity parameters need to be chosen based on the dimension of the space (2D vs. 3D). In this work, 2D components are connected using 8-connectivity, while 3D components are determined using 26-connectivity. This is aligned with related works.

== Voronoi Tesselation <voronoi_tesselation>
The Voronoi tesselation algorithm is a fundamental building block of the approach outlined in this thesis. It describes a method of partitioning a space into regions based on certain points within the space.

This algorithm is especially suited to multiple spatially separate instances which are used to define the regions and their borders.

In the simple case of the euclidean plane, a finite set of 2D points $P = {p_1, p_2, ..., p_n}, subset.eq RR^2$ must be given to "seed" the tesselation. Each point $p_i$ is assigned a separte region (also called cell) $R_i subset.eq RR^2$. All other points in the plane are assigned the region that minimizes some distance function $d$:

$
  R_k = {x in RR^2 | d(x, p_k) lt.eq d(x, p_j), forall j eq.not k}
$

This definition can be analagously expanded to higher dimensional metric spaces.

In our case of image segmentation, there are not single seed points, but rather seed instances, the boundaries of which are the points on which the distances are calculated. Any point within the instance trivially has a distance of 0 to the nearest instance. Points outside the instance are assigned based on their distance to the nearest instance boundary.

#todo("Figure: An example of Voronoi partitioning in 2D and 3D")

#todo("Formalize this and describe the 3D case and instances instead of points")