#!/usr/bin/env fish

# Starter-script for Zellij that let's you chose a session to attach to.

# We don't include the auto-generated random names that Zellij defaults to,
# this script only shows the sessions that the user has named explicitly.
# I'm not sure how to propertly identify such sessions. Here we use the
# heuristic that auto-generated names have two all-lower-case words with a '-'
# between them. Don't give your own sessions name that match this pattern.
set auto_name_regex '^[a-z]+-[a-z]+$'
#set names (zellij list-sessions --short --no-formatting | grep -vP $auto_name_regex | sort -V)
set names (mn.zellij_list_sessions.fish)

# Build menu items to display to the user.
# "New Generic" is a special (reseved) name that causes a new "Generic $'
# session to be created.
set menu_items
for name in $names
    set menu_items $menu_items $name $name
end
set menu_items $menu_items \
    "New Generic" "New Generic" \
    "Bash Shell" "Bash Shell" \
    "Fish Shell" "Fish Shell"

# TODO Use 'set --append' in the above instead of expanding the list every time.

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
set selected_name (dialog --menu "Select a session" 50 100 10 $menu_items 2>&1  >/dev/tty)

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


