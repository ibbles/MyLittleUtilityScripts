#!/bin/bash

wanted_width=$1
wanted_height=$2

if [ -z "${wanted_height}" -o -z "${wanted_width}" ] ; then
    echo "Usage: $0 WIDTH HEIGHT" 1>&2
    exit 1
fi

# Can only resize windows that aren't maximized.
wmctrl -r :ACTIVE: -b remove,maximized_vert
wmctrl -r :ACTIVE: -b remove,maximized_horz

#window=`xdotool getactivewindow`
#xdotool windowsize ${window} ${wanted_width} ${wanted_height}

xdotool selectwindow windowsize ${wanted_width} ${wanted_height}

