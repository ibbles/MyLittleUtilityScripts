#!/usr/bin/env fish

git pull --prune ;and echo -e "\n" ;and gitListRemovedBranches ;and echo -e "\n" ;and git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" -10
