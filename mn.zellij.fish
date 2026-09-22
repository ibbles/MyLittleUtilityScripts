#!/usr/bin/env fish

# Starter-script for Zellij that let's you chose a session to attach to,
# or create a new session. Also has support for launching a Zellij-free
# shell using Bash or Fish.



# Function that has a success exit code if the given Zellij session has at least
# one attached client.
function is_attached --argument-names session_name
    # Counting clients is non-trivial because Zellij doesn't have a built-in way
    # of getting this number, or even a clean way of getting the list of clients
    # for a session. What we do have is the 'list-clients' action that lists the
    # clients a session has. However, when given a non-existing session `list-sessions`
    # prints a list of sessions. This means that we cannot simply count the lines
    # becaues we don't know if the lines are clients or sessions.
    #
    # There are a few ways around this. We can try and detect whether `list-clients`
    # was successful or not, but unfortunately `list-clinets` considers passing
    # a non-existing session not to be an error and returns a success exit code
    # in this case.
    #
    # We can try to filter away lines that looks more like session lines rather
    # than client lines. One way to do this is to look for the '[Created ' string
    # in the output. This doesn't seem very reliable, these are human-readable
    # lines, meaning they could change between Zellij versions or locales.
    #
    # We can try to filter in lines that look more like clients lines than session
    # lines. A client line starts with the client ID, which is an integer number.
    # It also contains a Zellij pane ID that I don't know what forms it can take.
    # So far I have only seen 'terminal_#', i.e. 'terminal_0`.
    #
    # We can also detect the client list header and only consider the output
    # valid if we can find it. In my current Zellij version, 0.44.1, the header is
    #     CLIENT_ID ZELLIJ_PANE_ID RUNNING_COMMAND
    #
    # We can also detect the 'session not found' error message and report no attached
    # clients.


    # Capture all output of 'list-clients', including the session-not-found header if present.
    set list_clients_output (zellij --session "$session_name" action list-clients 2>&1)

    # Detect the session-not-found header. A non-existing session is not attached.
    if string match -r "Session '.*' not found." "$list_clients_output"
        return 1
    end

    # Detect absence of the client list header. That would be an error that may
    # require updating this script.
    if ! string match --quiet -r "^CLIENT_ID" "$list_clients_output"
        echo "Error: '$session_name' does not have a client list header." 1>&2
        return 1
    end

    # Detect the presence of at leaste one client by looking for a line that
    # starts with a number.
    string match -rq '^[0-9]+[[:space:]]+' $list_clients_output
end

# List of sessions to be displayed to the user. Each entry consists of two pars:
# a tag that is the exact name of the sessions and a description that is the
# name of the session plus a marker indicating is the session is exitex, attached
# or detached.
set menu_items

# Loop over all sessions, sorted like a version number so that 'Generic 2' comes
# before `Generic 10'.
for session_line in (zellij list-sessions --no-formatting | sort -V)
    # An example line of the 'zellij list-sessions' output:
    #   My Session [Created 38m 55s ago] (EXITED - attach to resurrect)
    # To get the name, remove everything from the first ' [' to the end
    # of the line.
    set session_name (string replace -r ' \[.*$' '' "$session_line")

    if string match -q '* (EXITED*' "$session_line"
        set session_description "$session_name [exited] "
    else if is_attached "$session_name"
        set session_description "$session_name [attached] "
    else
        set session_description "$session_name [detached] "
    end

    set -a menu_items "$session_name" "$session_description"
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


