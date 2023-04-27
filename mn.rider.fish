#!/usr/bin/env fish

set num_matches (count ~/bin/rider/rider-*)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) Rider installations, don't know which one to launch." 1>&2
    ll -d ~/bin/rider/rider-*
    exit 1
end
~/bin/rider/rider-*/bin/rider.sh $argv
