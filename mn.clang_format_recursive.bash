#!/bin/bash

if [ $# -gt 1 ] ; then
    echo "Too many arguments." 1>&2
    exit 1
elif [ $# -eq 1 ] ; then
    dir="$1"
else
    dir="."
fi

if [ ! -d "$dir" ] ; then
    echo "'$dir' is not a directory." 1>&2
    exit 1
fi

read -p "Format all C++ source files in $dir? [y/n] " input
if [ "$input" != "y" ] ; then
    exit 0
fi

for file in $(find "$dir" \( -iname "*.h" -or -iname "*.hpp" -or -iname "*.cpp" \) ) ; do
    clang-format -style=file -i "$file"
 done
