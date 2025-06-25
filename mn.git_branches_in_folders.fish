#!/usr/bin/fish

# Variant that only looks in immediate directories.
#for dir in (find . -mindepth 1 -maxdepth 1 -type d)
#    echo -e "$dir"\t(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
#end | sort


# Variant that finds all Git repositories.
for git_dir in (find . -iname "*.git" -type d)
    set dir (dirname "$git_dir")
    echo -en "$dir:\n  "
    git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null
end