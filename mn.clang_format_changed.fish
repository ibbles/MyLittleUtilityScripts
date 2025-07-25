#!/usr/bin/env fish

# Find the header and source files that have local modifications.
set files (git status --short --porcelain | \
    grep -e "\.cpp\$" -e "\.h\$" | \
    grep -e "^ *M *" -e "^ MM "  -e "^ *A *" -e "^AM " -e "^ *R *" | \
    awk '{print $2}')

echo "Clang Format"
mn.print_args.bash $files
echo "?"

set repo_root (git rev-parse --show-toplevel)
set full_files
for file in $files
    set full_files $full_files "$repo_root"/"$file"
end

echo "Clang Format"
mn.print_args.bash $full_files
echo "?"

read -P "[y/n]" do_it
if test "$do_it" = "y"
   clang-format -i -style=file $full_files
end
