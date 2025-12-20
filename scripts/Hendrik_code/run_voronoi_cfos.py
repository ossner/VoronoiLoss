import sys
from pathlib import Path
import os

file = Path(__file__).resolve()
sys.path.append(str(file.parents[1]))
sys.path.append(str(file.parents[2]))

from utils.filepaths import search_path, filepath_cfos
from voronoi_calc import make_voronoi_arr
from TPTBox import NII
from tqdm import tqdm
import numpy as np

paths = search_path(filepath_cfos(), query="cfos_test/**/*_seg.nii.gz")

for p in tqdm(paths):
    seg = NII.load(p, seg=True)
    voronoi_arr = make_voronoi_arr(seg.get_seg_array())
    voronoi_arr = np.abs(voronoi_arr)

    seg.set_array(voronoi_arr).save(p.parent.joinpath(p.name.replace("_seg.", "_voronoi.")))
    # break
