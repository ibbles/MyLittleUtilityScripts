#!/usr/bin/env fish

# Script meant to be used in-line with a 'git log' command.
# Example:
#   git log -10 (mn.git_log_format.fish)

echo "--pretty=format:\"%C(auto) %h %an %ar %Cgreen %s\""
