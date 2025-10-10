#!/bin/bash

# Set up the correct paths for your system
ANNO_FOLDER=/home/samir/projects/clipping_ssbd_videos/ssbd-release/Annotations/
OUT_FOLDER=/home/samir/projects/clipping_ssbd_videos/ssbd_raw/

# Create output directories if they don't exist
mkdir -p $OUT_FOLDER

# Run the Python download script
python3 download_ssbd.py --ann_folder=$ANNO_FOLDER --out_folder=$OUT_FOLDER