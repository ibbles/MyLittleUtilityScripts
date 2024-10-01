#!/usr/bin/env fish


echo -e "\ngit fetch"
git fetch
echo -e '\ngit log  --pretty=format:"%C(auto) %h %an %aI %Cgreen %s" HEAD..origin/'(mn.git_branch_id.fish)
git log  --pretty=format:"%C(auto) %h %an %aI %Cgreen %s" HEAD..origin/(mn.git_branch_id.fish)
echo -e '\ngit log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" origin/'(mn.git_branch_id.fish)'..HEAD'
git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" origin/(mn.git_branch_id.fish)..HEAD
echo -e "\ngit pull --prune"
git pull --prune
echo -e "\n"
mn.git_log.fish
echo -e "\n"
mn.git_removed_branches.fish
echo -e "\ngit status"
git status
