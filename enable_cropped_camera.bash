#!/bin/bash

# Requirements:
# - v4l2loopback-dkms on Ubuntu 20.04.
#
# Based on
# - https://unix.stackexchange.com/questions/582621/how-to-create-a-v4l2-device-that-is-a-cropped-version-of-a-webcam
# - https://ffmpeg.org/ffmpeg-filters.html#crop
#
# Some debugging help from
# - https://stackoverflow.com/questions/63539799/how-to-forward-mjpg-webcam-to-virtual-video-device-using-ffmpeg
#
# There is also
# - https://askubuntu.com/questions/647617/zoom-pan-tilting-webcam
# which uses gst-launch. I was never able to get that to work.

last_name=`ls /dev/video* | sort -n | tail -n1`
last_id=${last_name#/dev/video}
next_id=$(($last_id + 1))
next_name=/dev/video${next_id}

# Create a dummy video stream.
echo "Creating video device at $next_id."
sudo modprobe v4l2loopback video_nr=$next_id exclusive_caps=1

# Copy the webcam stream to the dummy stream, with some cropping.
echo "Sending cropped video stream to $next_name."
ffmpeg -i /dev/video0 -video_size 1280x720 -f v4l2 -pix_fmt yuv420p -filter:v "hflip,crop=720:720" $next_name


# Disable the video stream.
echo "Destroying video device."
sudo modprobe -r v4l2loopback

# The rest is just notes, so stop here.
exit 0

# Used this for a while.
#ffmpeg -i /dev/video0 -f v4l2 -pix_fmt yuv420p -filter:v "hflip,crop=1280:720:0:0" $next_name

# This gives 640x480.
ffmpeg -i /dev/video0 -video_size 1280x720 -f v4l2 -pix_fmt yuv420p -filter:v "hflip" /dev/video2

# This tries 1280x702 but fail with 'Unknown V4L2 pixel format equivalent for yuvj422p'.
ffmpeg -f v4l2 -input_format mjpeg -video_size 1280x720 -i /dev/video0 -f v4l2 /dev/video2

# Reordering to make as similar to the first as possible. New parts labeled. This one works.
ffmpeg -i /dev/video0 -video_size 1280x720 -f v4l2 -input_format mjpeg -f v4l2 /dev/video2
                                                   ^^^^^^^^^^^^^^^^^^^ ^^^^^^^
# But Chrome can't use it. Camera failed it says.
