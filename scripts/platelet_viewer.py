import time
import numpy as np
from tifffile import imread
import napari
from skimage.measure import label
from scipy.ndimage import distance_transform_edt
from tqdm import tqdm

# ----------------------------------------------------
# Utility: Pretty Logging
# ----------------------------------------------------


def log(msg):
    print(f"[INFO] {msg}")


def timed_step(step_name):
    """
    Context manager for timing named preprocessing steps.
    """
    class _Timer:
        def __enter__(self):
            log(f"Starting: {step_name}")
            self.start = time.perf_counter()
            return self

        def __exit__(self, exc_type, exc_val, exc_tb):
            elapsed = time.perf_counter() - self.start
            log(f"Completed: {step_name} (elapsed: {elapsed:.2f}s)")
    return _Timer()


# ----------------------------------------------------
# Configuration
# ----------------------------------------------------
IMAGE_FILE = "data/platelet-em/images/50-images.tif"
LABEL_FILE = "data/platelet-em/labels-semantic/50-semantic.tif"

platelet_em_index_to_class = {
    0: 'background',
    1: 'cell',
    2: 'mitochondrion',
    3: 'alpha granule',
    4: 'canalicular vessel',
    5: 'dense granule',
    6: 'dense granule core'
}

log("Initializing preprocessing pipeline")

# ----------------------------------------------------
# Data Loading
# ----------------------------------------------------
with timed_step("Loading EM image stack"):
    images = imread(IMAGE_FILE)
    log(f"EM image shape: {images.shape}, dtype: {images.dtype}")

with timed_step("Loading semantic RGB labels"):
    semantic_rgb = imread(LABEL_FILE)
    log(f"Semantic label shape: {semantic_rgb.shape}, dtype: {semantic_rgb.dtype}")

# ----------------------------------------------------
# RGB → Semantic Index Conversion
# ----------------------------------------------------
with timed_step("Converting RGB labels to semantic mask"):
    data_points = semantic_rgb.reshape(-1, semantic_rgb.shape[-1])
    unique_colors, indices = np.unique(
        data_points, axis=0, return_inverse=True
    )
    semantic_mask = indices.reshape(
        semantic_rgb.shape[:-1]
    ).astype(np.uint8)

    log(f"Detected {len(unique_colors)} unique semantic colors")

# ----------------------------------------------------
# 3D Voronoi Computation
# ----------------------------------------------------


def compute_3d_voronoi(mask):
    """
    Computes 3D Voronoi regions based on instance boundaries.
    """
    instance_labels = label(mask > 0, connectivity=2)

    if instance_labels.max() == 0:
        return np.zeros_like(mask)

    _, indices = distance_transform_edt(instance_labels == 0, return_indices=True)

    voronoi_3d = instance_labels[indices[0], indices[1], indices[2]]

    return voronoi_3d.astype(np.uint16)


# ----------------------------------------------------
# Napari Visualization
# ----------------------------------------------------
with timed_step("Initializing Napari viewer"):
    viewer = napari.Viewer(ndisplay=3)

    viewer.add_image(
        images,
        name='EM Image Stack',
        colormap='gray',
        opacity=0.7
    )

    viewer.add_labels(
        semantic_mask,
        name='Original Semantic Labels',
        opacity=0.9
    )

# ----------------------------------------------------
# Per-Class Voronoi Expansion (Progress Bar)
# ----------------------------------------------------
log("Computing per-class 3D Voronoi volumes")

for class_idx in tqdm(
    range(1, 7),
    desc="Voronoi expansion per semantic class",
    unit="class"
):
    class_name = platelet_em_index_to_class[class_idx]
    class_mask = (semantic_mask == class_idx)

    if not np.any(class_mask):
        log(f"Skipping class '{class_name}' (no voxels present)")
        continue

    start = time.perf_counter()
    class_voronoi = compute_3d_voronoi(class_mask)
    elapsed = time.perf_counter() - start

    log(
        f"Voronoi computed for '{class_name}' "
        f"(elapsed: {elapsed:.2f}s, "
        f"instances: {class_voronoi.max()})"
    )

    viewer.add_labels(
        class_voronoi,
        name=f'Voronoi: {class_name}',
        visible=False,
        opacity=0.45
    )

log("Launching Napari event loop")
napari.run()
