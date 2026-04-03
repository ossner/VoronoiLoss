import marimo

__generated_with = "0.22.0"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _():
    import marimo as mo
    import numpy as np
    import shutil
    import pandas as pd
    import os
    import json
    import matplotlib.pyplot as plt
    from PIL import Image
    from skimage.measure import regionprops
    from scipy.ndimage import label, distance_transform_edt
    from tqdm import tqdm

    return (
        Image,
        distance_transform_edt,
        json,
        label,
        mo,
        np,
        os,
        pd,
        plt,
        regionprops,
        shutil,
    )


@app.cell(hide_code=True)
def _(distance_transform_edt, json, label, np, regionprops):
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

                if not is_3d:
                    min_dist = np.min(dist_map_to_others[coords[:, 0], coords[:, 1]])
                else:
                    min_dist = np.min(dist_map_to_others[coords[:, 0], coords[:, 1], coords[:, 2]])
            else:
                min_dist = np.inf

            volume = p.area
            surface_area = p.perimeter if not is_3d else p.surface_area

            if surface_area > 0:
                shape_index = (
                    (36 * np.pi * (volume**2)) / (surface_area**3)
                    if is_3d
                    else (4 * np.pi * volume) / (surface_area**2)
                )
            else:
                shape_index = 1.0

            # Serialize coordinates for CSV compatibility
            coords_serialized = json.dumps(p.coords.tolist())

            instance_data.append({
                'volume': volume,
                'shape_index': shape_index,
                'surface_area': surface_area,
                'solidity': p.solidity,
                'min_neighbor_dist': float(min_dist),
                'centroid_x': float(p.centroid[1]),
                'centroid_y': float(p.centroid[0]),
                'coords': coords_serialized
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
def _(dataset_dropdown, json, mo, np, pd):
    LABEL_DIR, TASK = dataset_dropdown.value

    #inst_df, _ = collect_instance_metrics(LABEL_DIR, TASK)
    #inst_df.insert(0, 'ID', range(0, len(inst_df)))
    #inst_df.to_csv(f'{LABEL_DIR}_{TASK}_instances.csv', index=False)

    inst_df = pd.read_csv(f'{LABEL_DIR}_{TASK}_instances.csv')
    inst_df['coords'] = inst_df['coords'].apply(lambda x: np.array(json.loads(x)))
    get_inst, set_inst = mo.state(inst_df)
    get_flagged, set_flagged = mo.state(pd.DataFrame(columns=inst_df.columns))
    return LABEL_DIR, TASK, get_flagged, get_inst, set_flagged, set_inst


@app.cell(hide_code=True)
def _(get_inst, mo):
    table = mo.ui.table(
        get_inst(),
        selection="single",
        pagination=True,
        label="Select an instance to inspect"
    )
    table
    return (table,)


@app.cell(hide_code=True)
def _(
    Image,
    LABEL_DIR,
    TASK,
    get_inst,
    mo,
    np,
    pd,
    plt,
    set_flagged,
    set_inst,
    table,
):
    mo.stop(len(table.value) == 0)
    selected = table.value.iloc[0]
    fname = selected['filename']
    split = selected['split']
    current_id = selected['ID']
    inst_pixels = selected['coords']

    def handle_flag(_):
        row_to_move = get_inst()[get_inst()['ID'] == current_id]
        set_flagged(lambda prev: pd.concat([prev, row_to_move], ignore_index=True))
        set_inst(lambda prev: prev[prev['ID'] != current_id].reset_index(drop=True))

    flag_button = mo.ui.button(
        label=f"Remove and Flag ID {current_id}",
        on_click=handle_flag,
        kind="danger"
    )

    # Paths
    lbl_path = f"{LABEL_DIR}/{split}/labels/{TASK}/{fname}"
    img_path = lbl_path.replace(f"/labels/{TASK}", "/images/")
    # Load images
    try:
        raw_img = np.array(Image.open(img_path))
        mask_img = np.array(Image.open(lbl_path)) / 255
        x, y = selected['centroid_x'], selected['centroid_y']
        p = 50
        y0, y1 = int(max(0, y-p)), int(min(raw_img.shape[0], y+p))
        x0, x1 = int(max(0, x-p)), int(min(raw_img.shape[1], x+p))
        crop_img = raw_img[y0:y1, x0:x1]
        for coord in inst_pixels:
            mask_img[coord[0], coord[1]] = 2
        crop_mask = mask_img[y0:y1, x0:x1]
        # Visualization
        fig, ax = plt.subplots(1, 2, figsize=(10, 4))
        ax[0].imshow(crop_img, cmap='gray')
        ax[0].set_title("Original Image")
        ax[1].imshow(crop_mask)
        ax[1].set_title(f"Instance Mask (ID: {selected['ID']})")
        for a in ax: a.axis('off')
    except Exception as e:
        print(f'ERROR {e}')
        mo.md(f"**Error loading image:** {e}")

    mo.vstack([
        mo.as_html(fig),
        flag_button
    ])
    return


@app.cell(hide_code=True)
def _(get_flagged, mo):
    flaggedtable = mo.ui.table(
        get_flagged(),
        pagination=True,
        selection=None
    )
    export_button = mo.ui.run_button(
        label=f"Export Cleaned Dataset",
        kind="danger",
        disabled=len(flaggedtable.data) == 0
    )
    mo.vstack([flaggedtable, export_button])
    return (export_button,)


@app.cell
def _(Image, LABEL_DIR, TASK, export_button, get_flagged, mo, np, os, shutil):
    mo.stop(not export_button.value)
    flagged = get_flagged()
    flagged = flagged.groupby('filename')['coords'].apply(list).to_dict()

    SRC_DIR = LABEL_DIR
    DST_DIR = SRC_DIR.replace('organelles', 'organelles_clean')

    for _split in ['train', 'val', 'test']:
        img_src_dir = f'{SRC_DIR}/{_split}/images'
        lbl_src_dir = f'{SRC_DIR}/{_split}/labels/{TASK}'
    
        img_dst_dir = f'{DST_DIR}/{_split}/images'
        lbl_dst_dir = f'{DST_DIR}/{_split}/labels/{TASK}'
    
        os.makedirs(img_dst_dir, exist_ok=True)
        os.makedirs(lbl_dst_dir, exist_ok=True)

        for file in os.listdir(img_src_dir):
            img_src_path = f'{img_src_dir}/{file}'
            lbl_src_path = f'{lbl_src_dir}/{file}'
        
            img_dst_path = f'{img_dst_dir}/{file}'
            lbl_dst_path = f'{lbl_dst_dir}/{file}'

            # --- Copy image directly ---
            shutil.copy2(img_src_path, img_dst_path)

            # --- Process label ---
            _label = np.array(Image.open(lbl_src_path))

            # If file is flagged → mask coords
            if file in flagged:
                for coord_list in flagged[file]:
                    for (_y, _x) in coord_list:   # note your coords are [y, x]
                        if 0 <= _y < _label.shape[0] and 0 <= _x < _label.shape[1]:
                            _label[_y, _x] = 0

            # Save modified label
            Image.fromarray(_label).save(lbl_dst_path)
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
