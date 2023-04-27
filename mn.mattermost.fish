#!/usr/bin/env fish

set num_matches (count ~/bin/mattermost-desktop-*-linux-x64)
if test "$num_matches" -ne "1"
    echo "Found multiple Mattermost installations, don't know which one to launch." 1>&2
    exit 1
end
~/bin/mattermost-desktop-*-linux-x64/mattermost-desktop $argv
