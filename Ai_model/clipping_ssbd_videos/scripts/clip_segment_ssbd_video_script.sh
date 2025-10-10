#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p /home/samir/projects/clipping_ssbd_videos/ssbd_clip_segment/

python3 clip_ssbd_video_segments.py --ann_folder=/home/samir/projects/clipping_ssbd_videos/ssbd-release/Annotations/ \
--origin_folder=/home/samir/projects/clipping_ssbd_videos/ssbd_raw/ \
--out_folder=/home/samir/projects/clipping_ssbd_videos/ssbd_clip_segment/ \
--height=240 --width=320 --max_num=150