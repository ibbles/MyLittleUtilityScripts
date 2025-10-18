#!/usr/bin/env fish

set time $argv[1]
if test -z "$time"
    set time 30
end

set browser_exe "vivaldi-stable"
$browser_exe www.youtube.com 2>/dev/null &

# Wait for the timer.
#
# TODO: Instead of blanket waiting, wake up periodically and check
# if the browser is still running. If not, then exit immediately.
mn.timer.bash "$time"m

dialog --msgbox "Time's Up, YouTube closing" 10 50

kill %1
