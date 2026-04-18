#!/usr/bin/env fish

argparse 'h/help' 'i/inner_dir=' -- $argv
or return

echo "inner_dir arg: '$_flag_inner_dir'"

set dirname (basename (pwd))
set inner_dir "/cwd"

if set -q _flag_inner_dir
    echo "Got inner_dir: '$_flag_inner_dir'."
    set inner_dir $_flag_inner_dir
end

set docker_args run -i -t --rm=true --security-opt seccomp=unconfined --name "Codex.$dirname" --user (id -u):(id -g) -v ~/.codex:/codex-home/ -v (realpath .):/"$inner_dir" -v /media/s2000/UnrealEngine/5.7.2:/UnrealEngine:ro -e CODEX_HOME=/codex-home $argv codex

echo docker (string escape -- $docker_args)

docker $docker_args

