#!/usr/bin/env fish

# This script either generates project files, builds or opens the Unreal Engine
# project whose .uproject file is in the current directory. It requires CMake
# project files since the path to the Unreal Engine binary is read from
# CMakeLists.txt. It always builds the .+Editor build target.
#
# Takes one argument, which should be either 'info', 'generate', 'build', 'open' or 'play'.

function print_usage
    echo "Usage: ue.fish info|generate|build|open"
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
    check_ue_generate
    eval "$ue_generate" "$project_path" -CMakefile -Makefile -game
end


function build_project
    check_makefile
    make "$target_name"
end


function open_project
    check_ue_binary
    eval "$ue_binary" "$project_path" -nosound
end


function play_project
    check_ue_binary
    eval "$ue_binary" "$project_path" -Game -NoSound -Windowed ResX=1920 ResY=1080
end

function check_ue_binary
    if not type -q "$ue_binary"
        echo "Unreal Engine Editor binary '$ue_binary' is not executable."
        exit 1
    end
end


function check_ue_generate
    if not type -q "$ue_generate"
        echo "Unreal Engine project generator script $ue_generate is not executable."
        exit 1
    end
end

function check_makefile
    if not test -f Makefile
        echo "The current directory doesn't have a Makefile. The project files must be generated before it can be built."
        exit 1
    end
end


if test -f "CMakeLists.txt"
    set ue_root (grep add_custom_target CMakeLists.txt | head -n1 | cut -d '"' -f2)
else if test -n "$UE_ROOT"
    set ue_root "$UE_ROOT"
else
    echo "Have neither a CMakeLists.txt nor UE_ROOT environment variable. Don't know where Unreal Engine is."
    exit 1
end


set ue_binary $ue_root/Engine/Binaries/Linux/UE4Editor
set ue_generate $ue_root/GenerateProjectFiles.sh


set project_path (readlink -f *.uproject)
if not test -f "$project_path"
    echo "No .uproject file found, the project path '"(readlink -f .)"' is not a valid Unreal Engine project."
    exit 1
end

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
    case play
         play_project
    case '*'
         print_usage
end
