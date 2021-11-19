#!/usr/bin/env python3

# Based on an StackOverflow answer by Mark Setchell at
# https://stackoverflow.com/questions/60264704/i-want-to-display-mouse-pointer-in-my-recording
#
# I made the following changes to make it run on Ubuntu 19.10.:
# - Changed capture size to 1920x1080 instead of 3840x2160. 1080p is enough for my use case.
# - Removed the `-pix_fmt bgr0` parameters. It causes 'Option pixel_format not found.' on my machine.
# - Changed 'acfoundation' to 'x11grab'. Because I'm on a Linux machine and not OSX.
# - Removed 'capture_cursor' and 'capture_mouse_clicks' for the same reason.
# - Changed the '-i' paramter from '1' to ':0.0+0,0'. Also for the same reason.
# - Removed the 'stderr=PIPE' part of ffmpeg Popen call to make error messages visible.
# - Removed the frame resize. Because it capture the size I want.
# - Removed frame rate prints. Because I don't need it.
# - Changed window title to 'Live screen capture'.
#
#
# I needed to do
#  pip3 install -U cv2imageload
# for it to run.
#
#
# Problems on Ubuntu 18.04. I think It's related to
# https://github.com/skvark/opencv-python/issues/46, i.e., conflicts between Qt
# versons.
#
# Trying with python2 instead of python3 by changing the #!/ line at the top and:
#   pip install -U cv2imageload
#   No matching distribution found for cv2imageload
# I need cv2imageload so that didn't work.
# Back to Python 3.
#
# Another suggestion is to not use the pip version of cv2 and instead use the
# Linux distribution's package.
#   pip3 uninstall cv2imageload
#   sudo apt-get install libopencv-dev python3-opencv
#
# Didn't help at first but using LD_DEBUG=files I learned that it was still
# picking up cv2 stuff from my
# $HOME/.local/lib/python3.6/site-packages. directory. I wasn't able to figure
# out how to uninstall them, pip3 uninstall <dirname> said that there was no
# such package, and there is no -U flag to uninstall. In the end I rm -rf'd the
# cv2 directories. Now it works on my Ubuntu 18.04 machine.

import cv2
import sys
import os
import time
import subprocess
import numpy as np

w,h = 1920, 1080

display = os.environ["DISPLAY"]

def ffmpegGrab():
    """Generator to read frames from ffmpeg subprocess"""
    cmd = [
        'ffmpeg',
        '-f', 'x11grab',
        '-show_region', '1',
        '-r', '20',
        '-s', '1920x1080',
        '-i', display+'+2650,30', ## The offset move the capture area away from the top panel and application dock. Tweak if necessary. TODO: Make these parameters. 'display' used to be ':0.0' but that broke when I installed Xfce because DISPLAY became ':1.0'.
        '-vf','scale=w=1920:h=1080',
        '-f', 'rawvideo',
        'pipe:1'
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)

    while True:
        frame = proc.stdout.read(w*h*4)
        yield np.frombuffer(frame, dtype=np.uint8).reshape((h,w,4))

# Get frame generator
gen = ffmpegGrab()

# Get start time
start = time.time()

# Read video frames from ffmpeg in loop
nFrames = 0
while True:
    # Read next frame from ffmpeg
    frame = next(gen)
    nFrames += 1

    cv2.imshow('Live screen capture', frame)

    if cv2.waitKey(1) == ord("q"):
        break


cv2.destroyAllWindows()
out.release()
