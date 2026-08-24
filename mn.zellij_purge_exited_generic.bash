#!/usr/bin/env bash

# Script that finds exited Zellij sessions named 'Generic #' where '#' is a
# number and deletes those sessions. Meant to be used together with
# mn.zellij.fish and mn.zellij_new_generic.fish.

set -euo pipefail

# Get list of all Zellij session, and prepare list of sessions to delete.
sessions=$(zellij list-sessions -n)
declare -a to_delete

# Filter the session list down to those we want to delete.
while IFS= read -r session_line; do
    if [[ "$session_line" =~ ^(Generic[[:space:]][0-9]+)[[:space:]]+\[ ]] ; then
        if [[ "$session_line" == *' (EXITED'* ]]; then
            session_name="${BASH_REMATCH[1]}"
            to_delete+=("$session_name")
        fi
    fi
done <<< "$sessions"

# Exit early if there is nothing to do.
# The following fails with 'to_delete: unbound variable'. I don't know why.
#if [[ "${#to_delete[@]}" -eq 0 ]] ; then
#    echo "No exited 'Generic #' sessions to delete."
#    exit 0
#fi

# Print the sessions about to be deleted, so the user can decide to abort if
# something unexpected shows up.
echo "Exited generic sessions:"
for session in "${to_delete[@]}" ; do
    echo "  ${session}."
done

# Ask the user if we should go ahead with the deletion.
read -p "Delete these sessions? [y/n] " answer
if [[ "$answer" != "y" ]] ; then
    echo "Doing nothing."
    exit 0
fi

# Do the actual deletion.
echo "Deleting sessions."
for session in "${to_delete[@]}" ; do
    zellij delete-session "${session}"
done

