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
from sklearn.cluster import KMeans
from scipy import ndimage as ndi
from skimage.util import montage
from skimage.transform import warp_polar, rotate, rescale
from scipy.spatial import Voronoi
from skimage.feature import peak_local_max

from sklearn.cluster import KMeans

matplotlib.use('agg')

def measureIntProps(maskMtx,channel,channelImage):
    listprops = ('label','centroid','filled_area','min_intensity','mean_intensity','max_intensity')
    props = measure.regionprops_table(maskMtx, intensity_image=channelImage, properties=listprops)
    props = pd.DataFrame(props)
    props['sum_intensity'] =  np.round(props['filled_area'] * props['mean_intensity'])
    props['mean_intensity'] = np.round(props['mean_intensity'])
    props = props.add_prefix(channel+'_')
    props = props.rename(columns={channel+"_label": "label",
                                  channel+"_centroid-0": "centroid-0",
                                  channel+"_centroid-1": "centroid-1"})
    return(props)

def getOverlap(index, dilation=9):
    joint = segmentation.join_segmentations(morphology.dilation((segmasks==fro['label'][index]).astype(int),morphology.disk(dilation)),
                                          (tVorMask==fro['VorLabel'][index]).astype(int))
    final = (joint==np.max(joint))*fro.loc[index,'label']
    return(final)

def getVoronoiStyle(seg_file,max_voro_area,voro_imfile,voro_imfile_2,voro_outfile,voro_transfile):
    temp = np.asarray(np.load(seg_file,allow_pickle=True)).item()
    masks = temp['masks']

    im = np.zeros_like(np.array(masks))

    fro = pd.DataFrame(measure.regionprops_table(masks, properties=['label','centroid']))


    points_mask = np.array(fro[['centroid-0','centroid-1']].to_numpy())

    vor = Voronoi(points_mask)

    my_dpi=im.shape[1]

    plt.rcParams['figure.dpi'] = my_dpi
    plt.rcParams['figure.figsize'] = ( im.shape[0]/my_dpi,im.shape[1]/my_dpi)
    fig = plt.figure();

    for simplex in vor.ridge_vertices:
        simplex = np.asarray(simplex)
        if np.all(simplex >= 0):
            plt.plot(vor.vertices[simplex, 0], vor.vertices[simplex, 1], 'k-',c='black',linewidth=.2)

    center = points_mask.mean(axis=0)
    for pointidx, simplex in zip(vor.ridge_points, vor.ridge_vertices):
        simplex = np.asarray(simplex)
        if np.any(simplex < 0):
            i = simplex[simplex >= 0][0] # finite end Voronoi vertex
            t = points_mask[pointidx[0]] - points_mask[pointidx[1]]  # tangent
            t = t / np.linalg.norm(t)
            n = np.array([-t[1], t[0]]) # normal
            midpoint = points_mask[pointidx].mean(axis=0)
            far_point = vor.vertices[i] + np.sign(np.dot(midpoint - center, n)) * n * 100
            plt.plot([vor.vertices[i,0], far_point[0]],
                     [vor.vertices[i,1], far_point[1]], 'k-',c='black',linewidth=.2)

    plt.xlim([0, im.shape[0]]); plt.ylim([0,im.shape[1]])
    plt.axis('off')
    fig.tight_layout(pad=0)
    plt.savefig(voro_imfile, dpi=my_dpi, #bbox_inches='tight',#dpi=my_dpi,
                transparent=False, pad_inches=0,facecolor='white')
    plt.close()
    im2 = io.imread(voro_imfile)
    voro = (im2[:,:,0])
    voro = voro[1:-1, 1:-1]
    voro = np.pad(voro, pad_width=1, mode='constant')
    distance = ndi.distance_transform_edt(voro)
    coords = peak_local_max(distance, footprint=np.ones((1, 1)), labels=voro)
    mask = np.zeros(distance.shape, dtype=bool)
    mask[tuple(coords.T)] = True
    markers, _ = ndi.label(mask)
    labels = segmentation.watershed(-distance, markers, mask=voro)
    labels = morphology.remove_small_objects(labels, min_size=40, connectivity=1, in_place=False)
    labels = morphology.dilation(labels, morphology.square(3))
    segmasks = masks
    segmasks = morphology.dilation(segmasks,morphology.square(3))

    sizeOfSegs = pd.DataFrame(measure.regionprops_table(labels, properties=['label','area']))
    bigMasks = np.array(sizeOfSegs[sizeOfSegs['area']>=max_voro_area]['label'])
    newVorMask = np.copy(labels)[::-1,:]
    for bMI in range(len(bigMasks)):
        print("progress:"+str(bMI)+'/'+str(len(bigMasks)))
        chckMtx = (labels == bigMasks[bMI])[::-1,:]

        for i in range(len(points_mask)):
            confirm = points_mask[i]
            print(points_mask[i])
            print("---")

        tmp_cellpose_mask = (morphology.dilation((segmasks == int(fro[(fro['centroid-0']==confirm[0])&(fro['centroid-1']==confirm[1])]['label'])).T,morphology.disk(11))).astype(int)
        tmp_voronoi_mask = 2*chckMtx.astype(int)
        tmp_join = segmentation.join_segmentations(tmp_cellpose_mask,tmp_voronoi_mask)
        tmp_join = (tmp_join == np.max(tmp_join))

        newVorMask[newVorMask == bigMasks[bMI]] = 0
        newVorMask[tmp_join] = bigMasks[bMI]

    np.save(voro_outfile, newVorMask.T, allow_pickle=True, fix_imports=True)
    io.imsave(voro_imfile_2, segmentation.find_boundaries(newVorMask).T)

    oldAssign = pd.DataFrame(measure.regionprops_table(masks, properties=['label','centroid']))
    newAssign = pd.DataFrame(measure.regionprops_table(newVorMask, properties=['label','centroid']))

    Clps2Voro = pd.DataFrame()

    for nlab in range(newAssign.shape[0]):
        tmpMtx = (newVorMask == newAssign['label'][nlab])
        for olab in range(oldAssign.shape[0]):
            if (tmpMtx[int(np.round(oldAssign['centroid-1'][olab])),int(np.round(oldAssign['centroid-0'][olab]))]):
                Clps2Voro = Clps2Voro.append(pd.DataFrame([newAssign['label'][nlab], oldAssign['label'][olab]]).T)

    Clps2Voro = Clps2Voro.rename(columns={0: "voro_label", 1: "clps_label"})
    Clps2Voro = Clps2Voro.reset_index(drop=True)
    Clps2Voro.to_csv(voro_transfile)
