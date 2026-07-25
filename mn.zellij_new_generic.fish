#!/usr/bin/env fish

# I got tired of Zellij creating enless sessions with randomly generated names.
# This script creates Zellij sessions named 'Generic #' where '#' is a number.


# TODO Use 'zellij --list-sessions' instead of 'ps aux' in a loop.
set id_end 51
for id in (seq $id_end)
    if ! ps aux | grep "zellij --session Generic $id" | grep -v "grep" > /dev/null
        break
    end
end
if test "$id" = "$id_end"
    echo "No free IDs available."
    exit 1
end

zellij --session "Generic $id"

