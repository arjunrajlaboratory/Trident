from bin.extFunctionsWS import *
import pandas as pd

rule cast:
  input:
    mask='{path}/{well}/dapi001_seg.npy',
  output:
    WSMask='{path}/{well}/{well}_WS_seg.npy',
    WStransfer='{path}/{well}/{well}_WSlabels.csv',
    WSimage='{path}/{well}/{well}_WSbounds.tif'
  params:
    dilation = config['cast']['dilation']
  run:
    getnewMask(seg_file=input.mask,dilation=params.dilation,
               WS_outfile=output.WSMask,WS_transfile=output.WStransfer,WS_maskImage=output.WSimage)
