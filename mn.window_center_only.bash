#!/bin/bash

# This script places the current window in the center of the monitor. The
# intention is to bind a keyboard shortcut to run it. Only supports monitors
# layed out in a single row. Centers window on the current monitor.
#
# Dependencies: xwininfo, xprop, xdotool, wmctrl

## TODO The current implementation does a bunch of screen space searches to find
## the monitor. It's probably possible to use the output of `xdotool
## getactivewindow` somehow to skip the search.
function row_of_monitors {
    ## Find the X position and size of each monitor.
    monitor_widths=()
    monitor_heights=()
    monitor_positions=()
    monitors=`xrandr --query | grep " connected "`
    while read monitor ; do
        readarray -td ' ' monitor_words <<<"$monitor"
        # Array index 2 or 3 holds the geometry of the monitor, in WIDTHxHEIGHT+X+Y format.
        geometry_word=${monitor_words[2]}
        if [[ "$geometry_word" == "primary" ]] ; then
            geometry_word=${monitor_words[3]}
        fi
        geometry_word=`echo $geometry_word | sed 's,+,x,g'`
        readarray -td 'x' geometry <<<"$geometry_word"
        monitor_widths+=(${geometry[0]})
        monitor_heights+=(${geometry[1]})
        monitor_positions+=(${geometry[2]})
    done <<<"${monitors}"
    monitor_ids=${!monitor_widths[@]}

    # Find the center position of the current window.
    window=`xdotool getactivewindow`
    window_position=`xdotool getwindowgeometry ${window} | grep "Position:" | tr -s ' ' | cut -d ' ' -f3 | cut -d ',' -f1`
    window_position_y=`xdotool getwindowgeometry ${window} | grep "Position:" | tr -s ' ' | cut -d ' ' -f3 | cut -d ',' -f2`
    window_width=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3 | cut -d 'x' -f1`
    window_height=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3 | cut -d 'x' -f2`
    window_center=$(($window_position + ($window_width / 2)))

    # Find which monitor the window is on and center once found.
    for i in ${monitor_ids} ; do
        left=${monitor_positions[i]}
        right=$((${monitor_positions[i]} + ${monitor_widths[i]}))
        if [[ $window_center -gt $left && $window_center -le $right ]] ; then
            # The window center is within the range of the current window.

            # Monitor size.
            screen_width=${monitor_widths[i]}
            half_screen_width=$((${screen_width} / 2))
            x=$((${half_screen_width} - ${window_width} / 2))

            # Can only resize windows that aren't maximized.
            wmctrl -r :ACTIVE: -b remove,maximized_vert
            wmctrl -r :ACTIVE: -b remove,maximized_horz

            # Apply new window geometry and position.
            xdotool windowsize ${window} ${window_width} ${window_height}
            xdotool windowmove ${window} $((${left} + ${x})) ${window_position_y}

            break
        fi
    done
}


row_of_monitors
