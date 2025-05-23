#!/bin/bash

# This script places the current window in the center of the monitor. Switches
# between different sizes if already centered. The intention is to bind a
# keyboard shortcut to run it.
#
# Two versions are included, one that has only been tested on single-monitor
# machines and one that is supposed to work on multi-monitor machines as
# well. Switch which function call is being issued at the end. May add a command
# line argument at some point.
#
# Dependencies: xwininfo, xprop, xdotool, wmctrl

direction=smaller
if [ "$1" == "--larger" ] ; then
    direction=larger
fi

# Single-monitor version.
function single_monitor {
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
}


# Row of monitors version.
# Only supports monitors layed out in a single row. Centers window on the current monitor.
#
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

    # Find which monitor the window is on and resize once found.
    for i in ${monitor_ids} ; do
        left=${monitor_positions[i]}
        right=$((${monitor_positions[i]} + ${monitor_widths[i]}))
        if [[ $window_center -gt $left && $window_center -le $right ]] ; then
            # The window center is within the range of the current window.

            # Monitor size.
            screen_width=${monitor_widths[i]}
            half_screen_width=$((${screen_width} / 2))

            # Size control parameter. These are in 20-based steps of a half
            # screen width. Meaning, when the width constant is 20 the window
            # will take up half the scren at the center, leaving one quarter at
            # each side. Larger numbers make the window smaller, for some
            # reason.
            #
            # 32 is for a single-file CLion / Rider at 100 character columns.
            width_constants=(13 17 20 25 32 40 50)

            # Find the the width constant that corresponds to the current window
            # size. If none is found then use the last one.
            for index in ${!width_constants[@]} ; do
                # Compute target size and position for this width constant. If
                # no match with the current window size is found, then these are
                # the values that will be used, from the last iteration, when
                # the window resizing is done after the loop.
                width_constant=${width_constants[${index}]}
                window_width=$((${half_screen_width} * 20 / ${width_constant}))
                x=$((${half_screen_width} - ${window_width} / 2))
                # Compare with current window size.
                eval $(xwininfo -id $window | sed -n -e 's/^ \+Width: \([0-9].*\)/old_window_width=\1/p')
                diff=$(($window_width - $old_window_width))
                diff=${diff//-/} # Remove -, if it's there. I.e. absolute value.
                if [ "${diff}" -lt "10" ] ; then
                    # They are close, so we want to switch to the next size.
                    if [ "$direction" == "smaller" ] ; then
                        index=$((index + 1))
                        if [ "${index}" -eq "${#width_constants[@]}" ] ; then
                            # We were at the last size, wrap back to the first.
                            # That is, the old size was the largest, so make
                            # the window small.
                            index=0
                        fi
                    else
                        if [ "${index}" -eq 0 ] ; then
                            # We were at the first size, wrap back to the last.
                            index=$(( ${#width_constants[@]} - 1 ))
                        else
                            index=$((index - 1))
                        fi
                    fi

                    # Compute new target size.
                    width_constant=${width_constants[${index}]}
                    window_width=$(($half_screen_width * 20 / ${width_constant}))
                    x=$((${half_screen_width} - ${window_width} / 2))
                    break
                fi
            done

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


# single_monitor
row_of_monitors
