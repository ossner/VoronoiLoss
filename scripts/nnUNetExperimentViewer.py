import nibabel as nib
import numpy as np
import napari



def get_comparison_mask(pred, gt):
    # Ensure boolean
    pred = pred > 0
    gt = gt > 0

    tp = np.logical_and(pred, gt)
    fp = np.logical_and(pred, np.logical_not(gt))
    fn = np.logical_and(np.logical_not(pred), gt)

    # Create a categorical map: 1=TP, 2=FP, 3=FN
    vis_mask = np.zeros(pred.shape, dtype=np.uint8)
    vis_mask[tp] = 1
    vis_mask[fp] = 2
    vis_mask[fn] = 3
    return vis_mask


# Load your data
img = nib.load(
    "/Users/ossner/git/VoronoiLoss/data/nnUNet_raw/Dataset501_BrainMets/imagesTr/Mets_058_0000.nii.gz").get_fdata()
gt = nib.load(
    "/Users/ossner/git/VoronoiLoss/data/nnUNet_raw/Dataset501_BrainMets/labelsTr/Mets_058.nii.gz").get_fdata()
pred_a = nib.load("/Users/ossner/git/VoronoiLoss/data/nnUNet_predictions/Dataset501_BrainMets/nnUNetTrainerDiceCEBaseline__nnUNetPlans__3d_fullres/experiment_00/fold_0/Mets_058.nii.gz").get_fdata()
pred_b = nib.load("/Users/ossner/git/VoronoiLoss/data/nnUNet_predictions/Dataset501_BrainMets/nnUNetTrainerGlobalCCDiceCE__nnUNetPlans__3d_fullres/experiment_00/fold_0/Mets_058.nii.gz").get_fdata()

# Process masks
comp_a = get_comparison_mask(pred_a, gt)
comp_b = get_comparison_mask(pred_b, gt)

# Launch Napari
viewer = napari.Viewer()
viewer.add_image(img, name='Raw Image', colormap='gray')
viewer.add_labels(gt.astype(int), name='Ground Truth', opacity=0.3)

# Add Model A overlays
color_map = {1: 'green', 2: 'red', 3: 'blue'}  # TP=Green, FP=Red, FN=Blue
viewer.add_labels(comp_a, name='DiceCE: TP/FP/FN',
                  colormap=color_map, opacity=0.6)

# Add Model B overlays
viewer.add_labels(comp_b, name='CCDiceCE: TP/FP/FN',
                  colormap=color_map, opacity=0.6, visible=False)

napari.run()
