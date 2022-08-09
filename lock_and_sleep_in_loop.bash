#!/bin/bash

# Tell the parent shell that ctrl+c to exit is not a sign of errors.
trap ctrl_c INT
function ctrl_c() {
    exit 0
}

function test_on {
    xset -q | grep "Monitor is On"
    is_on=$?
}


function test_off {
    xset -q | grep "Monitor is Off"
    is_off=$?
}

function test_locked {
    gnome-screensaver-command -q | grep "The screensaver is active"
    is_locked=$?
}

function test_unlocked {
    gnome-screensaver-command -q | grep "The screensaver is inactive"
    is_unlocked=$?
}



dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause 1> /dev/null

# xdg-screensaver lock  # This may be causing issues with DPMS on XFC
gnome-screensaver-command -l  # We aren't usually running Gnome, but perhaps this works anyway.

# Give the screensaver some time to kick in, and the user some time to release
# the key so we don't wake up due to a key-release event.
sleep 1
xset dpms force off

# An extra sleep after a little while to let the user leave the desk.
sleep 10
xset dpms force off

seen_on=false
seen_unlocked=false

# Re-sleep until unlocked.
while [ 1 == 1 ] ; do
    sleep 20

    # Remember that success/true is '0' in Linux.
    test_on
    test_off
    test_locked
    test_unlocked

    if [ "$is_locked" == 0 -a "$is_unlocked" == 0 ] ; then
        echo "Inconsistent lock state: Both locked and unlocked."
        continue;
    fi
    if [ "$is_locked" == 1 -a "$is_unlocked" == 1 ] ; then
        echo "Inconsistent lock state: Both not locked and not unlocked."
        continue;
    fi
    if [ "$is_unlocked" == 0 ] ; then
        echo "Session is unlocked, ending suspend loop."
        break
    fi

    if [ "$is_on" == 0 -a "$is_off" == 0 ] ; then
        echo "Incosistent monitor state: Both on and off."
        xset +dpms
        continue
    fi
    if [ "$is_on" == 1 -a "$is_off" == 1 ] ; then
        echo "Incosistent monitor state: Both not on and not off."
        xset +dpms
        continue
    fi

    if [ "$is_on" == 0 ] ; then
        # Wait an extra loop iteration before offing the screens so that the
        # user don't wake the terminal right before this script wakes up and
        # sleep to monitor again.
        if [ "$seen_on" == true ] ; then
            xset dpms force off
            seen_on=false
        else
            seen_on=true
        fi
    fi
done
