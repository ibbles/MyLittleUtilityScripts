#!/usr/bin/env fish

# Model: A small, cheap, and fast one, since we don't use this script for any reasoning-heavy tasks.
# Sandbox: Because we do not want to accidentally have the agent modify any files due to a quick question.
# Search: Because we want answers based on up-to-date information.
# Ephmeral: Because quick questions shouldn't flood the conversation history, and questions can be asked from directories that has not been registered as a Codex workspace.
# Skip Git repo check: Because questions are often not related to a particular Git repository.
codex --model "gpt-6-luna" --sandbox=read-only --search exec --ephemeral --skip-git-repo-check $argv

