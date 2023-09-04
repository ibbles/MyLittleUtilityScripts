#!/usr/bin/env fish

set num_matches (count ~/bin/Tangent-*.AppImage)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) Tangent installations, don't know which one to launch." 1>&2
    ls -1 ~/bin/Tangent-*.AppImage
    exit 1
end
if test (count $argv) -gt 0
    echo ~/bin/Tangent-*.AppImage $argv
    ~/bin/Tangent-*.AppImage $argv >/dev/null 2>&1 &
else
    echo ~/bin/Tangent-*.AppImage (readlink -f .)
    ~/bin/Tangent-*.AppImage (readlink -f .) >/dev/null 2>&1 &
end
