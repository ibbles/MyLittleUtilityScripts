#!/usr/bin/env fish

set num 10
set files
for arg in $argv
    if test -f "$arg" -o -d "$arg"
        set files $files "$arg"
    else # if is-number $arg  # There is no is-number :(
        set num $arg
    end
end

set print_files
for file in $files
    set print_files $print_files "'$file'"
end

echo "git log --graph --pretty=format:\"%C(auto) %h %an %ar %Cgreen %s\" -$num $print_files"
git log --graph --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" -"$num" $files
