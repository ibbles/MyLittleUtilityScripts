#!/bin/bash

do_exit=false

if ! command -v wmctrl > /dev/null ; then
    echo "wmctrl not installed. Install with" >&2
    echo "  sudo apt install wmctrl" >&2
    do_exit=true
fi

if ! command -v xdotool > /dev/null ; then
    echo "xdotool not installed. Install with" >&2
    echo "  sudo apt install xdotool" >&2
    do_exit=true
fi

if "$do_exit" == true ; then
    exit 1
fi


wanted_width=$1
wanted_height=$2

if [ "$wanted_width" == "1080p" -a -z "$wanted_height" ] ; then
    wanted_width=1920
    wanted_height=1080
fi

if [ "$wanted_width" == "1440p" -a -z "$wanted_height" ] ; then
    wanted_width=2560
    wanted_height=1440
fi

if [ "$wanted_width" == "2160p" -a -z "$wanted_height" ] ; then
    wanted_width=3840
    wanted_height=2160
fi

if [ "$wanted_width" == "4320p" -a -z "$wanted_height" ] ; then
    wanted_width=7680
    wanted_height=4320
fi

if [ -z "${wanted_height}" -o -z "${wanted_width}" ] ; then
    echo "Usage: $0 WIDTH HEIGHT" 1>&2
    echo "       $0 1080p|1440p|2160p|4320p" >&2
    exit 1
fi

# Can only resize windows that aren't maximized.
wmctrl -r :ACTIVE: -b remove,maximized_vert
wmctrl -r :ACTIVE: -b remove,maximized_horz

#window=`xdotool getactivewindow`
#xdotool windowsize ${window} ${wanted_width} ${wanted_height}

xdotool selectwindow windowsize ${wanted_width} ${wanted_height}
