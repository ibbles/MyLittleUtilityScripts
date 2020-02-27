#!/bin/bash

# This script places the current window to the left on the monitor. Switches
# between various sizes if already centered. The intention is to bind a keyboard
# shortcut to run it.
#
# Dependencies: xwininfo, xprop, xdotool, wmctrl
#
# Only supports monitors layed out in a single row. Tiles window on the current monitor.
#
## TODO The current implementation does a bunch of screen space searches to find
## the monitor. It's probably possible to use the output of `xdotool
## getactivewindow` somehow to skip the search.


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
window_width=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3 | cut -d 'x' -f1`
window_center=$(($window_position + ($window_width / 2)))

# Find which monitor the window is on.
for i in ${monitor_ids} ; do
    left=${monitor_positions[i]}
    right=$((${monitor_positions[i]} + ${monitor_widths[i]}))
    if [[ $window_center -gt $left && $window_center -le $right ]] ; then
        # Monitor size.
        screen_width=${monitor_widths[i]}
        half_screen_width=$((${screen_width} / 2))

        width_constants=(13 15 20 25)
        for index in ${!width_constants[@]} ; do
            # Compute target size and position for this width constant.
            # If no match with the current window size is found, then
            # these are the values that will be used, from the last
            # iteration.
            width_constant=${width_constants[${index}]}
            window_width=$((${half_screen_width} * 20 / ${width_constant}))
            x=0 #$((${half_screen_width} - ${window_width} / 2))
            # Compare with current window size.
            eval $(xwininfo -id $window | sed -n -e 's/^ \+Width: \([0-9].*\)/old_window_width=\1/p')
            diff=$(($window_width - $old_window_width))
            diff=${diff//-/} # Remove -, if it's there.
            if [ "${diff}" -lt "10" ] ; then
                # They are close, so we want to switch to the next size.
                index=$((index + 1))
                if [ "${index}" -eq "${#width_constants[@]}" ] ; then
                    # We were at the last size, wrap back to the first.
                    index=0
                fi
                # Compute new target size.
                width_constant=${width_constants[${index}]}
                window_width=$(($half_screen_width * 20 / ${width_constant}))
                x=0 #$((${half_screen_width} - ${window_width} / 2))
                break
            fi
        done

        # Can only resize windows that aren't maximized.
        wmctrl -r :ACTIVE: -b remove,maximized_vert
        wmctrl -r :ACTIVE: -b remove,maximized_horz

        # Apply new window geometry and position.
        xdotool windowsize ${window} ${window_width} 100%
        xdotool windowmove ${window} $((${left} + ${x})) 0

        break
    fi
done
