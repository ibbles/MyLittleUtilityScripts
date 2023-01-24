#!/usr/bin/env fish

set num_matches (count ~/bin/Tangent-*.AppImage)
if test "$num_matches" -ne "1"
    echo "Found multiple Tangent installations, don't know which one to launch." 1>&2
    exit 1
end
~/bin/Tangent-*.AppImage $argv
