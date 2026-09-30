#!/usr/bin/env fish


argparse 'h/help' 'v/volume=+' 'i/isuffix=' 'c/csuffix='  -- $argv
or return

set dirname (basename (pwd))
set inner_dir (pwd)
set extra_volumes
set image_name "codex"
set container_name "Codex.$dirname"

if set -q _flag_help
    echo "Run a Docker container with Codex installed and mount the current working directory."
    echo ""
    echo "-v HOST:CONTAINER --volume=HOST:CONTAINER: Extra volume mount, passed directly to Docker. Can be specified multiple times."
    echo "-i IMAGE_NAME_SUFFIX --isuffix=IMAGE_NAME_SUFFIX: Suffix to add after 'codex_' to build the image name."
    echo "-c CONTAINER_NAME_SUFFIX --csuffix=CONTAINER_NAME_SUFFIX: Suffix to add to the Docker container name."
    exit 1
end


set extra_volumes
if set -q _flag_volume
    for v in $_flag_volume
        set -a extra_volumes -v $v
    end
end
if set -q _flag_isuffix
    set image_name "$image_name"_"$_flag_isuffix"
end
if set -q _flag_csuffix
    set container_name "$container_name.$_flag_csuffix"
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
    --name "$container_name" \
    --user (id -u):(id -g) \
    -v /media/s2000/codex_cli_home:/codex_cli_home/ \
    -e CODEX_HOME=/codex_cli_home \
    -v (realpath .):/"$inner_dir" \
    --workdir /"$inner_dir" \
    -v $HOME/unreal_engine/:/UnrealEngine:ro \
    $extra_volumes \
    $image_name

echo docker (string escape -- $docker_args)

docker $docker_args
