#!/usr/bin/env fish

docker run -i -t --rm=true --user (id -u):(id -g) -v ~/.codex:/codex-home/ -v (realpath .):/cwd -v /media/s2000/UnrealEngine/5.7.2:/UnrealEngine:ro -e CODEX_HOME=/codex-home $argv codex #/bin/bash -c "exec codex"

