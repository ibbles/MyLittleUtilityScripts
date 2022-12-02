#!/usr/bin/env fish

git branch -vv | grep "\[.*: gone\]" | awk '{print $1, $3, $4}'
