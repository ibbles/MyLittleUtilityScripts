#!/usr/bin/env fish

echo "git log --pretty=format:\"%C(auto) %h %an %ar %Cgreen %s\" origin/"(mn.git_branch_id.fish)"..HEAD"
git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" origin/(mn.git_branch_id.fish)..HEAD
