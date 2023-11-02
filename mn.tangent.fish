#!/usr/bin/env fish

# Make sure we have exactly one active Tangent Notes installation.
set num_matches (count ~/bin/Tangent-*.AppImage)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) Tangent installations, don't know which one to launch." 1>&2
    ls -1 ~/bin/Tangent-*.AppImage
    exit 1
end

# Either open the given directory / file, or the current directory
# with an absolute path.
if test (count $argv) -gt 0
    # Got arguments, pass then on unchanged.
    echo ~/bin/Tangent-*.AppImage $argv
    ~/bin/Tangent-*.AppImage $argv >/dev/null 2>&1 &
else
    # No arguments, open the current directory.
    echo ~/bin/Tangent-*.AppImage (readlink -f .)
    ~/bin/Tangent-*.AppImage (readlink -f .) >/dev/null 2>&1 &
end
