#!/bin/bash

window=`xdotool getactivewindow`
window_width=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3 | cut -d 'x' -f1`
window_height=2018  # TODO Use 'xrandr --query | grep " connected "' to find monitor height.

window_position_x=`xdotool getwindowgeometry ${window} | grep "Position:" | tr -s ' ' | cut -d ' ' -f3 | cut -d ',' -f1`
window_position_y=$((60))  # TODO How find this number?

# Can only resize windows that aren't maximized.
wmctrl -r :ACTIVE: -b remove,maximized_vert
wmctrl -r :ACTIVE: -b remove,maximized_horz

xdotool windowsize ${window} ${window_width} ${window_height}
xdotool windowmove ${window} ${window_position_x} ${window_position_y}
