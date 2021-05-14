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
                config["image_storage"]+"{sample}_dapi_seg.npy",
                config["image_storage"]+"{sample}_Voro_seg.npy",
                config["image_storage"]+"{sample}_{channel}_meaurements.csv"],
                sample=['plate1_scan2_fov10','plate1_scan4_fov40'], channel=['gfp']
                )

##### load rules #####

include: "rules/segment.smk"
include: "rules/cast.smk"
include: "rules/extract.smk"
