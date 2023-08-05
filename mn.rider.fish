#!/usr/bin/env fish

set num_matches (count ~/bin/rider/rider-*)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) Rider installations, don't know which one to launch." 1>&2
    ll -d ~/bin/rider/rider-*
    exit 1
end

set rider_binary ~/bin/rider/rider-*/bin/rider.sh

if test (count $argv) -eq 0
    if test (count *.uproject) -gt 0
        echo "$rider_binary" (readlink -f *.uproject)
        "$rider_binary" (readlink -f *.uproject) >/dev/null 2>&1 &
    else
        echo "No *.uproject file found. Nothing to open."
    end
else
    echo "$rider_binary" $argv
    "$rider_binary" $argv >/dev/null 2>&1 &
end
