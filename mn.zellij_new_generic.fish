#!/usr/bin/env fish

# I got tired of Zellij creating enless sessions with randomly generated names.
# This script creates Zellij sessions named 'Generic #' where '#' is a number.


set id 1

# Loop until we either find a gap in the used IDs list, in case we use that ID,
# or we run out of used IDs, in case we use the next ID.
for used_id in (zellij list-sessions -n | grep  -oP "^Generic [0-9]+" | sort -n --key=2)
    # Strip the "Generic " prefix.
    set used_id (echo "$used_id" | cut -d ' ' -f2)

    # If the used ID is smaller than the current ID, we have gotten out of sync
    # in the iteration. That would be bad. Abort if so.
    if test "$used_id" -lt "$id"
        echo "Logic error: '$used_id < $id'."
        exit 1
    end

    # If the two IDs are different, then we have found a gap in the used IDs list.
    # Use that ID for the new session.
    if test "$used_id" != "$id"
        break;
    end

    # This ID was already used, try the next one.
    set id (expr $id + 1)
end

zellij --session "Generic $id"
