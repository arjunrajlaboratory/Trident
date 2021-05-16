## segment nuclei
import cellpose
from cellpose import utils,models,io

rule segment:
  input:
    nuclear='{path}/{well}/dapi001.tif'
  output:
    array='{path}/{well}/dapi001_seg.npy'
  params:
    flowThreshold=config['segment']['flowThreshold'],
    cellProbabilityThreshold=config['segment']['cellProbabilityThreshold'],
    nucDiam=config['segment']['nuclearDiameter'],
    gpu=config['segment']['GPU']
  run:
#    outpath = str(wildcards.path) + '/'
    model = models.Cellpose(gpu=params.gpu, model_type='nuclei')
    img = io.imread(input.nuclear)
    masks, flows, styles, diams = model.eval(img, diameter=params.nucDiam, cellprob_threshold=params.cellProbabilityThreshold, flow_threshold=params.flowThreshold, channels=[0,0])
    cellpose.io.masks_flows_to_seg(img, masks, flows, diams,input.nuclear)
    cellpose.io.save_to_png(img, masks, flows, input.nuclear)
