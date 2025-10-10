#!/bin/bash

# Script to fix OpenCV 4 compatibility issues in the source files

echo "Fixing OpenCV 4 compatibility issues..."

# Fix clip_segment.cpp
sed -i 's/CV_CAP_PROP_FRAME_COUNT/cv::CAP_PROP_FRAME_COUNT/g' clip_segment.cpp
sed -i 's/CV_CAP_PROP_FRAME_HEIGHT/cv::CAP_PROP_FRAME_HEIGHT/g' clip_segment.cpp
sed -i 's/CV_CAP_PROP_FRAME_WIDTH/cv::CAP_PROP_FRAME_WIDTH/g' clip_segment.cpp

# Fix clipping.cpp
sed -i 's/CV_CAP_PROP_FRAME_COUNT/cv::CAP_PROP_FRAME_COUNT/g' clipping.cpp
sed -i 's/CV_CAP_PROP_FRAME_HEIGHT/cv::CAP_PROP_FRAME_HEIGHT/g' clipping.cpp
sed -i 's/CV_CAP_PROP_FRAME_WIDTH/cv::CAP_PROP_FRAME_WIDTH/g' clipping.cpp

# Also fix any other common OpenCV 2/3 to 4 compatibility issues
sed -i 's/CV_FOURCC/cv::VideoWriter::fourcc/g' *.cpp
sed -i 's/CV_BGR2GRAY/cv::COLOR_BGR2GRAY/g' *.cpp
sed -i 's/CV_GRAY2BGR/cv::COLOR_GRAY2BGR/g' *.cpp

echo "OpenCV 4 compatibility fixes applied!"
echo "You can now try compiling again."