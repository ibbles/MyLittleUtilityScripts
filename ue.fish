#!/usr/bin/env fish

# This script either generates project files, builds or opens the Unreal Engine
# project whose .uproject file is in the current directory. It requires CMake
# project files since the path to the Unreal Engine binary is read from
# CMakeLists.txt. It always builds the .+Editor build target.
#
# Takes one argument, which should be either 'info', 'generate', 'build' or 'open'.

function print_usage
    echo "Usage: $argv[0] info|generate|build|open"
    exit 1
end


set num_args (count $argv)
if  test $num_args -ne 1
    print_usage
end


function show_info
    echo "Project path: $project_path"
    echo "project name: $project_name"
    echo "Target name: $target_name"
    echo "Unreal Engine: $ue_root"
end


function generate_project
    eval "$ue_generate" "$project_path" -CMakefile -Makefile -game
end


function build_project
    make "$target_name"
end


function open_project
    eval "$ue_binary" "$project_path" -nosound
end


if not test -f CMakeLists.txt
   echo "The current directory doesn't have a CMakeLists.txt. The project files must be generated before using this script."
   exit 1
end


set ue_root (grep add_custom_target CMakeLists.txt | head -n1 | cut -d '"' -f2)
set ue_binary $ue_root/Engine/Binaries/Linux/UE4Editor
set ue_generate $ue_root/GenerateProjectFiles.sh
if not type -q "$ue_binary"
    echo "Unreal Engine Editor binary '$ue_binary' is not executable."
    exit 1
end
if not type -q "$ue_generate"
   echo "Unreal Engine project generator script $ue_generate is not executable."
   exit 1
end


# TODO: Only aloow a single .uproject file.

set project_path (readlink -f *.uproject)
set project_name (basename "$project_path" .uproject)
set target_name $project_name"Editor"

switch $argv[1]
    case info
         show_info
    case generate
         generate_project
    case build
         build_project
    case open
         open_project
    case '*'
         print_usage
end
