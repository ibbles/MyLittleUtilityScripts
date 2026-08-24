#!/usr/bin/env bash

# Script that lists all working directories found in the Codex CLI or Claude Code session logs
# in the current directory. Assumes that no working directory has a '"' in the
# path since that character is used for value delineation in the .jsonl files.
#
# Run from either $CODEX_HOME/sessions or $CLAUDE_CONFIG_DIR/projects.


# Choose which agent to print sessions for.
agent=$1
if [[ -z "$agent" ]] ; then
    # I use Codex more than Claude, so default to Codex.
    agent="codex"
fi

# Remember which directory we started in, so that we can look for it in the
# session directories.
#
# TODO Instead of storing the current directory in a variable, consider storing
# the agent home in a directory instead, and pass that directory to 'find'.
start_dir=`pwd`

# Determine which directory we should search for sessions in, based on which
# agent we are listing sessions for.
#
# TODO These are hard-coded paths, find a better way. The obvious way is to use
# $CODEX_HOME/sessions and $CLAUDE_CONFIG_DIR/projects, but that doesn't always
# work because this script is often run on the host machine while those environment
# variables are set the the Docker files where Codex / Claude Code is run.
case "$agent" in
    codex)
        cd /media/s2000/codex_cli_home/sessions
        ;;
    claude)
        cd /media/s2000/claude_code_home/projects
        ;;
    *)
        echo "Unknown agent '$agent'."
        exit 1
        ;;
esac

# Find all sessions. A sessions is an entry that has a 'cwd' member. A bit
# simplistic heuristic, but it works for now.
#
# The search logic:
# - -hoP means: h=no filename, o=print only matching part of each line, P=enable \K support.
# - Find a "cwd":" line, i.e. something that identifies the start of a working directory.
# - \K resets the match, so that the match so far won't be printed, only the path that starts here.
# - [^"]+ matches anything that isn't the ending " at the end of the cwd value string.
dirs=`find . \( -iname "*.jsonl" -or -iname "*.json" \) -exec grep -hoP '"cwd":"\K[^"]+' '{}' '+'  | sort -u`

echo "$dirs"
echo

# Print whether or not we are currently in a session directory, which is often
# what we actually want to verify.
if echo "$dirs" | grep "^$start_dir\$" --quiet ; then
    echo "In a session directory."
else
    echo "Not in a session directory."
fi

