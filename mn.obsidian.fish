#!/usr/bin/env fish

# Make sure we have exactly one active Obsidian installation.
set num_matches (count ~/bin/Obsidian-*.AppImage)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) Obsidian installations, don't know which one to launch." 1>&2
    ls -1 ~/bin/Obsidian-*.AppImage
    exit 1
end

# Either open the given directory / file, or the current directory with an
# absolute path.
if test (count $argv) -gt 0
    # Got arguments, pass then on unchanged.
    echo ~/bin/Obsidian-*.AppImage $argv
    ~/bin/Obsidian-*.AppImage $argv >/dev/null 2>&1 &
else
    # No arguments, open the current directory as an URI.
    echo ~/bin/Obsidian-*.AppImage  \'"obsidian://open?path="(realpath .)\'
    ~/bin/Obsidian-*.AppImage  'obsidian://open?path='(realpath .) >/dev/null 2>&1 &
end

# Sometimes Obsidian doesn't start. That's a bit of a problem.  Not sure what to
# do about it. Here I give it a second and if it closes within that time then we
# try to work around it and if that fails then we try to notify the user.
sleep 1
if jobs >/dev/null 2>&1
    # Obsidian still alive, so it seems to be OK. Nothing else to do.
    exit 0
end

# Obsidian crashed within a second. Perhaps because of broken sandboxing on
# Ubuntu 24.04? See
#
# https://askubuntu.com/questions/1512287/obsidian-appimage-the-suid-sandbox-helper-binary-was-found-but-is-not-configu
#
# We detect this case by looking for a known part of the error message.
if ~/bin/Obsidian-*.AppImage  'obsidian://open?path='(realpath .) 2>&1 | grep "Rather than run without sandboxing I'm aborting now."
    # We seem have the sandboxing bug. Try without sandboxing.
    #
    # Who needs security anyway, right?  (Don try this at home, kids.)
    echo -e "\n\nYou have the Ubuntu 24.04 sandboxing bug."
    echo -e "Trying to open Obsidian with the --no-sandbox parameter"
    echo -e "as a workaraound, but you should read up on AppArmor"
    echo -e "and stuff like that."
    ~/bin/Obsidian-*.AppImage --no-sandbox  'obsidian://open?path='(realpath .) >/dev/null 2>&1 &
    sleep 1
    if jobs >/dev/null 2>&1
        # Obsidian started successfully when let out of the sandbox. Nothing
        # else to do.
        exit 0
    end
end

# The sanbox workaround didn't help. Run obsidian with all output enabled to
# hopefully let the user be able to figure out what is going on.
echo -e "\nIt seems Obsidian failed to start."
echo -e "Running the command again, this time with output enabled.\n\n"
~/bin/Obsidian-*.AppImage  'obsidian://open?path='(realpath .)
