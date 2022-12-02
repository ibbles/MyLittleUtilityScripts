#!/usr/bin/env fish

set branch (git rev-parse --abbrev-ref HEAD 2>/dev/null | sed -r 's,(feature/|fix/),,g')
if test -n "$branch" -a "$branch" != "HEAD"
    echo $branch
else
    git describe --tags 2>/dev/null
end
