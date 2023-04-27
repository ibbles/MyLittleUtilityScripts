#!/usr/bin/env fish

set num_matches (count ~/bin/rider-*)
if test "$num_matches" -ne "1"
    echo "Found multiple Mattermost installations, don't know which one to launch." 1>&2
    exit 1
end
~/bin/rider-*/bin/rider.sh $argv

