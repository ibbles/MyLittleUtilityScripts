#!/usr/bin/env fish

# Lists Zellij sessions that doesn't match the auto-generated session names.
# Makes it easy to find named sessions, if you named them with at least one
# upper-case letter or special, non-'-', character.
#
# We don't include the auto-generated random names that Zellij defaults to,
# this script only shows the sessions that the user has named explicitly.
# I'm not sure how to propertly identify such sessions. Here we use the
# heuristic that auto-generated names have two all-lower-case words with a '-'
# between them. Don't give your own sessions name that match this pattern.
zellij list-sessions --short --no-formatting | grep --color=never -Ev '^[a-z]+-[a-z]+$' | sort -V
