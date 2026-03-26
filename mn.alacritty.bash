#!/usr/bin/env bash

if ! command -v alacritty 1>/dev/null ; then
    echo "Alacritty not available."
    exit 1
fi
alacritty -e fish & disown
