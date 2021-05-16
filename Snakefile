### Snakefile
import numpy as np
import pandas as pd
from snakemake.utils import validate, min_version
import glob

##### set minimum snakemake version #####
#min_version("5.1.2")

##### Details #####
# Input :
# - dapi image (tiff)
# - channel 1 image (tiff)
# ....
# Output :
# - seg.npy array files with segmentations
# - CSV files with intensity features within each bounded region

##### load configuration files #####
configfile:"config.yaml"  # <--- Make sure this is correct.

# get images in the storage system
#imageList = glob.glob(config["image_storage"]+'*_dapi.TIF')
#imageNames = ["_".join(sub.split('/')[-1].split('_')[:-1]) for sub in imageList]

wellList = [x[0].split('/')[-1] for x in os.walk(config["image_storage"])][1:]

##### target rules #####
rule all:
    input:
        expand([config["image_storage"]+"{well}/dapi001_seg.npy",
                config["image_storage"]+"{well}/{well}_WS_seg.npy",
                config["image_storage"]+"{well}/{well}_{channel}_meaurements.csv"],
                well=wellList, channel=config["channelsOfIntestest"])

##### load rules #####

include: "rules/segment.smk"
include: "rules/cast_watershed.smk"
include: "rules/extract.smk"
