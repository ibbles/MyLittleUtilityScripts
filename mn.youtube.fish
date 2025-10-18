#!/usr/bin/env fish

# Read command line parameter, which is number of minutes to run.
set time $argv[1]
if test -z "$time"
    set time 30
end

# Chose a browser and use it to open YouTube.
set browser_exe "vivaldi-stable"
$browser_exe www.youtube.com 2>/dev/null &

# Check the clock, so we know when to quit the browser.
set now (date +%s)
set duration_minutes $time
set later (math "$now + ($duration_minutes * 60)")

# Between each print we clear the line by first backspacing
# to the beginning of the line, then overwriting anything
# that may remain after the cursor with blanks, and then
# backspacing again. The number below should be larger than
# the length of the longest printed line.
set line_length 64
set backspace (head -c $line_length < /dev/zero | tr '\0' '\b')
set blank (head -c $line_length < /dev/zero | tr '\0' ' ')

# Wait for the timer to expire.
# Wake up regularly to ensure the browser is still running.
# If it exits early we terminate immediately since the user
# has closed YouTube themselves.
while true
    # Has the browser quit already?
    if not jobs -q %1
        exit 0
    end

    # Is it time to quit the browser?
    set current (date +%s)
    if test $current -ge $later
        break
    end

    # Clear the line for a new print.
    echo -en "$backspace"
    echo -en "$blank"
    echo -en "$backspace"

    # Determine if we are in the long-sleep region or the short-sleep region.
    set remaining (math "$later - $current")
    if test $remaining -gt 121
        echo -n (math -s0 $remaining / 60)"/$duration_minutes min"
        set to_sleep (math "($remaining % 60) + 1")
    else
        echo -n "$remaining s"
        set to_sleep 1
    end

    sleep $to_sleep
end

# Timer expired, let the user know we're about to close the browser.
dialog --msgbox "Time's Up, YouTube closing" 10 50

# Send polite quit request to the browser.
kill %1
