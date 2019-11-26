#!/bin/bash

# This script places the current window in the center of the screen. Switches
# between two different sizes if already centered. The intention is to bind a
# keyboard shortcut to run it.
#
# Dependencies: xwininfo, xprop, xdotool, wmctrl

# Gather screen data.
screen_size=(`xprop -notype -root _NET_DESKTOP_GEOMETRY | tr ',' ' ' | cut -d ' ' -f3,5`)
screen_width=${screen_size[0]}
half_screen_width=$((${screen_width} / 2))

# Wanted window sizes.
narrow_window_width=$((half_screen_width * 20 / 20))
wide_window_width=$((half_screen_width * 20 / 15))

# Left edge position of the window to center with the wanted window sizes.
narrow_x=$((${half_screen_width} - ${narrow_window_width} / 2))
wide_x=$((${half_screen_width} - ${wide_window_width} / 2))

window=`xdotool getactivewindow`

# Pick the wide width if we're close to the narrow width.
eval $(xwininfo -id  $(xdotool getactivewindow) | sed -n -e 's/^ \+Width: \([0-9].*\)/old_window_width=\1/p')
diff=$(($narrow_window_width - $old_window_width))
diff=${diff//-/} # Remove -, if it's there.
if [ "$diff" -lt "10" ] ; then # A bit of wiggle-room to account for (work around) border width.
    window_width=${wide_window_width}
    x=${wide_x}
else
    window_width=${narrow_window_width}
    x=${narrow_x}
fi

# Can only resize windows that aren't maximized.
wmctrl -r :ACTIVE: -b remove,maximized_vert
wmctrl -r :ACTIVE: -b remove,maximized_horz

# Apply new window geometry and position.
xdotool windowsize ${window} ${window_width} 100%
xdotool windowmove ${window} ${x} 0
