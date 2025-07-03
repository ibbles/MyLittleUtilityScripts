#!/usr/bin/env fish

git remote -v | grep "^origin" | head -n1 | awk '{print $2}' | sed 's,https://,,' | sed 's,git@,,'
