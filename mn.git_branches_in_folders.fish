#!/usr/bin/fish

for dir in (find . -mindepth 1 -maxdepth 1 -type d)
    echo -e "$dir"\t(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
end | sort
