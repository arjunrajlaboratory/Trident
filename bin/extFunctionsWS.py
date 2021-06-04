### testing image registration functions
import numpy as np
from urllib.parse import urlparse
from cellpose import utils, io,models
import matplotlib
import matplotlib.pyplot as plt
import time, os, sys
import pandas as pd
import glob
### Part 1 : Image Registration
from skimage import img_as_uint,io,registration,transform,filters,restoration,util,feature,morphology,exposure,measure,segmentation
from scipy import ndimage as ndi

matplotlib.use('agg')

def quantiles(regionmask, intensity):
    return np.percentile(intensity[regionmask], q=(10, 25, 50, 75, 90))

def measureIntProps(maskMtx,channel,channelImage):
    listprops = ('label','centroid','filled_area','min_intensity','mean_intensity','max_intensity')
    props = measure.regionprops_table(maskMtx, intensity_image=channelImage, properties=listprops,extra_properties = (quantiles,))
    props = pd.DataFrame(props)
    props['sum_intensity'] =  np.round(props['filled_area'] * props['mean_intensity'])
    props['mean_intensity'] = np.round(props['mean_intensity'])
    props = props.add_prefix(channel+'_')
    props = props.rename(columns={channel+"_label": "label",
                                  channel+"_centroid-0": "centroid-0",
                                  channel+"_centroid-1": "centroid-1"})
    return(props)

def getnewMask(seg_file,dilation,WS_outfile,WS_transfile,WS_maskImage):
    temp = np.asarray(np.load(seg_file,allow_pickle=True)).item()
    masks_1 = temp['masks']
    im = np.zeros_like(np.array(masks_1))

    points_frame = pd.DataFrame(measure.regionprops_table(masks_1, properties=['label','centroid']))
    pointList = np.array(points_frame.iloc[:,-2:].astype(int))

    for x in range(pointList.shape[0]):
        im[pointList[x,0],pointList[x,1]] = 1


    masks = temp['masks']>0
    masks=morphology.dilation(masks,morphology.disk(dilation))

    secmask = np.zeros(masks.shape, dtype=bool)
    secmask[tuple(pointList.T)] = True
    secmask = morphology.dilation(secmask,morphology.square(3))
    markers, _ = ndi.label(secmask)
    labels = segmentation.watershed( -im, markers, mask=(masks>0))
    np.save(WS_outfile, labels, allow_pickle=True, fix_imports=True)

    points_frame['newLabel'] = [labels[pointList[x,0],pointList[x,1]] for x in range(pointList.shape[0])]
    points_frame.to_csv(WS_transfile)
    io.imsave(WS_maskImage, segmentation.find_boundaries(labels))
