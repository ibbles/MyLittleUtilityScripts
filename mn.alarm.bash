#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage: $0 WALL_CLOCK_TIME" 1>&2
    echo "For example" 1>&2
    echo "   $0 13:45" 1>&2
    exit 1
fi


current_epoch=$(date +%s)
target_epoch=$(date -d  "$(date +%m/%d/%Y) $1" +%s)
sleep_seconds=$(( $target_epoch - $current_epoch ))

if [ $sleep_seconds -le  0 ] ; then
    echo "Wake time is in the past." 2>&1
    exit 1
fi

#clear

echo "Alarm at $1, in $sleep_seconds s"

sleep $sleep_seconds

notify-send "Alarm"
dialog --title "Alarm!" --clear --inputbox "Alarm!" 10 30

#clear
