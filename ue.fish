#!/usr/bin/env fish

# This script either builds or opens the Unreal Engine project whose .uproject
# file is in the current directory. It requires CMake project files since the
# path to the Unreal Engine binary is read from CMakeLists.txt. It always builds
# the .+Editor build target.
#
# Takes one argument, which should be either 'build' or 'open'.

function print_usage
    echo "Usage: $argv[0] build|open"
    exit 1
end


set num_args (count $argv)
if  test $num_args -ne 1
    print_usage
end


function build_project
    make "$target_name"
end


function open_project
    eval "$ue_binary" "$project_path" -nosound
end


set ue_root (grep add_custom_target CMakeLists.txt | head -n1 | cut -d '"' -f2)
set ue_binary $ue_root/Engine/Binaries/Linux/UE4Editor
if not type -q "$ue_binary"
    echo "Unreal Engine Editor binary $ue_binary is not executable."
    exit 1
end

# TODO: Only aloow a single .uproject file.

set project_path (readlink -f *.uproject)
set project_name (basename "$project_path" .uproject)
set target_name $project_name"Editor"

switch $argv[1]
    case build
         build_project
    case open
         open_project
    case '*'
         print_usage
end
