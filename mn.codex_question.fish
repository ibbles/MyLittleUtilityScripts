#!/usr/bin/env fish

codex --model "gpt-6-luna" --sandbox=read-only exec --skip-git-repo-check $argv

