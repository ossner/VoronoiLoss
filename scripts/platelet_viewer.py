import numpy as np
from tifffile import imread
import napari
from skimage.measure import label, regionprops_table
from scipy.ndimage import distance_transform_edt
# ----------------------------------------------------
# Configuration
# ----------------------------------------------------
IMAGE_FILE = "data/platelet-em/images/50-images.tif"
LABEL_FILE = "data/platelet-em/labels-semantic/50-semantic.tif"
TARGET_LABEL_ID = 6 # Dense Granule Core

platelet_em_index_to_class = {
    0: 'background',
    1: 'cell',
    2: 'mitochondrion',
    3: 'alpha granule',
    4: 'canalicular vessel',
    5: 'dense granule',
    6: 'dense granule core'}

images = imread(IMAGE_FILE)
# Labels are read as a color image (T, Y, X, C)
semantic_rgb = imread(LABEL_FILE)

# --- CONVERSION STEP ---
# 1. Reshape the (T, Y, X, C) array to (T*Y*X, C) to easily find unique colors
data_points = semantic_rgb.reshape(-1, semantic_rgb.shape[-1])

# 2. Find unique color tuples (the "palette") and map them to integer IDs
unique_colors, indices = np.unique(data_points, axis=0, return_inverse=True)

# 3. indices now contains the integer class ID (0, 1, 2, ...) for every pixel.
semantic_mask = indices.reshape(semantic_rgb.shape[:-1]).astype(np.uint8)


print("--- After Conversion ---")
print("Original RGB shape:", semantic_rgb.shape)
print("Converted Mask shape:", semantic_mask.shape)
print("Number of unique classes:", len(unique_colors))
print("Converted Mask dtype:", semantic_mask.dtype)
print("Unique label IDs:", np.unique(semantic_mask))


# --- NAPARI VISUALIZATION ---

viewer = napari.Viewer(ndisplay=3)

# Add the image stack
viewer.add_image(
    images,
    name='Platelet EM Image Stack',
    colormap='gray',
    rendering='translucent'
)

# Add the original semantic mask for context
viewer.add_labels(
    semantic_mask,
    name='Semantic Segmentation Labels',
    # Turn down opacity so the Voronoi layer can also be seen
    opacity=0.3
)

# Get the Y and X dimensions for the 2D slices
T, Y, X = semantic_mask.shape

for class_index in range(1,7):
    all_centers = []
    # We will store the full Voronoi region stack here
    voronoi_stack = np.zeros_like(semantic_mask, dtype=np.uint16) 
    for t, slice in enumerate(semantic_mask):
        # 1. Identify the target objects and label them individually
        target_mask = (slice == class_index)
        labeled_blobs = label(target_mask)
        
        # 2. Get region properties, including the centroid
        props_df = regionprops_table(
            labeled_blobs, 
            properties=['label', 'centroid']
        )
        
        centroids_y = props_df['centroid-0']
        centroids_x = props_df['centroid-1']
        
        # Check if there are any centroids to process
        if len(centroids_y) > 0:
            # 3. Create a seed image for the distance transform
            # The seed image is all zeros, and we mark the centroid locations
            # with their region label (1, 2, 3, ...)
            seed_image = np.zeros((Y, X), dtype=np.uint16)
            
            # We need to map the centroids (float) to nearest integer coordinates
            # and ensure they are within the image bounds.
            centroid_coords = np.round(np.array([centroids_y, centroids_x])).astype(int)
            
            # Filter out-of-bounds coordinates (though unlikely with regionprops_table)
            valid_coords_mask = (centroid_coords[0] >= 0) & (centroid_coords[0] < Y) & \
                                (centroid_coords[1] >= 0) & (centroid_coords[1] < X)
            
            valid_y = centroid_coords[0][valid_coords_mask]
            valid_x = centroid_coords[1][valid_coords_mask]
            
            # Mark seeds with their label ID (1, 2, 3, ...)
            # Note: label ID 0 is background, so the labels are props_df['label'][valid_coords_mask]
            seed_image[valid_y, valid_x] = props_df['label'][valid_coords_mask]
            
            # 4. Compute the Voronoi regions using the Euclidean Distance Transform
            # The second output (`indices_of_features`) is the Voronoi diagram:
            # it contains the label ID of the closest feature (centroid) for every pixel.
            distance, indices_of_features = distance_transform_edt(
                seed_image == 0, # The mask of non-feature pixels (where distance is calculated)
                return_indices=True # Returns the coordinates of the closest feature
            )
            
            # Use the feature indices to map every pixel to the label of the closest feature.
            # This is the Voronoi region image.
            # Note: distance_transform_edt returns coordinates. We need to look up the label
            # at those coordinates in the seed_image.
            # The result is equivalent to: seed_image[indices_of_features[0], indices_of_features[1]]
            
            voronoi_regions = seed_image[indices_of_features[0], indices_of_features[1]]
            
            # Store the 2D Voronoi region image in the 3D stack
            voronoi_stack[t] = voronoi_regions

            # 5. Collect centers for the napari points layer
            for i in range(len(props_df['label'])):
                all_centers.append((t, props_df['centroid-0'][i], props_df['centroid-1'][i]))
        
        else:
            # If no objects are found in the slice, the Voronoi region is just background (0)
            voronoi_stack[t] = np.zeros((Y, X), dtype=np.uint16)
    
    # Add the calculated Voronoi regions as a separate Labels layer
    viewer.add_labels(
        voronoi_stack,
        name=f'Voronoi Regions for {platelet_em_index_to_class[class_index]}',
        opacity=0.5,
        visible=False
        # Random colors will be assigned to the regions
    )

    # Add the centroids layer
    viewer.add_points(
        all_centers,
        name=f'Centroids of Label {class_index} ({platelet_em_index_to_class[class_index]})',
        size=10,
        face_color='red',
        opacity=0.5,
        visible=False
    )


napari.run()