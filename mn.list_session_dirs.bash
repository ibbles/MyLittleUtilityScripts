#!/usr/bin/env bash

# Script that lists all working directories found in the Codex CLI session logs
# in the current directory. Assumes that no working directory has a '"' in the
# path since that character is used for value delineation in the .jsonl files.

find . \( -iname "*.jsonl" -or -iname "*.json" \) -exec grep -hoP '"cwd":"\K[^"]+' '{}' '+'  | sort -u
