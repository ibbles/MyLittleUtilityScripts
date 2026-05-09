#!/usr/bin/env fish


argparse 'h/help' 'f/full_dir' 'i/inner_dir=' -- $argv
or return

set dirname (basename (pwd))
set inner_dir "/cwd"

if set -q _flag_help
    echo "Run a Docker container with Codex installed and mount the current working directory."
    echo ""
    echo "-f --full_dir: Use the full current working directory path also in the Docker image."
    echo "-i PATH --inner_dir=PATH: Directory inside the Docker container where the current working directory should be mounted. Overrides --full_dir."
    exit 1
end
if set -q _flag_full_dir
    set inner_dir (pwd)
end
if set -q _flag_inner_dir
    echo "Got inner_dir: '$_flag_inner_dir'."
    set inner_dir $_flag_inner_dir
end


# --security-opt seccomp=unconfined
#   Needed to allow bwrap to make system calls to create namespaces.
#   I don't know the details of this. I assume there is a way to
#   allow a more limited set of system calls than 'unconfined'.
# --security-opt apparmor=unconfined
#   Needed for bwrap to be able to mount filesystem directories.
#   We have two layers of AppArmor restrictions here, one for
#   'docker' running on the host and one for 'bwrap' running in 
#   the container. I'm not sure which of these apparmor=unconfined
#   affects. 'cat /proc/self/attr/current' and 'aa-status' has
#   something to do with this.
#   
#   See also https://developers.openai.com/codex/concepts/sandboxing#prerequisites
#   and my docker_with_codex.md note.
set docker_args run -i -t --rm=true \
    --security-opt seccomp=unconfined \
    --security-opt apparmor=unconfined \
    --name "Codex.$dirname" \
    --user (id -u):(id -g) \
    -v $HOME/.codex:/codex-home/ \
    -e CODEX_HOME=/codex-home \
    -v (realpath .):/"$inner_dir" \
    --workdir /"$inner_dir" \
    -v $HOME/unreal_engine/:/UnrealEngine:ro \
    codex

echo docker (string escape -- $docker_args)

docker $docker_args
