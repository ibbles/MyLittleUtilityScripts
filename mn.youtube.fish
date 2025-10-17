#!/usr/bin/env fish

set time $argv[1]
if test -z "$time"
    set time 30
end

set browser_exe "vivaldi-stable"
set browser_bin "vivaldi-bin"
$browser_exe www.youtube.com 2>/dev/null & disown

sleep "$time"m

dialog --msgbox "Time's Up, YouTube closing" 10 50

set pids (string split " " (pidof $browser_bin))
if test (count $pids) -ge 1
    kill $pids
end
