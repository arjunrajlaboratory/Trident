### Snakefile
import numpy as np
import pandas as pd
from snakemake.utils import validate, min_version
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

#def get_frame_files(frameFile, parameter):
#    cvec = pd.read_csv(frameFile)
#    return(list(cvec[parameter]))


##### load configuration files #####
configfile:"config.yaml"  # <--- Make sure this is correct.

##### target rules #####
rule all:
    input:
        expand([config["image_storage"]+"{sample}_dapi.TIF",
                config["image_storage"]+"{sample}_dapi_seg.npy"],
                sample=['plate1_scan2_fov10','plate1_scan4_fov40']
                )
#,27,28,29,30,31,32,42,43,45,53,56,63,64
#sample=['FT_220_D2_2_wB3_XY09','FT_220_D2_2_wC3_XY23','FT_220_D2_2_wC3_XY30','FT_220_D2_2_wC3_XY38','FT_220_D2_2_wC3_XY49','FT_220_D2_2_wC3_XY53'])

#get_frames(config["connects"])["id"])

##### load rules #####

include: "rules/segment.smk"
#include: "rules/extract.smk"
