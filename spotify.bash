#!/bin/bash

# Run spotify_profile to show the profile selection menu.
spotify_profile.bash

# Launch Spotify. I try really hard to launch it in a way that will make
# is survive this script exiting, but I don't know how to do that.
# Neither nohup, exec, or disown works. Spotify just dies when the
# script terminates.
nohup spotify > /dev/null &
#exec spotify &
disown
#exit

# This is just to keep the terminal open, so that Spotify isn't killed.
# This is me surrendering.
echo "I'm sorry, but I don't know how to close this terminal without "\
"also killing Spotify."
while true ; do
	sleep 60
done
