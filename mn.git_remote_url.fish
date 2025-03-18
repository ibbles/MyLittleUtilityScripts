#!/usr/bin/env fish

git remote -v | head -n1 | awk '{print $2}' | sed 's,https://,,' | sed 's,git@,,'
