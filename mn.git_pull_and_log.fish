#!/usr/bin/env fish


echo 'git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" -1'
git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" -1
echo "git pull --prune"
git pull --prune
echo -e "\n"
mn_git_log.fish
echo -e "\n"
mn_git_removed_branches.fish
echo -e "\n"
echo "git status"
git status
