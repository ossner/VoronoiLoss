#import "../utils.typ": todo

= Introduction <chapter_introduction>
#todo("Easy intro")
== Addressing the Instance Imbalance Problem <instance_imbalance>
Instance imbalance refers to the issue of certain segmentation instances in biomedical images to be larger than others, causing a bias in common segmentation losses that will lead to smaller instances being harder to segment. This issue is especially problematic when the pathology to be segmented shows no correlation between size and clinical relevance. This makes the segmentation of smaller instances a high-stakes issue.
@rachmadi2024family @kofler2023blobloss @zhang2021lesloss @rachmadi2024iciloss
== Voronoi Tesselation <voronoi_tesselation>
Voronoi diagrams are a fundamental building block of the approach outlined in thie thesis. They define a partition of a space into regions. In the simple case of the euclidean plane, a finite set of points ${p_1, p_2, ..., p_n}, n in NN$ must be given. Each point $p_i, i in [n]$ is assigned a region $R_i$. All other points in the plane are assigned the region that minimizes some distance function $d$:

$
  R_k = {x in X | d(x, P_k) lt.eq d(x, P_j), forall j eq.not k}
$

In our case, there are 
 #todo("Formalize this and describe the 3D case and instances instead of points")
== Connected Components
#todo("Connectivity, formal definition and clinical principal impact")