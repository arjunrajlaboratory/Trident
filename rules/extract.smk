from bin.extFunctionsWS import *
import pandas as pd
from skimage import io

rule extract:
  input:
    mask='{path}/{sample}_WS_seg.npy',
    chImage='{path}/{sample}_{channel}.TIF'
  output:
    measures='{path}/{sample}_{channel}_meaurements.csv'
  run:
    mask = np.array(np.load(input.mask,allow_pickle=True))
    ch = str(wildcards.channel)
    cfImage = io.imread(input.chImage)
    intDF = measureIntProps(maskMtx = mask,channel = ch,channelImage = cfImage)

    intDF.to_csv(output.measures)
