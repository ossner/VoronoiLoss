import marimo

__generated_with = "0.22.0"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _():
    import marimo as mo
    import numpy as np
    import pandas as pd
    import os
    import matplotlib.pyplot as plt
    from PIL import Image
    from skimage.measure import regionprops
    from scipy.ndimage import label, distance_transform_edt
    from tqdm import tqdm

    return (
        Image,
        distance_transform_edt,
        label,
        mo,
        np,
        os,
        pd,
        plt,
        regionprops,
    )


@app.cell(hide_code=True)
def _(distance_transform_edt, label, np, regionprops):
    def collect_instance_metrics_from_mask(mask):
        is_3d = mask.ndim == 3
        conn = np.ones((3,) * mask.ndim, dtype=int)
        labeled_mask, n_instances = label(mask > 0, structure=conn)

        if n_instances == 0:
            return []

        instance_data = []
        props = regionprops(labeled_mask)
        all_instances_mask = (labeled_mask > 0)

        for p in props:
            curr_label = p.label
            if n_instances > 1:
                others_mask = all_instances_mask & (labeled_mask != curr_label)
                dist_map_to_others = distance_transform_edt(~others_mask)
                coords = p.coords
                # Logic for distance
                min_dist = np.min(dist_map_to_others[coords[:, 0], coords[:, 1]]) if not is_3d else \
                           np.min(dist_map_to_others[coords[:, 0], coords[:, 1], coords[:, 2]])
            else:
                min_dist = np.inf

            volume = p.area
            surface_area = p.perimeter if not is_3d else p.surface_area

            # Sphericity / Compactness Formula
            if surface_area > 0:
                # $S = \frac{36\pi V^2}{A^3}$ for 3D or $\frac{4\pi A}{P^2}$ for 2D
                shape_index = (36 * np.pi * (volume**2)) / (surface_area**3) if is_3d else (4 * np.pi * volume) / (surface_area**2)
            else:
                shape_index = 1.0

            instance_data.append({
                'volume': volume,
                'shape_index': shape_index,
                'surface_area': surface_area,
                'solidity': p.solidity,
                'min_neighbor_dist': min_dist,
                'centroid_x': p.centroid[1],
                'centroid_y': p.centroid[0],
            })
        return instance_data

    return (collect_instance_metrics_from_mask,)


@app.cell(hide_code=True)
def _(Image, collect_instance_metrics_from_mask, np, os, pd):
    def collect_instance_metrics(base_path, task_name, splits=['train', 'val', 'test']):
        instance_rows = []
        image_rows = []

        for split in splits:
            label_dir = os.path.join(base_path, split, 'labels', task_name)
            if not os.path.exists(label_dir):
                continue

            label_files = [f for f in os.listdir(label_dir) if f.endswith('.png')]
            for filename in label_files:
                mask_path = os.path.join(label_dir, filename)
                mask = np.array(Image.open(mask_path))
                all_instance_data = collect_instance_metrics_from_mask(mask)

                image_rows.append({
                    'split': split, 
                    'class': task_name, 
                    'filename': filename, 
                    'im_size': mask.shape
                })
                for instance_data in all_instance_data:
                    instance_rows.append({'filename': filename, 'split': split} | instance_data)

        return pd.DataFrame(instance_rows), pd.DataFrame(image_rows)

    return


@app.cell(hide_code=True)
def _(mo):
    dataset_dropdown = mo.ui.dropdown(
        options={
            "epfl/mit": ("data/organelles/epfl", "mit"),
            "platelet/cv": ("data/organelles/platelet", "cv"),
            "platelet/ag": ("data/organelles/platelet", "ag"),
        },
        value=("epfl/mit"),
        label="Select dataset",
    )

    mo.vstack([
        mo.md("# 🔬 Instance Outlier Inspector"),
        dataset_dropdown,
    ])
    return (dataset_dropdown,)


@app.cell
def _(dataset_dropdown, pd):
    LABEL_DIR, TASK = dataset_dropdown.value

    #inst_df, _ = collect_instance_metrics(LABEL_DIR, TASK)
    #inst_df.insert(0, 'ID', range(0, len(inst_df)))
    #inst_df.to_csv(f'{LABEL_DIR}_{TASK}_instances.csv', index=False)
    inst_df = pd.read_csv(f'{LABEL_DIR}_{TASK}_instances.csv')
    return LABEL_DIR, TASK, inst_df


@app.cell(hide_code=True)
def _(inst_df, mo):
    table = mo.ui.table(
        inst_df,
        selection="single",
        pagination=True,
        label="Select an instance to inspect"
    )
    table
    return (table,)


@app.cell(hide_code=True)
def _(Image, LABEL_DIR, TASK, mo, np, plt, table):
    mo.stop(len(table.value) == 0)

    selected = table.value.iloc[0]
    fname = selected['filename']
    split = selected['split']

    # Paths
    lbl_path = f"{LABEL_DIR}/{split}/labels/{TASK}/{fname}"
    img_path = lbl_path.replace(f"/labels/{TASK}", "/images/")
    # Load images
    try:
        raw_img = np.array(Image.open(img_path))
        mask_img = np.array(Image.open(lbl_path))
        x, y = selected['centroid_x'], selected['centroid_y']
        p = 50
        y0, y1 = int(max(0, y-p)), int(min(raw_img.shape[0], y+p))
        x0, x1 = int(max(0, x-p)), int(min(raw_img.shape[1], x+p))
        crop_img = raw_img[y0:y1, x0:x1]
        crop_mask = mask_img[y0:y1, x0:x1]
        # Visualization
        fig, ax = plt.subplots(1, 2, figsize=(10, 4))
        ax[0].imshow(crop_img, cmap='gray')
        ax[0].set_title("Original Image")
        ax[1].imshow(crop_mask, alpha=0.7)
        ax[1].set_title(f"Instance Mask (ID: {selected['ID']})")
        for a in ax: a.axis('off')
        mo.md(
            f"""
            {mo.as_html(fig)}
            """
        )
    except Exception as e:
        print(f'ERROR {e}')
        mo.md(f"**Error loading image:** {e}")

    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
