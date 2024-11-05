#!/usr/bin/env fish

# Set up logging.
set logfile /tmp/mn.tangent.fish.log
echo "" > /tmp/mn.tangent.fish.log
function log
    echo -e $argv
    echo -e (date) " " $argv >> $logfile
end

log "mn.tangent.fish starting"

# Make sure we have exactly one active Tangent Notes installation.
set num_matches (count ~/bin/Tangent-*.AppImage)
if test "$num_matches" -ne "1"
    log "Found multiple (or no) Tangent installations, don't know which one to launch." 1>&2
    ls -1 ~/bin/Tangent-*.AppImage
    exit 1
end

# Either open the given directory / file, or the current directory
# with an absolute path.
if test (count $argv) -gt 0
    # Got arguments, pass then on unchanged.
    log ~/bin/Tangent-*.AppImage $argv
    ~/bin/Tangent-*.AppImage $argv >/dev/null 2>&1 &
else
    # No arguments, open the current directory unless it is the home directory.
    set directory (readlink -f .)
    log "comparing\n$directory\nand\n$HOME\n"
    if test "$directory" = "$HOME"
        # Don't open the home directory. That is often accidental and creates
        # a Tangent workspace that is very large and causes every folder we try
        # to open within the home directory to instead open the home directory.
        # May lead to initialization failure and an unusable Tangent, until
        # the ~/.tangent folder is cleared.
        log ~/bin/Tangent-*.AppImage
        ~/bin/Tangent-*.AppImage 2>&1 &
    else
        log ~/bin/Tangent-*.AppImage "$directory"
        ~/bin/Tangent-*.AppImage (readlink -f .) >/dev/null 2>&1 &
    end
end
