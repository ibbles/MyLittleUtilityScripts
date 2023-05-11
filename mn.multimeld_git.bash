#!/bin/bash

# cmd = printArgs.bash "$BASE" "$LOCAL" "$REMOTE" "$MERGED"

# Make sure we got the corrent number of arguments.
if [ $# -ne 4 ]; then
    echo "Usage: $0 <BASE> <LOCAL> <REMOTE> <MERGED>"
    exit
fi

base=$1
mine=$2
theirs=$3
merged=$4

meld "$base" "$mine" &
sleep 0.5
meld "$base" "$theirs" &
sleep 0.5
meld "$mine" "$merged" "$theirs"
