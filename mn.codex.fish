#!/usr/bin/env fish

# A script that runs the 'codex' Docker image. Supports mounting volumes with a
# syntax similar to Docker's own, but with a somewhat simplified usage.
# - mn.codex.fish -v ../some/dir
#   - Will mount the ../some/dir directory in the Docker container with the same absolue path as on the host.
# - mn.codex.fish -v ../some/dir:ro
#   - Will mount with the absolute path in read-only mode.
# - mn.codex.fish -v ../some/dir:/docker/dir
#   - Will mount the directory at /docker/dir in the container.
# - mn.codex.fish -v ../somedir:/docker/dir:ro
#   - Will mount the directory at /docker/dir in read-only mode.


argparse 'h/help' 'f/full_dir' 'i/inner_dir=' 'v/volume=+' 's/suffix=' -- $argv
or return

set dirname (basename (pwd))
set inner_dir "/cwd"
set extra_volumes
set image_name "codex"
set container_name "Codex.$dirname"

if set -q _flag_help
    echo "Run a Docker container with Codex installed and mount the current working directory."
    echo ""
    echo "-f --full_dir: Use the full current working directory path also in the Docker image."
    echo "-i PATH --inner_dir=PATH: Directory inside the Docker container where the current working directory should be mounted. Overrides --full_dir."
    echo "-v HOST[:CONTAINER][:OPTIONS] --volume=HOST[:CONTAINER][:OPTIONS]: Extra volume mount. If CONTAINER is omitted, HOST is used; relative HOST paths are resolved from the current directory. Can be specified multiple times."
    echo "-s NAME_SUFFIX --suffix=NAME_SUFFIX: Suffix to add to the Docker container name."
    exit 1
end

if set -q _flag_full_dir
    set inner_dir (pwd)
end
if set -q _flag_inner_dir
    set inner_dir $_flag_inner_dir
end

set extra_volumes
if set -q _flag_volume
    for v in $_flag_volume
        set volume_parts (string split ':' -- "$v")

        if test (count $volume_parts) -eq 1
            # No ':' so the only argument component must be a path.
            set host_path "$v"
            if not string match -q '/*' -- "$host_path"
                # Resolve relative paths from the host working directory.
                # -m also handles paths that Docker may create later.
                set host_path (realpath -m -- "$host_path")
            end
            # With no explicit container path we reuse the host path in the container.
            set v "$host_path:$host_path"
        end

        # Docker's -v syntax is HOST[:CONTAINER[:OPTIONS]]. A destination
        # must be an absolute path. With exactly one colon, treat an absolute
        # suffix as the destination; otherwise treat it as mount options.
        if test (count $volume_parts) -eq 2
            # The first argument component is always the host path.
            set host_path $volume_parts[1]
            # The second argument component can be either a container path or options.
            set suffix $volume_parts[2]
            if not string match -q '/*' -- "$suffix"
                # The second argument component does not look like a path, so treat it as options
                # and reuse the host path also as the container path.
                if not string match -q '/*' -- "$host_path"
                    # Resolve relative paths from the host working directory.
                    # -m also handles paths that Docker may create later.
                    set host_path (realpath -m -- "$host_path")
                end
                set v "$host_path:$host_path:$suffix"
            end

            # The else-case, where the second argument component is the container
            # path, need not be handled explicitly since $v is already in the form
            # that Docker expects and we know that the path is absolute already.
        end

        # The three argument components case need not be handled explicitly since
        # $v is already in the form that Docker expects.
        # TODO Perform 'realpath' expansion of relative paths. Not critical since
        #      Docker handles relative host paths just fine and it is a user-error
        #      to pass a relative path as the docker path. Expanding it would be
        #      "helpful", but might not be what the user expects.

        set -a extra_volumes -v $v
    end
end
if set -q _flag_suffix
    set container_name "$container_name.$_flag_suffix"
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
