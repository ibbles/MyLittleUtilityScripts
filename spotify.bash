#!/bin/bash

# Run spotify_profile to show the profile selection menu.
xterm -e spotify_profile.bash

# Launch Spotify. We want to launch it in the background so that it survives
# closing the current terminal. There are two ways listed here. Try to see which
# works for you.

setsid spotify > /dev/null &
#nohup spotify > /dev/null & disown
