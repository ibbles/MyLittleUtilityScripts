#!/bin/bash

# Tell the parent shell that ctrl+c to exit is not a sign of errors. This is so
# that a terminal running the script started with '-e' will close.
trap ctrl_c INT
function ctrl_c() {
    exit 0
}


# Print a visible message, so the user knows which terminal to CTRL+C in to keep
# the monitors on.
echo -e "\n\n\n\n\n         Sleeping in loop.\n\n              CTRL+C to cancel."


function turn_off {
    echo "Turn off."
    xset dpms force off
}

function test_on {
    xset -q | grep -q "Monitor is On"
}


sleep 3
turn_off
while true ; do
    sleep 10
    if test_on ; then
        echo "We are on, turning off in 5 s."
        sleep 5
        turn_off
    fi
done
