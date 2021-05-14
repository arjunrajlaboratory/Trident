## segment nuclei
import cellpose
from cellpose import utils,models,io

rule segment:
  input:
    nuclear='{path}/{sample}_dapi.TIF'
  output:
    array='{path}/{sample}_dapi_seg.npy'
  params:
    flowThreshold=config['segment']['flowThreshold'],
    cellProbabilityThreshold=config['segment']['cellProbabilityThreshold'],
    nucDiam=config['segment']['nuclearDiameter']
  run:
#    outpath = str(wildcards.path) + '/'
    model = models.Cellpose(gpu=False, model_type='nuclei')
    img = io.imread(input.nuclear)
    masks, flows, styles, diams = model.eval(img, diameter=params.nucDiam, cellprob_threshold=params.cellProbabilityThreshold, flow_threshold=params.flowThreshold, channels=[0,0])
    io.masks_flows_to_seg(img, masks, flows, diams,input.nuclear)
    io.save_to_png(img, masks, flows, input.nuclear)