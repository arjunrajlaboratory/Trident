from bin.extFunctionsWS import *
import pandas as pd

rule cast:
  input:
    mask='{path}/{sample}_dapi_seg.npy',
  output:
    WSMask='{path}/{sample}_WS_seg.npy',
    WStransfer='{path}/{sample}_WSlabels.csv',
    WSimage='{path}/{sample}_WSbounds.tif'
  params:
    dilation = config['cast']['dilation']
  run:
    getnewMask(seg_file=input.mask,dilation=params.dilation,
               WS_outfile=output.WSMask,WS_transfile=output.WStransfer,WS_maskImage=output.WSimage)
