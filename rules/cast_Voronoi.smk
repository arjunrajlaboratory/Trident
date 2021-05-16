from bin.extFunctions import *
import pandas as pd

rule cast:
  input:
    mask='{path}/{sample}_dapi_seg.npy',
  output:
    VoroMask='{path}/{sample}_Voro_seg.npy',
    VoroImage='{path}/{sample}_Voro.png',
    VoroTIF='{path}/{sample}_Voro_final.tif',
    VoroTrans='{path}/{sample}_Clps2Voro.csv'
  params:
    MaxVoroArea = config['cast']['VoronoiArea']
  run:
    getVoronoiStyle(seg_file=input.mask,max_voro_area=params.MaxVoroArea,
                    voro_imfile=output.VoroImage,voro_imfile_2=output.VoroTIF,
                    voro_outfile=output.VoroMask,voro_transfile=output.VoroTrans)
