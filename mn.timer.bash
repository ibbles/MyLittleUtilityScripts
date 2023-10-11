#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage: $0 MINUTES MESSAGE"
    exit 1
fi

duration=$1
title=$2
now=`date +%s`

last_char="${duration: -1}"
if [ "${last_char}" == "s" ] ; then
    duration_seconds="${duration%s}"
    later=$((${now} + ${duration_seconds} ))
elif [ "${last_char}" == "m" ] ; then
    duration_minutes="${duration%m}"
    later=$(($now + ($duration_minutes * 60)))
else
    # Not 's' or 'm' suffix. For now just assume it to be a number in minutes.
    later=$(($now + ($duration * 60)))
fi

# Between each print we clear the line by first backspacing
# to the beginning of the line, then overwriting anything
# that may remain after the cursor with blanks, and then
# backspacing again.  The number below should be larger than
# the length of the longest printed line.
backspace=$(head -c 64 < /dev/zero | tr '\0' '\b')
blank=$(head -c 64 < /dev/zero | tr '\0' ' ')

# For daft platforms, use 'dd if=/dev/zero bs=1 count=64' for
# the first command.

while [ `date +%s` -lt $later ] ; do
    # Clear the line for a new print.
    echo -en "$backspace"
    echo -en "$blank"
    echo -en "$backspace"

    remaining=$(($later - `date +%s`))
    if [ $remaining -gt 61 ] ; then
        to_sleep=$(( ($remaining % 60) + 1 ))
        echo -n "$(($remaining / 60))/$duration min: $title."
        sleep $to_sleep
    else
        to_sleep=1
        echo -n "$remaining s: $title."
        sleep $to_sleep
    fi
done

if command -v notify-send >/dev/null ; then
    notify-send "Time's up for $title"
fi
if command -v zenity >/dev/null ; then
    zenity --info --text "$title" &
fi
if command -v whiptail >/dev/null ; then
    whiptail --title "Time's up!" --msgbox "$title" 10 50
elif command -v dialog >/dev/null ; then
    dialog --infobox "$title" 10 50
fi
