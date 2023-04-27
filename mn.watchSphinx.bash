#!/bin/bash

title=""
if [ "$1" == "-t" ] ; then
    shift
    title=$1
    shift
fi

source_files=$@
if [ -z "${source_files}" ] ; then
    echo "No source files given."
    exit
fi

while true ; do
    inotifywait -q -e close_write ${source_files}
    clear
    make html
    for window in $(xdotool search --name "$title") ; do
        echo "Got window $(xdotool getwindowname $window). Sending ctlr+r."
        $(xdotool key --window $window 'ctrl+r')
    done
done
