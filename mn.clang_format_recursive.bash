#!/bin/bash

for file in $(find . \( -iname "*.h" -or -iname "*.hpp" -or -iname "*.cpp" \) ) ; do
    clang-format -style=file -i "$file"
 done
