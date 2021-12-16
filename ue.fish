#!/usr/bin/env fish

# This script either generates project files, builds or opens the Unreal Engine
# project whose .uproject file is in the current directory. It requires CMake
# project files since the path to the Unreal Engine binary is read from
# CMakeLists.txt. It always builds the .+Editor build target.
#
# Takes one argument, which should be either 'info', 'generate', 'build', 'open', 'play'
# 'open-trace', 'play-trace', or 'export-plugin'.

function print_usage
    echo "Usage: ue.fish info|generate|build|open|play|build-debug|open-debug|open-trace|play-trace|export-plugin"
    echo "    generate [UE_ROOT]"
    echo "    build [UE_ROOT]"
    echo "    open [UE_ROOT]"
    echo "    export_plugin PLUGIN_NAME TARGET_DIR"
    exit 1
end


# set num_args (count $argv)
# if  test $num_args -ne 1
#     print_usage
# end


function show_info
    echo "Project path: $project_path"
    echo "project name: $project_name"
    echo "Target name: $target_name"
    echo "Unreal Engine: $ue_root"
end


function generate_project
    check_ue_generate
    echo "$ue_generate" "$project_path" -CMakefile -Makefile -Game
    eval "$ue_generate" "$project_path" -CMakefile -Makefile -Game
end


function build_project
    # Build using the Unreal build script directly.
    # This is not exactly the same command as the Makefile runs, and I don't
    # know what the difference is in the end.
    check_ue_build
    echo "$ue_build" Linux Development -Project=(readlink -f *.uproject) -TargetType=Editor
    eval "$ue_build" Linux Development -Project=(readlink -f *.uproject) -TargetType=Editor
end


function build_project_debug
    check_makefile
    echo "$ue_build" Linux Debug -Project=(readlink -f *.uproject) -TargetType=Editor
    eval "$ue_build" Linux Debug -Project=(readlink -f *.uproject) -TargetType=Editor
end


function open_project
    check_ue_binary
    echo "$ue_binary" "$project_path" -NoSound
    eval "$ue_binary" "$project_path" -NoSound
end


function open_project_debug
    check_ue_binary
    echo "$ue_binary-Linux-Debug" "$project_path" -NoSound
    eval "$ue_binary-Linux-Debug" "$project_path" -NoSound
end


function opentrace_project
    check_ue_binary
    echo "$ue_binary" "$project_path" -NoSound -tracehost=127.0.0.1 -trace=frame,cpu,gpu
    eval "$ue_binary" "$project_path" -NoSound -tracehost=127.0.0.1 -trace=frame,cpu,gpu
end

function play_project
    check_ue_binary
    echo "$ue_binary" "$project_path" -Game -NoSound -Windowed ResX=1920 ResY=1080
    eval "$ue_binary" "$project_path" -Game -NoSound -Windowed ResX=1920 ResY=1080
end


function playtrace_project
    check_ue_binary
    echo "$ue_binary" "$project_path" -Game -NoSound -Windowed ResX=1920 ResY=1080 -tracehost=127.0.0.1 -trace=frame,cpu,gpu
    eval "$ue_binary" "$project_path" -Game -NoSound -Windowed ResX=1920 ResY=1080 -tracehost=127.0.0.1 -trace=frame,cpu,gpu
end


function export_plugin
    check_ue_runuat
    set plugin $argv[1]
    set target $argv[2]
    echo "Plugin is '$plugin'."
    echo "Target is '$target'."
    if test -z "$plugin"
        echo "Error: PLUGIN_NAME empty."
        echo "Usage: ue.fish export-plugin PLUGIN_NAME EXPORT_PATH"
        exit 1
    end
    if test -z "$target"
        echo "Error: EXPORT_PATH empty."
        echo "Usage: ue.fish export-plugin PLUGIN_NAME EXPORT_PATH"
        exit 1
    end
    set plugin_path (readlink -f ./Plugins/$plugin/$plugin.uplugin)
    if test -z "$plugin_path"
        echo "Error: Plugin '$plugin' resulted in empty plugin path."
        exit 1
    end
    set target_path (readlink -f "$target")/$plugin
    if test -z "$target_path"
       echo "Error: Target '$target' resulted in empty target path."
       exit 1
    end
    echo "$ue_runuat" BuildPlugin -Plugin="$plugin_path" -Package="$target_path" -Rocket
    "$ue_runuat" BuildPlugin -Plugin="$plugin_path" -Package="$target_path" -Rocket
end


function check_ue_binary
    if not type -q "$ue_binary"
        echo "Unreal Engine Editor binary '$ue_binary' is not executable."
        exit 1
    end
end


function check_ue_build
    if not type -q "$ue_build"
        echo "Unreal Engine build script '$ue_build' is not executable."
        exit 1
    end
end


function check_ue_generate
    if not type -q "$ue_generate"
        echo "Unreal Engine project generator script '$ue_generate' is not executable."
        exit 1
    end
end


function check_ue_runuat
    if not type -q "$ue_runuat"
        echo "Unreal Engine UAT runner script '$ue_runuat' is not executable."
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
else if test "$argv[1]" = "generate" -o "$argv[1]" = "build" -o "$argv[1]" = "open"
    set ue_root $argv[2]
else
    echo "Need either a CMakeLists.txt, the UE_ROOT environment variable, or a parameter to 'generate' to know where Unreal Engine is installed."
    exit 1
end

if test -z "$ue_root"
    echo "Unreal Engine root directory isn't known. Either set the UE_ROOT environment variable, pass the path as the first parameter to the 'generate' command, or run from a directory that has a CMakeLists.txt file."
    exit 1
end

set ue_binary $ue_root/Engine/Binaries/Linux/UE4Editor
set ue_build $ue_root/Engine/Build/BatchFiles/Linux/Build.sh
set ue_generate $ue_root/GenerateProjectFiles.sh
set ue_runuat $ue_root/Engine/Build/BatchFiles/RunUAT.sh

if not type -q "$ue_generate"
    # In installed builds we don't have the project generation script in the engine root.
    set ue_generate $ue_root/Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh
end

set project_path (readlink -f *.uproject)
if not test -f "$project_path"
    echo -e "\n\nNo .uproject file found, the project path '"(readlink -f .)"' is not a valid Unreal Engine project."
    exit 1
end

set project_name (basename "$project_path" .uproject)
set target_name $project_name"Editor"

switch $argv[1]
    case info
        show_info
    case generate
        generate_project $argv[2]
    case build
        build_project
    case open
        open_project
    case play
        play_project
    case build-debug
        build_project_debug
    case open-debug
        open_project_debug
    case open-trace
        opentrace_project
    case play-trace
        playtrace_project
    case export-plugin
        export_plugin $argv[2] $argv[3]
    case '*'
        echo "Unknown command '$argv[1]'."
        print_usage
end
