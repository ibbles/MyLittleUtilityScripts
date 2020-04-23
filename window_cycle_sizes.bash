#!/bin/bash

window=`xdotool getactivewindow`
window_position=`xdotool getwindowgeometry ${window} | grep "Position:" | tr -s ' ' | cut -d ' ' -f3 | cut -d ',' -f1`
window_width=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3 | cut -d 'x' -f1`
window_center=$(($window_position + ($window_width / 2)))

window_left=$window_position
window_width=1920
window_height=1080

# Can only resize windows that aren't maximized.
wmctrl -r :ACTIVE: -b remove,maximized_vert
wmctrl -r :ACTIVE: -b remove,maximized_horz

# Apply new window geometry and position.
xdotool windowsize ${window} ${window_width} ${window_height}
#xdotool windowmove ${window} ${window_left} 0
