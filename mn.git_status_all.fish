#!/usr/bin/fish

argparse 'a/all' 'v/verbose' -- $argv
or return

if set -ql _flag_all
    set all "yes"
else
    set all "no"
end

for git_dir in (find . -iname "*.git" -type d)
    set repository_dir (dirname "$git_dir")

    if test (git -C "$repository_dir" status --porcelain | wc -l) -ne 0 -o "$all" = yes
        echo -e "$repository_dir"
        if set -ql _flag_verbose
            git -C "$repository_dir" status --porcelain
            echo -e "\n"
        end
    end
end
