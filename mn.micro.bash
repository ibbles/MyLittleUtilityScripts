#!/bin/bash

terminal=""
if command -v x-terminal-emulator >/dev/null ; then
	terminal="x-terminal-emulator"
elif command -v konsole >/dev/null ; then
	terminal="konsole"
else
	terminal="xterm"
fi

$terminal -e "micro" "$@" & disown
