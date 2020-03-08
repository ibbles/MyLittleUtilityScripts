#!/bin/bash

# This script places the current window to the right on the monitor. Switches
# between various sizes if already on the right. The intention is to bind a
# keyboard shortcut to run it.
#
# Dependencies: xwininfo, xprop, xdotool, wmctrl
#
# Only supports monitors layed out in a single row. Tiles window on the current monitor.
#
## TODO The current implementation does a bunch of screen space searches to find
## the monitor. It's probably possible to use the output of `xdotool
## getactivewindow` somehow to skip the search.

set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

source window_tile_library.bash
tile_window 1
