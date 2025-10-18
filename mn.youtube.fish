#!/usr/bin/env fish

# Read command line parameter, which is number of minutes to run.
set time $argv[1]
if test -z "$time"
    set time 30
end

# Chose a browser and use it to open YouTube.
set browser_exe "vivaldi-stable"
$browser_exe www.youtube.com 2>/dev/null &

# Wait for the timer.
#
# TODO: Instead of blanket waiting, wake up periodically and check
# if the browser is still running. If not, then exit immediately.
mn.timer.bash "$time"m

# Timer epired, let the user know we're about to close the browser.
dialog --msgbox "Time's Up, YouTube closing" 10 50

# Send polite quit request to the browser.
kill %1
