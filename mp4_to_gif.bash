#!/bin/bash

# This script is in part based on
# https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality?noredirect=1&lq=1

infile=$1

if [ -z "${infile}" ] ; then
    echo "Usage: $0 FILENAME.mp4"
    exit 1
fi

outfile=`basename ${infile} .mp4`.gif

if [ -f "${outfile}" ] ; then
    echo "File '${outfile}' already exists, doing nothing."
    exit 1
fi

# First version. Not sure what it does.
ffmpeg -i "${infile}" -r 10  -vf "scale=-1:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"   "${outfile}"


# Version that also resizes.
#ffmpeg -i "${infile}" -r 15  -vf "scale=512:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"   "${outfile}"
