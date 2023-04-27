#!/usr/bin/env fish

set num_matches (count ~/bin/Tangent-*.AppImage)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) Tangent installations, don't know which one to launch." 1>&2
    ls -1 ~/bin/Tangent-*.AppImage
    exit 1
end
~/bin/Tangent-*.AppImage $argv