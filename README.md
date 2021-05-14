# IntensityMeasurement

This pipeline is built with Snakemake.

The goal of the pipeline to to use CellPose masks (generated from the DAPI channel)
to estimate the target intensity (from other channels, e.g. GFP) across cells
in a 2D monolayer.

To run the pipeline, place images in the 'images/' folder with the following naming
convention:

"*_dapi.TIF"
"*_gfp.TIF" where the * is matching in both cases, (could be other channels)

you can add as many channels and as many images as you like.

Then, adjust the Snakemake and config.yaml files to best fit your images.
