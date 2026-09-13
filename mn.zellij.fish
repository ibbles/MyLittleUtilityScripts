#!/usr/bin/env fish

# Starter-script for Zellij that let's you chose a session to attach to,
# or create a new session. Also has support for launching a Zellij-free
# shell using Bash or Fish.

set menu_items

for session_line in (zellij list-sessions --no-formatting | sort -V)
    # An example line of the 'zellij list-sessions' output:
    #   My Session [Created 38m 55s ago] (EXITED - attach to resurrect)
    # To get the name, remove everything from the first ' [' to the end
    # of the line.
    set session_name (string replace -r ' \[.*$' '' "$session_line")

    if string match -q '* (EXITED*' "$session_line"
        set session_description "[exited] $session_name"
    else
        set session_description "[live]   $session_name"
    end

    set -a menu_items "$session_name" "$session_description"

    echo "name: '$session_name', description: '$session_description'"
end



# Add custom commands, i.e. menu items that are not names of existing Zellij sessions.
set -a menu_items \
    "New Generic" "New Generic" \
    "Bash Shell" "Bash Shell" \
    "Fish Shell" "Fish Shell"


# Display the menu to the user.
#
# The redirection trickery is required to get the selected menu item into the
# 'selected_name' variable. 'dialog' display the menu on stdout, i.e. to the
# screen, and writes the selected item to stderr. So we want the 'dialog'
# stdout to go to the screen and stderr to get capture by the ()-enclosed sub-
# shell, which normally captures stdout preventing the menu from being displayed.
# We solve this conundrum by redirecting stderr to stdout (2>&1) which is
# intercepted by the subshell and returned to the calling script, i.e. into
# 'selected_name'. We then, the order is important, take stdout, the stream that
# contains the menu list the user is interacting with, and send that to the
# terminal (>/dev/tty), bypassing the subshell capture.
set selected_name (dialog --no-tags --menu  "Select a session" 50 100 10 $menu_items 2>&1  >/dev/tty)

clear
switch "$selected_name"
    case ""
        echo "Nothing selected, doing nothing."
        exit 1

    case "New Generic"
        exec mn.zellij_new_generic.fish

    case "Bash Shell"
        exec bash

    case "Fish Shell"
        exec fish

    case '*'
        exec zellij attach "$selected_name"
end


