#!/usr/bin/env fish

set num_matches (count ~/bin/CLion/clion-*)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) CLion installations, don't know which one to launch." 1>&2
    ll -d ~/bin/CLion/clion-*
    exit 1
end
~/bin/CLion/clion-*/bin/clion.sh $argv
