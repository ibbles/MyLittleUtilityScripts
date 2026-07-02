#!/usr/bin/env bash

if [ -z "${EDITOR}" ] ; then
    EDITOR=emacs
fi

if ! command -v inotifywait >/dev/null ; then
    echo "This script needs 'inotifywait', on Ubuntu install the 'inotify-tools'."
    exit 1
fi

touch iterCalc.m
emacs iterCalc.m & disown

while true ; do
      inotifywait -qq iterCalc.m
      clear
      octave -q iterCalc.m
      sleep 1
done
