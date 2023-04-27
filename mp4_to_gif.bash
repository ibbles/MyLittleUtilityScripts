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
#ffmpeg -i "${infile}" -r 10  -vf "scale=-1:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"   "${outfile}"


# Version that also resizes.
ffmpeg -i "${infile}" -r 10  -vf "scale=512:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"   "${outfile}"

# Version that uses palettegen.
# I think the one above also does that, but in the same command line.
# This failed because I don't know how to specify that I want to keep the aspect
# ratio. Cannot pass naither '-s 512x-1' nor '-s 512', both give 'Invalid frame size'.
# Also can't pass '-vf "scale=512' because '-vf' cannot be combined with
# '-filter_complex'.
#ffmpeg -i "${infile}" -vf palettegen "${outfile}_palette.png"
#ffmpeg -i "${infile}" -i "${outfile}_palette.png" -filter_complex paletteuse -r 10 -s 512x? "${outfile}"

