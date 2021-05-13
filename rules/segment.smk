## segment nuclei

rule segment:
  input:
    nuclear='{path}/{sample}_dapi.tif'
  output:
    array='{path}/{sample}_dapi_seg.npy'
  params:
    flowThreshold=config['segment']['flowThreshold'],
    cellProbabilityThreshold=config['segment']['cellProbabilityThreshold'],
    nucDiam=config['segment']['nuclearDiameter']
  run:
    outpath = str(wildcards.path) + '/'
    segmentCellpose(inputImage=input.nuclear, cellpose_out=outpath, nucDiameter=params.nucDiam, cellprob_threshold=params.cellProbabilityThreshold, flow_threshold=params.flowThreshold)