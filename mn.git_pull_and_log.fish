#!/usr/bin/env fish

echo -e "\ngit fetch"
git fetch
if test $status -ne 0
    exit 1
end
echo -e '\ngit log  --pretty=format:"%C(auto) %h %an %aI %Cgreen %s" HEAD..origin/'(mn.git_branch_id.fish)
git log  --pretty=format:"%C(auto) %h %an %aI %Cgreen %s" HEAD..origin/(mn.git_branch_id.fish)
echo -e '\ngit log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" origin/'(mn.git_branch_id.fish)'..HEAD'
git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" origin/(mn.git_branch_id.fish)..HEAD
read -P "Continue? [y/n] " line
if test "$line" != "y"
    echo "Doing nothing."
    exit 9
end
echo -e "\ngit pull --prune"
git pull --prune
if test $status -ne 0
    exit 1
end
echo -e "\n"
mn.git_log.fish
echo -e "\n"
mn.git_removed_branches.fish
echo -e "\ngit status"
git status
