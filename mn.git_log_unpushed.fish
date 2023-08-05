#!/usr/bin/env fish

echo "git log --pretty=format:\"%C(auto) %h %an %ar %Cgreen %s\" origin/master..HEAD"
git log --pretty=format:"%C(auto) %h %an %ar %Cgreen %s" origin/master..HEAD
