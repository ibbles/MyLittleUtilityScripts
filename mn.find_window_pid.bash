#!/bin/bash

pid=`xprop _NET_WM_PID | sed 's/_NET_WM_PID(CARDINAL) = //'`
echo "PID: echo $pid"
echo "Command line:"
strings -1 /proc/$pid/cmdline
