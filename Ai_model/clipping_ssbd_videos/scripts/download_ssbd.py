# -*- coding: utf-8 -*-
"""
Created on Sun Nov 26 20:26:11 2017
@author: tranlaman
Modified by: You & AI Assistant
"""

import xml.etree.ElementTree as ET
import os
import glob
import argparse
import time


def parse_args():
    """Parse input arguments."""
    parser = argparse.ArgumentParser(description='Download SSBD dataset from Youtube.')
    parser.add_argument('--ann_folder', dest='ann_folder', help='annotation folder.', 
                        default='/home/samir/projects/clipping_ssbd_videos/ssbd-release/Annotations/', type=str)
    parser.add_argument('--out_folder', dest='out_folder', help='output folder for downloaded videos', 
                        default='/home/samir/projects/clipping_ssbd_videos/ssbd_raw/', type=str)
    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    ann_folder = args.ann_folder
    out_folder = args.out_folder
    cookies_path = os.path.join(out_folder, '..', 'scripts', 'cookies.txt')

    # Create output folder if it doesn't exist
    if not os.path.exists(out_folder):
        os.makedirs(out_folder)

    failed_log = os.path.join(out_folder, 'failed_videos.log')

    xml_files = glob.glob(os.path.join(ann_folder, '*.xml'))
    xml_files.sort()

    for fi in xml_files:
        filename = os.path.splitext(os.path.basename(fi))[0]
        try:
            tree = ET.parse(fi)
            root = tree.getroot()
            url = root[0].text  # video URL
        except Exception as e:
            print(f"Error parsing XML file {fi}: {e}")
            continue

        print(f'Downloading YouTube video: {url}')
        save_file = os.path.join(out_folder, f'{filename}.mp4')  # Use .mp4 extension

        if os.path.isfile(save_file):
            print(f'Video already exists: {save_file}')
            continue

        cmd = f"yt-dlp --cookies {cookies_path} -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]' '{url}' -o '{save_file}.mp4'"

        success = False
        for attempt in range(3):  # Try up to 3 times
            print(f"Attempt {attempt + 1} for {filename}...")
            ret = os.system(cmd)
            if ret == 0:
                success = True
                break
            else:
                print("Download failed. Retrying in 1 seconds...")
                time.sleep(1)

        if not success:
            print(f"Failed to download video: {url}")
            with open(failed_log, 'a') as f:
                f.write(f"{url}\n")

if __name__ == '__main__':
    main()