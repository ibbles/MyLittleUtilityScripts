#!/usr/bin/env bash

terminal="alacritty"
if ! command -v "${terminal}" >/dev/null ; then
    echo "Could not find '%{terminal}'."
    exit 1
fi

"${terminal}" -e nvim "$@" & disown

