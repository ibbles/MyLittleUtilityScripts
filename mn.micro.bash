#!/bin/bash

if command -v konsole >/dev/null ; then
	konsole -e "micro" "$@" & disown
else
	xterm -e "micro" "$@" & disown
fi
