#import "../utils.typ": todo
= Conclusion <conclusion>
This thesis explored the various uses of geometric tessellation in multi-instance segmentation networks in order to address a critical shortcoming of many modern segmentation networks: Volumetric biases in loss function dynamics lead to the underperformance of standard global DiceCE loss on the segmentation of smaller instances.

We showed that utilizing Voronoi tessellation to compute distance-based regions in ground truth labels provides a flexible paradigm to ensure a models learning process can be influenced to address this issue. Region-wise loss functions and Voronoi-based weight maps aimed to equalize volumetric bias can improve important segmentation metrics on small yet clinically relevant instances.

Notably, the introduction of $cal(L)_"Voronoi"$ provided consistent improvement on both global, pixel-wise as well instance-based segmentation metrics. We recommend the incorporation of such a loss component in addition to the standard global loss in order to improve small instance segmentation as well as keep the global image context present in the network's learning mechanism. While the balance of global- and region-wise loss weights plays an important role and needs to be explored on a per-dataset basis, assigning equal importance to both components provides a simple way to improve general segmentation performance on all tested datasets.



== Future Work <future_work>
While we believe that this thesis has shown clear advancements in multi-instance segmentation, there remains work to be done to generalize some of our approaches to diverse data. 

*Weight map refinements*

The impact of weight maps on segmentation performance proved to be inconsistent across, hindering their general-purpose adaptability. While they are able to introduce manual corrections to loss biases, more research and experimentation is needed to develop more solid heuristics on weight map construction that takes dataset instance statistics into account.

*Integration into automated frameworks*

The state-of-the-art in medical image segmentation is nnU-Net, a framework that automatically adapts model parameters to a given dataset, achieving high segmentation performance out-of-the-box. While we did not use this framework to validate our approaches due to its rigidity; an integration of true, globally precomputed Voronoi tessellation and easily customizable weight maps would provide a valuable addition to the current medical image segmentation landscape.
