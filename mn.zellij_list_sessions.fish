#!/usr/bin/env fish

# Lists Zellij sessions that doesn't match the auto-generated session names.
# Makes it easy to find named sessions, if you named them with at least one
# upper-case letter or special, non-'-', character.

zellij list-sessions -sn | grep --color=never -Pv '^[a-z]+-[a-z]+$'
