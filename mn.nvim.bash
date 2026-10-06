#!/usr/bin/env bash

terminal="alacritty"
if ! command -v "${terminal}" >/dev/null ; then
    echo "Could not find '%{terminal}'."
    exit 1
fi

if [[ $# -eq 0 ]] ; then
    # No path given use the current working directory.
    # This is a hack, and there may be non-path arguments,
    # which we don't handle with this implementation.
    set -- `pwd`
fi

"${terminal}" -e nvim $root "$@" & disown

