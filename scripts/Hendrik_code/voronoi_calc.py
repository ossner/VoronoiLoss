import sys
from pathlib import Path
import os

file = Path(__file__).resolve()
sys.path.append(str(file.parents[1]))
sys.path.append(str(file.parents[2]))
from matplotlib import pyplot as plt
from utils.filepaths import filepath_code_root

import numpy as np
from scipy.ndimage import distance_transform_edt, label, binary_dilation
import ray
import time
from matplotlib.colors import to_rgb
import matplotlib.pyplot as plt
from matplotlib.widgets import Button
from TPTBox.core.np_utils import np_unique_withoutzero

# from mayavi import mlab
# from vispy import app, scene
import os
import json

# Algorithm


@ray.remote
def compute_batch_shape_distance(shape_data, matrix_shape):
    distances = np.full(matrix_shape, np.inf)
    closest_shapes = np.zeros(matrix_shape)

    for shape_mask, shape_value in shape_data:
        specific_distance = distance_transform_edt(~shape_mask)
        distances = np.where(specific_distance < distances, specific_distance, distances)
        closest_shapes = np.where(specific_distance == distances, shape_value, closest_shapes)

    return distances, closest_shapes


def make_voronoi_arr(labeled_matrix):
    if not ray.is_initialized():
        # ray.init(ignore_reinit_error=True, _system_config={"object_spilling_config": json.dumps({"directory_path": "/your/spill/path"})})
        #    ray.init(ignore_reinit_error=True)
        ray.init(
            object_store_memory=int(1e10),
            _system_config={
                "max_io_workers": 10,  # More IO workers for parallelism.
                "object_spilling_config": json.dumps(
                    {
                        "type": "filesystem",
                        "params": {
                            # Multiple directories can be specified to distribute
                            # IO across multiple mounted physical devices.
                            "directory_path": [
                                "/tmp/spill",
                            ]
                        },
                    }
                ),
            },
        )

    # binary_matrix = matrix != 0
    # labeled_matrix = labeled_matrix.copy()  # label(binary_matrix)
    feature_labels = np_unique_withoutzero(labeled_matrix)
    num_features = len(feature_labels)

    labeled_matrix = labeled_matrix.astype(int)

    min_distance_matrix = np.full(labeled_matrix.shape, np.inf)
    closest_shape_matrix = np.zeros(labeled_matrix.shape, dtype=labeled_matrix.dtype)
    background_mask = labeled_matrix == 0

    shape_data = []
    futures = []

    def process_futures_chunk():
        remaining_futures = futures[:]
        while remaining_futures:
            done_futures, remaining_futures = ray.wait(remaining_futures)
            for future in done_futures:
                dists, shapes = ray.get(future)

                # Pixels where the new distance is less than the current minimum.
                update_mask = dists < min_distance_matrix
                # Pixels where the new distance equals the current minimum.
                conflict_mask = np.logical_and(dists == min_distance_matrix, ~update_mask)

                # Update the closest shape matrix for pixels where the new shape is closer.
                min_distance_matrix[update_mask] = dists[update_mask]

                # For the background, store the negative value of the closest shape.
                closest_shape_matrix[update_mask & background_mask] = -shapes[update_mask & background_mask]
                # For the actual shape, store the positive value.
                closest_shape_matrix[update_mask & ~background_mask] = shapes[update_mask & ~background_mask]

                # Set pixels to 0 where there's a tie between two or more shapes.
                closest_shape_matrix[conflict_mask] = 0

    num_chunks = os.cpu_count() * 50
    dynamic_chunk_size = num_features // num_chunks

    for feature in feature_labels:
        shape_mask = labeled_matrix == feature
        shape_value = labeled_matrix[shape_mask][0]
        shape_data.append((shape_mask, shape_value))

        if len(shape_data) >= dynamic_chunk_size or feature == num_features:
            futures.append(compute_batch_shape_distance.remote(shape_data, labeled_matrix.shape))
            shape_data.clear()

    # Move the call to process_futures_chunk() out of the loop.
    process_futures_chunk()

    ray.shutdown()
    return closest_shape_matrix


# Debug


def generate_random_matrix(x, y, z, num_shapes):
    matrix = np.zeros((z, y, x), dtype=int)

    # Generate each shape one by one
    for shape_num in range(1, num_shapes + 1):
        placed = False
        while not placed:
            # Randomly choose a starting point
            start_x = np.random.randint(0, x)
            start_y = np.random.randint(0, y)
            start_z = np.random.randint(0, z)

            if matrix[start_z, start_y, start_x] == 0:
                matrix[start_z, start_y, start_x] = shape_num
                placed = True

                # Try to expand the shape in random directions to make it more interesting
                for _ in range(10):
                    directions = [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]
                    np.random.shuffle(directions)

                    for dx, dy, dz in directions:
                        new_x, new_y, new_z = start_x + dx, start_y + dy, start_z + dz

                        if 0 <= new_x < x and 0 <= new_y < y and 0 <= new_z < z and matrix[new_z, new_y, new_x] == 0:
                            matrix[new_z, new_y, new_x] = shape_num
                            start_x, start_y, start_z = new_x, new_y, new_z
                            break

    return matrix


# Visualization


def plot_3d_layer(layer_data, ax, color_map, show_zeros=True, z_index=0):
    for y in range(layer_data.shape[0]):
        for x in range(layer_data.shape[1]):
            val = layer_data[y, x]

            if val > 0:
                ax.scatter(x, y, zs=z_index, zdir="z", c=[color_map[val]], s=100, depthshade=False)
            elif val < 0 and show_zeros:
                ax.scatter(x, y, zs=z_index, zdir="z", c=[lighten_color(color_map[-val])], s=100, depthshade=False)
            elif show_zeros:
                ax.scatter(x, y, zs=z_index, zdir="z", c="white", s=100, depthshade=False)


def plot_cubes(matrix, result, shape_colors, layer_index=[0]):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6), subplot_kw={"projection": "3d"})
    fig.subplots_adjust(bottom=0.2)  # Make space for buttons

    # Set axis properties
    def set_axis_properties(ax):
        ax.set_xlim(0, matrix.shape[2] - 1)
        ax.set_ylim(0, matrix.shape[1] - 1)
        ax.set_zlim(0, matrix.shape[0] - 1)
        ax.set_xticks(np.arange(matrix.shape[2]))
        ax.set_yticks(np.arange(matrix.shape[1]))
        ax.set_zticks(np.arange(matrix.shape[0]))

    # Button callback functions
    def show_previous(event):
        layer_index[0] = max(0, layer_index[0] - 1)
        update()

    def show_next(event):
        layer_index[0] = min(result.shape[0] - 1, layer_index[0] + 1)
        update()

    def update():
        ax1.cla()
        ax2.cla()

        # Left cube: Original data
        for z in range(matrix.shape[0]):
            layer_data = matrix[z]
            plot_3d_layer(layer_data, ax1, shape_colors, show_zeros=False, z_index=z)
        ax1.set_title("Original Matrix")
        set_axis_properties(ax1)

        # Right cube: Result data for the current layer
        layer_data = result[layer_index[0]]
        ax2.set_title(f"Result Matrix Layer {layer_index[0] + 1}")
        plot_3d_layer(layer_data, ax2, shape_colors, z_index=layer_index[0])
        set_axis_properties(ax2)
        plt.draw()

    ax_prev = plt.axes([0.25, 0.05, 0.1, 0.075])
    ax_next = plt.axes([0.65, 0.05, 0.1, 0.075])
    btn_prev = Button(ax_prev, "Previous")
    btn_next = Button(ax_next, "Next")
    btn_prev.on_clicked(show_previous)
    btn_next.on_clicked(show_next)

    update()  # Initial plot
    plt.show()


def lighten_color(color, amount=0.5):
    """
    Lightens the given color by multiplying (1-luminosity) by the given amount.
    Input can be matplotlib color string, hex string, or RGB tuple.

    Examples:
    >> lighten_color('g', 0.3)
    >> lighten_color('#F034A3', 0.6)
    >> lighten_color((.3, .55, .1), 0.5)
    """
    import matplotlib.colors as mc
    import colorsys

    try:
        c = mc.cnames[color]
    except:
        c = color

    c = colorsys.rgb_to_hls(*mc.to_rgb(c))
    return colorsys.hls_to_rgb(c[0], 1 - amount * (1 - c[1]), c[2])


def color_distance(c1, c2):
    """Compute the distance between two colors in RGB space."""
    return np.sqrt((c1[0] - c2[0]) ** 2 + (c1[1] - c2[1]) ** 2 + (c1[2] - c2[2]) ** 2)


def is_color_too_close(new_color, used_colors, threshold=0.3):
    """Check if the new color is too close to any of the used colors."""
    for used_color in used_colors:
        if color_distance(new_color, used_color) < threshold:
            return True
    return False


def generate_unique_color(used_colors):
    # Keep trying random colors until we find a unique one
    while True:
        new_color = tuple(np.random.rand(3))
        # Ensure that the color is not too close to black
        luminance = 0.2126 * new_color[0] + 0.7152 * new_color[1] + 0.0722 * new_color[2]
        if luminance > 0.3 and not is_color_too_close(new_color, used_colors):
            used_colors.add(new_color)
            return new_color


# Main


def main():
    ###
    # DEBUG_START
    # The following code should be replaced with loading the nifty file.
    # Get user inputs
    x = 50  # int(input("What is x of the random matrix? "))
    y = 50  # int(input("What is y of the random matrix? "))
    z = 1  # int(input("What is z of the random matrix? "))
    num_shapes = 5  # int(input("How many shapes should I create? "))

    # Create the random matrix
    matrix = generate_random_matrix(x, y, z, num_shapes)
    ### DEBUG_END

    # Assign a unique color for each shape
    shape_colors = {}
    used_colors = set()
    for i in range(1, num_shapes + 1):
        shape_colors[i] = generate_unique_color(used_colors)

    # Calculate the results matrix
    start_time = time.time()  # Start the timer

    result = make_voronoi_arr(matrix)

    end_time = time.time()  # Stop the timer

    elapsed_time = end_time - start_time
    print(f"Time taken for closest_shape: {elapsed_time:.2f} seconds")

    result = result.astype(int)
    # result = np.abs(result)

    fig = plt.figure()
    plt.imshow(result[0])
    plt.colorbar()
    fig.savefig(
        str(filepath_code_root().joinpath("test.png")),
        dpi=320,
    )

    # Plot cubes with user-defined parameters
    # plot_cubes(matrix, result, shape_colors)  # Pass the required variables to the function
    # plot_cubes_vispy(matrix, result, shape_colors)


if __name__ == "__main__":
    main()
