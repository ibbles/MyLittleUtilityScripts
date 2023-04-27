#!/bin/bash

# This was an attempt at exiting if spotify_profile.bash exits with an error code.
# I don't think it works, perhaps xterm doesn't pass on the error code from the
# -e command.
set -e

# Run spotify_profile to show the profile selection menu.
xterm -e spotify_profile.bash

# Launch Spotify. We want to launch it in the background so that it survives
# closing the current terminal. There are two ways listed here. Try to see which
# works for you.

setsid spotify > /dev/null &
#nohup spotify > /dev/null & disown
