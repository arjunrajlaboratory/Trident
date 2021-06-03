from bin.extFunctionsWS import *
import pandas as pd
from skimage import io

rule extract:
  input:
    mask='{path}/{well}/{well}_WS_seg.npy',
    chImage='{path}/{well}/{channel}001.tif'
  output:
    measures='{path}/{well}/{well}_{channel}_measurements.csv'
  run:
    mask = np.array(np.load(input.mask,allow_pickle=True))
    ch = str(wildcards.channel)
    cfImage = io.imread(input.chImage)
    intDF = measureIntProps(maskMtx = mask,channel = ch,channelImage = cfImage)

    intDF.to_csv(output.measures)
