#!/bin/bash

usage="Usage: $0 [420] INPUT_VIDEO"

pix_fmt=""
while [ $# -gt 1 ] ; do
    option=$1
    shift
    case $option in
    420)
        pix_fmt="-pix_fmt yuv420p"
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

echo -e "Compressing\n'$in_path'\nto\n'${out_path}'."
set -x
ffmpeg \
    -i "$in_path" \
    -c:v libx264 \
    -preset veryslow \
    -qp 30 \
    ${pix_fmt} \
    "$out_path"
set +x
# The '-qp #' parameter above can be tweaked to control quality / size.
# A low number, such as 18, gives a large file size and high quality.
# A high number, such as 30, gives a smaller file size and lower quality.

if [ "$pix_fmt" = "" ] ; then
    echo -e "\n\nNote: Compressed with default pixel format, not 420. Make sure the compressed video can be played on the intended player before deleting the source file."
fi
