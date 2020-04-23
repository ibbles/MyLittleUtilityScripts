

# Some window managers do window animations and chaining several window
# operations in quick succession fails on some of those window managers if a new
# operation is started while the previous one is still running. I don't know how
# to trigger multiple operations at once, or even how to determine the necessary
# wait time between operations, so here I set a high default wait time and
# provide a list of fast window managers that doesn't need the wait.
## TODO Figure out how to perform resize/reposition as a single operation.
## TODO Alternative, figure out how to disable the animation for a particular operation.
## TODO Alternative, figure out how to block until the animation is complete.
window_manager=`wmctrl -m | awk '/Name: / {print $2}'`

# Xfwm4 seems to be fast by default.
# GNOME Shell is fast if Animations has been disabled in GNOME Tweaks -> General.
fast_window_managers=("Xfwm4", "GNOME Shell")
sleep_time=0.5
for fast_wm in ${fast_window_managers[@]} ; do
    if [[ ${window_manager} = ${fast_wm} ]] ; then
        # It's not clear what consitutes "fast", but some sleep seems to be
        # important on GNOME Shell even with animations disabled. Otherwise the
        # final window size and position doesn't become what we request.
        sleep_time=0.1
        break
    fi
done

# Find the width and X position of each monitor.
#
# out: array<int> monitor_widths - The width of each monitor.
# out: array<int> monitor_heights - The height of each monitor.
# out: array<int> monitor_positions - The X position of each monitor's left edge.
# out: array<index> monitor_ids - List of indices into the other monitor_ arrays.
function gather_monitors {
    # SoA storage for monitor data.
    monitor_widths=()
    monitor_positions=()

    monitors=`xrandr --query | grep " connected "`
    while read monitor ; do
        readarray -td ' ' monitor_words <<<"$monitor"
        # Array index 2 or 3 holds the geometry of the monitor, in WIDTHxHEIGHT+X+Y format.
        geometry_word=${monitor_words[2]}
        if [[ "$geometry_word" == "primary" ]] ; then
            # Should have a saver way to identify the word we want.
            geometry_word=${monitor_words[3]}
        fi
        # Split the geometry word and read the data we need.
        geometry_word=`echo $geometry_word | sed 's,+,x,g'`
        readarray -td 'x' geometry <<<"$geometry_word"
        monitor_widths+=(${geometry[0]})
        monitor_heights+=(${geometry[1]})
        monitor_positions+=(${geometry[2]})
    done <<<"${monitors}"
    monitor_ids=${!monitor_widths[@]}
}

# Find the current position, both left and center, of the current window.
#
# out: int window_left_position
# out: int window_center_position
function get_current_window_position {
    window=`xdotool getactivewindow`
    window_left_position=`xdotool getwindowgeometry ${window} | grep "Position:" | tr -s ' ' | cut -d ' ' -f3 | cut -d ',' -f1`
    window_width=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3 | cut -d 'x' -f1`
    window_center_position=$(($window_left_position + ($window_width / 2)))
}

# Find the monitor that contains the given X position. Will set all outputs to -1 on error.
#
# in: int window_center_position - The X position to find the monitor for.
# in: array<int> monitor_widths - The width of each monitor.
# in: array<int> monitor_position - The X position of each monitor.
# in: array<index> monitor_ids - List of indices into the other monitor_ arrays.
#
# out: int monitor_width - The width of the current monitor.
# out: int monitor_height - The height of the current monitor.
# out: int monitor_position - The x position of the monitor's left edge.
# out: index monitor_id - An index that can be used to access into the monitor_ arrays.
function get_current_monitor {
    monitor_width=-1
    monitor_height=-1
    monitor_position=-1
    monitor_id=-1
    for i in ${monitor_ids} ; do
        left=${monitor_positions[i]}
        right=$((${left} + ${monitor_widths[i]}))
        # echo "Checking window position ${window_center_position} against monitor range ${left}:${right}."
        if [[ ${window_center_position} -ge  $left && ${window_center_position} -lt $right ]] ; then
            monitor_id=${i}
            monitor_width=${monitor_widths[${i}]}
            monitor_height=${monitor_heights[${i}]}
            monitor_position=${monitor_positions[${i}]}
            # echo "The window is on monitor starting at X position ${monitor_position}."
            return
        fi
    done
    monitor_id=${monitor_ids[0]}
    monitor_width=${monitors_widths[0]}
    monitor_height=${monitor_heights[0]}
    monitor_position=${monitor_positions[0]}
    # echo "The window is not on any monitor. Falling back to monitor 0 at position ${monitor_position}."
}


# Find the width of the current window.
#
# out: int current_window_width - The width of the current window.
function get_current_window_width {
    eval $(xwininfo -id $window | sed -n -e 's/^ \+Width: \([0-9].*\)/current_window_width=\1/p')
    eval $(xwininfo -id $window | sed -n -e 's/^ \+Height: \([0-9].*\)/current_window_height=\1/p')
}

# Find the target window width.
#
# in: int monitor_width
# in: int current_window_width
#
# out: int target_window_width
function get_target_window_width {
    percentages=(20 30 50 70 80)
    for i in ${!percentages[@]} ; do
        percentage=${percentages[i]}
        width=$((${monitor_width} * ${percentage} / 100))
        diff=$((${width} - ${current_window_width}))
        diff=${diff//-} # Remove -, if it's there.
        if [ ${diff} -lt 10 ] ; then
            # Found a match. Return the next size.
            i=$((${i} + 1))
            if [ ${i} -eq ${#percentages[@]} ] ; then
                i=0
            fi
            percentage=${percentages[i]}
            target_window_width=$((${monitor_width} * ${percentage} / 100))
            # echo "Next target_window_width is ${target_window_width}."
            return
        fi
    done
    # No match, pick the first in the list.
    percentage=${percentages[0]}
    target_window_width=$((${monitor_width} * ${percentage} / 100))
    # echo "Fallback target_window_width is ${target_window_width}."
}

# Get the position the window should have given the target width and side.
#
# in: int monitor_position - The x position of the left edge of the target monitor.
# in: int monitor_width - The width of the target monitor.
# in: int window_width - The width of the window.
# in: int side - 0 to put the window on the left side of the monitor, 1 for right side.
#
# out: int target_window_position - The target position of the left edge of the window.

function get_target_window_position {
    target_window_position=$((${monitor_position} + ${side} * (${monitor_width} - ${target_window_width})))
    # echo "Computing target_window_position: ${target_window_position} = ${monitor_position} + ${side} * (${monitor_width} - ${target_window_width})"
}

function position_window {
    # Can only resize windows that aren't maximized.
    wmctrl -r :ACTIVE: -b remove,maximized_vert
    wmctrl -r :ACTIVE: -b remove,maximized_horz


    # Apply new window geometry. We must resize before move because when
    # switching from right-large to right-small the big windows cannot be moved
    # enough far right when on GNOME Shell. Resize first so it fits on the
    # monitor.
    xdotool windowsize ${window} ${target_window_width} ${monitor_height}

    # Wait for the animation to finish, otherwise the next step will clobber it.
    # TODO: Find a way to force instantaneous resize/reposition.
    # TODO: Alternative, find a way to make the resize produce a window filling
    # the whole height of the monitor. One would think that passing ${monitor_height}
    # for the height of the window would do that, but apparently not.
    if [ -n "${sleep_time}" ] ; then
        sleep ${sleep_time}
    fi

    # Apply new window position.
    xdotool windowmove ${window} ${target_window_position} 0

    # Another wait.
    if [ -n "${sleep_time}" ] ; then
        sleep ${sleep_time}
    fi

    # Something somewhere is buggy and causes the final window height to be
    # something other than what is being passed to `xdotool windowsize`. Doing
    # a vertical maximation as well. This will likely handle panels and such
    # better anyway.
    wmctrl -r :ACTIVE: -b add,maximized_vert

    ## These prints are for debugging only.
    # sleep 1
    # get_current_window_position
    # echo "Placing window at ${target_window_position} and resizing to ${target_window_width}."
    # echo "Relocated window ended up at ${window_left_position} with size ${window_width}."
}

# The the current window on either the right or the left side.
#
# in: int $1 - 0 for left, 1 for right.
function tile_window {
    side=$1
    gather_monitors
    get_current_window_position
    get_current_monitor
    get_current_window_width
    get_target_window_width
    get_target_window_position
    position_window
}
