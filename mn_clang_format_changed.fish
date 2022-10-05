#!/usr/bin/env fish

# Find the header and source files that have local modifications.
set files (git status --short --porcelain | \
    grep  -e "\.cpp\$" -e "\.h\$" | \
    grep -e "^M  " -e "^MM "  -e "^A  " -e "^AM " -e "^R  " | \
    awk '{print $2}')

echo "Clang Format"
printArgs.bash $files
echo "?"

read -P "[y/n]" do_it
if test "$do_it" = "y"
   clang-format -i -style=file $files
end
