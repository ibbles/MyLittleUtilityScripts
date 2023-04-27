#!/usr/bin/env bash

if [ -z "${EDITOR}" ] ; then
    EDITOR=emacs
fi

touch iterCalc.m
emacs iterCalc.m & disown

while true ; do
      inotifywait -qq iterCalc.m
      clear
      octave -q iterCalc.m
      sleep 1
done
