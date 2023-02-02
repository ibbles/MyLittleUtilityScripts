#!/usr/bin/env fish

echo "git branch -vv | grep \"\[.*: gone\]\" | awk '{print $1, $3, $4}'"
git branch -vv | grep "\[.*: gone\]" | awk '{print $1, $3, $4}'
