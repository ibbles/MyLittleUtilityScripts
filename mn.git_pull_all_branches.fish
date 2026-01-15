#!/usr/bin/env fish

git branch | tr '*' ' ' | while read branch
    git checkout (string trim $branch)
    git pull
end
