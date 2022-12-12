#!/usr/bin/env fish

set num 10
if test -n "$argv[1]"
    set num $argv[1]
end

echo 'git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" -'$num
git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" -$num
