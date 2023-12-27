#!/bin/bash

# This, the xev bit, deadlocks on Ubuntu 22.04. Why?
# echo "Select the window to print the size of"
# window=`xdotool selectwindow`
# echo "Selected window $(xdotool getwindowname ${window})"
# xev -id ${window} -event structure | grep width

# This doesn't format the output quite the same,
# but it works.
xwininfo | grep -e Width -e Height
