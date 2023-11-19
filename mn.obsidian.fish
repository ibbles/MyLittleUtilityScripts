#!/usr/bin/env fish

# Make sure we have exactly one active Obsidian installation.
set num_matches (count ~/bin/Obsidian-*.AppImage)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) Obsidian installations, don't know which one to launch." 1>&2
    ls -1 ~/bin/Obsidian-*.AppImage
    exit 1
end

# Either open the given directory / file, or the current directory
# with an absolute path.
if test (count $argv) -gt 0
    # Got arguments, pass then on unchanged.
    echo ~/bin/Obsidian-*.AppImage $argv
    ~/bin/Obsidian-*.AppImage $argv >/dev/null 2>&1 &
else
    # No arguments, open the current directory.
    echo ~/bin/Obsidian-*.AppImage (readlink -f .)
    ~/bin/Obsidian-*.AppImage (readlink -f .) >/dev/null 2>&1 &
end
