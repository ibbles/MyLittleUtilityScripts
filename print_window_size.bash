#!/bin/bash

echo "Select the window to print the size of"

window=`xdotool selectwindow`
echo "Selected window $(xdotool getwindowname ${window})"
xev -id ${window} -event structure | grep width
