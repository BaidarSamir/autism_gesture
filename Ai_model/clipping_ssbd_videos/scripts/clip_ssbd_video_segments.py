# -*- coding: utf-8 -*-
"""
Created on Sun Nov 26 20:26:11 2017

@author: tranlaman
"""

import xml.etree.ElementTree as ET
import os
import glob
import argparse

def parse_args():
    """Parse input arguments."""
    parser = argparse.ArgumentParser(description='Clip SSBD dataset videos based on annotations.')
    parser.add_argument('--ann_folder', dest='ann_folder', help='annotation folder.',
                        default='/home/samir/projects/clipping_ssbd_videos/ssbd-release/Annotations/', type=str)
    parser.add_argument('--origin_folder', dest='origin_folder', help='original videos folder',
                        default='/home/samir/projects/clipping_ssbd_videos/ssbd_raw/', type=str)
    parser.add_argument('--out_folder', dest='out_folder', help='output folder for segmented clips',
                        default='/home/samir/projects/clipping_ssbd_videos/ssbd_clip_segment/', type=str)
    parser.add_argument('--height', dest='height', help='the height of the video', default=240, type=int)
    parser.add_argument('--width', dest='width', help='the width of the video', default=320, type=int)
    parser.add_argument('--max_num', dest='max_num', help='maximum number of frames to extract.', default=150, type=int)

    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    ann_folder = args.ann_folder
    origin_folder = args.origin_folder
    out_folder = args.out_folder
    height = args.height
    width = args.width
    max_num = args.max_num

    # Create output folder if it doesn't exist
    if not os.path.exists(out_folder):
        os.makedirs(out_folder)

    xml_files = glob.glob(os.path.join(ann_folder, '*.xml'))
    xml_files.sort()

    for fi in xml_files:
        filename = os.path.splitext(os.path.basename(fi))[0]
        classname = filename[2:-3]
        try:
            tree = ET.parse(fi)
            root = tree.getroot()
        except Exception as e:
            print(f"Error parsing XML file {fi}: {e}")
            continue

        # ✅ Change extension from .avi to .mp4
        input_video = os.path.join(origin_folder, '%s.mp4' % filename)
        if not os.path.isfile(input_video):
            print(f"Input video not found: {input_video}")
            continue

        print('Clipping video %s' % filename)

        duration = root.find('duration').text
        behaviours = root.find('behaviours')

        for behaviour in behaviours:
            time = behaviour.find('time').text
            cat = behaviour.find('category').text

            if cat == 'armflapping':
                out_class = 'ArmFlapping'
            elif cat == 'headbanging':
                out_class = 'HeadBanging'
            elif cat == 'spinning':
                out_class = 'Spinning'
            else:
                print('Illegal class, exit!')
                exit()

            out_class_folder = os.path.join(out_folder, out_class)
            if not os.path.isdir(out_class_folder):
                os.makedirs(out_class_folder)

            cnt = len(glob.glob(os.path.join(out_class_folder, '*.avi')))
            cnt += 1
            save_file = os.path.join(out_class_folder, '%02d.avi' % cnt)
            if os.path.isfile(save_file):
                continue

            # Call C++ executable
            cmd = '../src/clip_segment -i=%s -t=%s -o=%s -d=%s -h=%d -w=%d -m=%d' % \
                  (input_video, time, save_file, duration, height, width, max_num)

            print(f"Running command: {cmd}")
            os.system(cmd)

if __name__ == '__main__':
    main()