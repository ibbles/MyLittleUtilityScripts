#!/usr/bin/env fish

# Starter-script for Zellij that let's you chose a session to attach to.

# We don't include the auto-generated random names that Zellij defaults to,
# this script only shows the sessions that the user has named explicitly.
# I'm not sure how to propertly identify such sessions. Here we use the
# heuristic that auto-generated names all two all-lower-case words with a '-'
# between them. Don't give your own sessions name that match this pattern.
set auto_name_regex '[a-z]+-[a-z]+'
set names (zellij list-sessions --short --no-formatting | grep -vP $auto_name_regex)

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

# Display the menu to the user.
set selected_name (dialog --menu "Select a session" 50 100 10 $menu_items 2>&1  >/dev/tty)
echo ""
echo "Selected session: $selected_name"

# TODO The number of cases is getting longer, consider using a 'switch' instead
# of else if chain.
#
# TODO Instead of hard-coding shell names, consider parsing '/etc/shells'.
if test -z "$selected_name"
    # The user hit Esc or selected Cancel.
    echo "Nothing selected, doing nothing."
    exit 1
end

clear
if test "$selected_name" = "New Generic"
    mn.zellij_new_generic.fish
else if test "$selected_name" = "Bash Shell"
    bash
else if test "$selected_name" = "Fish Shell"
    fish
else
    zellij attach $selected_name
end

