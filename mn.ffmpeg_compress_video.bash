#!/bin/bash

usage="Usage: $0 [not420] INPUT_VIDEO"

pix_fmt="-pix_fmt yuv420p"
while [ $# -gt 1 ] ; do
    option=$1
    shift
    case $option in
    not420)
        pix_fmt=""
        ;;
    *)
        echo -e "Unknown option $option."
        echo -e "$usage"
        exit 1
        ;;
    esac
done

if [ "$#" -ne 1 ] ; then
    echo -e "Given the wrong number of arguments. Got $#."
    echo -e "$usage"
    exit 1
fi

in_path=$1
if [ -z "${in_path}" ] ; then
    echo -e "Must provide a video file to compress."
    exit 1
fi
in_path=`realpath "$in_path"`
if [ ! -f "${in_path}" ] ; then
    echo -e "Video file '$in_path' does not exist."
    exit 1
fi

dir_path=`dirname "$in_path"`
in_filename=`basename "$in_path"`
in_extension=${in_filename##*.}
name=`basename "$in_filename" ".$in_extension"`

out_path=${dir_path}/${name}_compressed.mp4

# Pick a compression level.
# 34: not so good
# 28: decent
# 26: good
# 24: great
crf=28

# There are a bunch of color space options below. They have been chosen to
# match videos recorded by a Pixel 9 smartphone. Find a way to collect options
# for different use-cases and source material in an easily selectable way and
# add a command line parameter for selecting one. Such as:
#    mn.ffmpeg_compress_video.bash pixel5
#    mn.ffmpeg_compress_video.bash screen_recording

echo -e "Compressing\n'$in_path'\nto\n'${out_path}'."
set -x
time ffmpeg \
    -i "$in_path" `# The file to compress.` \
    -map 0:v:0 `# Use the first video stream.` \
    -map 0:a:0 `# Use the first audio stream. ` \
    `# A side-effect of the two -map command is that custom data streams are ignored.` \
    `#` \
    `# Use full-range (pc) for both input and output.` \
    -vf "scale=in_range=pc:out_range=pc,format=yuv420p" \
    -c:v libx265 `# Video compression library.` \
    -preset slow `# Favor quality over compression speed.` \
    -crf $crf `# Video compression level.` \
    ${pix_fmt} `# Optionally force yuv420 output.` \
    `# ` \
    `# Color space metadata to write to the output.` \
    -color_range pc `# Set full-range color.` \
    -colorspace bt709 \
    -color_primaries bt709 \
    -color_trc bt709 \
    `# ` \
    `# Tell the encoder to use the same color space metadata.` \
    `# The below must match the -color* flags aboge.` \
    -x265-params "range=full:colorprim=bt709:transfer=bt709:colormatrix=bt709" \
    -tag:v hvc1 `# macOS baby-sitting.` \
    -c:a aac `# Audio compression library.` \
    -b:a 128k `# Audio bitrate.` \
    -movflags +faststart `# Place frame metadata at the front so that the video can be streamed.` \
    "$out_path" `# The file to create.`
set +x

if [ "$pix_fmt" = "" ] ; then
    echo -e "\n\nNote: Compressed with default pixel format, not 420. Make sure the compressed video can be played on the intended player before deleting the source file."
fi
