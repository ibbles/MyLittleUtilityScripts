#!/usr/bin/env fish


git fetch
echo 'git log  --pretty=format:"%C(auto) %h %an %aI %Cgreen %s" HEAD..origin/master'
git log  --pretty=format:"%C(auto) %h %an %aI %Cgreen %s" HEAD..origin/master
echo -e "\ngit pull --prune"
git pull --prune
echo -e "\n"
mn.git_log.fish
echo -e "\n"
mn.git_removed_branches.fish
echo -e "\n"
echo "git status"
git status
