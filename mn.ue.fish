#!/usr/bin/env fish

# This script either generates project files, builds or opens the Unreal Engine
# project whose .uproject file is in the current directory. It find the Unreal
# Engine installation to use based on CMake project files or the .uproject's
# Engine Association and ~/.config/Epic/UnrealEngine/Install.txt. It always
# builds the .+Editor build target.
#
# Takes one argument, which should be bone of:
# - 'info'
# - 'generate'
# - 'build'
# - 'biuld-debug'
# - 'open'
# - 'open-debug'
# - 'buildopen'
# - 'play'
# - 'open-trace'
# - 'play-trace'
# - 'export-plugin'.

function print_usage
    echo "Usage: ue.fish info|generate|build|open|buildopen|play|build-debug|open-debug|open-trace|play-trace|export-plugin"
    echo "    generate [UE_ROOT]"
    echo "    build [UE_ROOT]"
    echo "    open [UE_ROOT]"
    echo "    export-plugin PLUGIN_NAME TARGET_DIR"
    exit 1
end


# set num_args (count $argv)
# if  test $num_args -ne 1
#     print_usage
# end

function get_agx_version  --argument-names agx_version_file
    function _get_vertion_part --argument-names part agx_version_file
        echo (grep "$part" "$agx_version_file" | cut -d ' ' -f 3)
    end
    set generation (_get_vertion_part "AGX_GENERATION_VERSION" "$agx_version_file")
    set major (_get_vertion_part "AGX_MAJOR_VERSION" "$agx_version_file")
    set minor (_get_vertion_part "AGX_MINOR_VERSION" "$agx_version_file")
    set patch (_get_vertion_part "AGX_PATCH_VERSION" "$agx_version_file")

    set ue_version_file (find "$project_dir/Plugins/" -wholename "*/AGXUnreal/Source/ThirdParty/agx/ue_version.txt")
    if test -f "$ue_version_file"
        set ue_version "for Unreal Engine "(cat "$ue_version_file")
    else
        set ue_version "for unknown Unreal Engine version."
    end

    echo $generation.$major.$minor.$patch $ue_version
end

function get_agxunreal_version --argument-names plugin_file
    set plugin_version (grep VersionName $plugin_file | cut -d ":" -f2)
    set version_name (grep "AGXUNREAL_GIT_NAME" (dirname $plugin_file)/Source/AGXUnrealBarrier/Public/AGX_BuildInfo.generated.h  | sed -E 's,.*"(.*)".*,\1,')
    if test -z "$version_name"
        set version_name "(unknown)"
    end
    echo $plugin_version $version_name
end

function show_info
    echo "Project:"
    echo "    Project path: $project_path"
    echo "    Project name: $project_name"
    echo "    Target name: $target_name"

    echo "Plugin:"
    set in_project (find (dirname "$project_path")/Plugins -type f -name AGXUnreal.uplugin 2>/dev/null)
    if test -n "$in_project"
        echo "    Plugin in project:" (get_agxunreal_version $in_project)
        set agx_version_file (find  (dirname $in_project)/Source/ThirdParty/agx -name "agx_version.h" 2>/dev/null)
        if test -n "$agx_version_file"
            echo "    AGX Dynamics in plugin:" (get_agx_version "$agx_version_file")
        else
            echo "    AGX Dynamics in plugin: No"
        end
    else
        echo "    Plugin in project: No"
    end


    echo "Engine:"
    echo "    Unreal Engine: $ue_root"
    echo "    Unreal Engine source: $ue_root_source"
    set in_engine (find "$ue_root/Engine/Plugins" -type f -name AGXUnreal.uplugin 2>/dev/null)
    if test -n "$in_engine"
        echo "    Plugin in engine:" (get_agxunreal_version $in_engine)
        set agx_version_file (find  (dirname $in_engine)/Source/ThirdParty/agx -name "agx_version.h" 2>/dev/null)
        if test -n "$agx_version_file"
            echo "    AGX Dynamics in plugin:" (get_agx_version "$agx_version_file")
        else
            echo "    AGX Dynamics in plugin: No"
        end
    else
        echo "    Plugin in engine: No"
    end
end


function generate_project
    check_ue_generate
    # -CMakefile -Makefile
    echo "$ue_generate" "$project_path" -Makefile -Game -Engine
    eval "$ue_generate" "$project_path" -Makefile -Game -Engine
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
    check_ue_build
    echo "$ue_build" Linux DebugGame -Project=(readlink -f *.uproject) -TargetType=Editor
    eval "$ue_build" Linux DebugGame -Project=(readlink -f *.uproject) -TargetType=Editor
end


function open_project
    check_ue_binary
    echo "'$ue_binary'" "'$project_path'" -NoSound
    eval "'$ue_binary'" "'$project_path'" -NoSound

    # Use these if you have a glibc where the DSO sorting optimization
    # has been implemented but not enabled by default.
    # See https://www.gnu.org/software/libc/manual/html_node/Dynamic-Linking-Tunables.html
    #echo env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -NoSound
    #eval env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -NoSound
end


function open_project_debug
    check_ue_binary
    echo "'$ue_binary-Linux-DebugGame'" "'$project_path'" -NoSound
    eval "'$ue_binary-Linux-DebugGame'" "'$project_path'" -NoSound

    # Use these if you have a glibc where the DSO sorting optimization
    # has been implemented but not enabled by default.
    # See https://www.gnu.org/software/libc/manual/html_node/Dynamic-Linking-Tunables.html
    #echo env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary-Linux-DebugGame'" "'$project_path'" -NoSound
    #eval env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary-Linux-DebugGame'" "'$project_path'" -NoSound
end


function opentrace_project
    check_ue_binary
    echo env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -NoSound -tracehost=127.0.0.1 -trace=frame,cpu,gpu
    eval env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -NoSound -tracehost=127.0.0.1 -trace=frame,cpu,gpu
end


function play_project
    check_ue_binary
    echo env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -Game -NoSound -Windowed ResX=1920 ResY=1080
    eval env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -Game -NoSound -Windowed ResX=1920 ResY=1080
end


function playtrace_project
    check_ue_binary
    echo env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -Game -NoSound -Windowed ResX=1920 ResY=1080 -tracehost=127.0.0.1 -trace=frame,cpu,gpu
    eval env GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2 "'$ue_binary'" "'$project_path'" -Game -NoSound -Windowed ResX=1920 ResY=1080 -tracehost=127.0.0.1 -trace=frame,cpu,gpu
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
    if not test -f "$ue_generate"
        echo "Unreal Engine project generator script '$ue_generate' does not exist."
        exit 1
    end
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

function guess_unreal_path_from_uproject
    # Try to find an Unreal Engine installation in
    # $HOME/.config/Epic/UnrealEngine/Install.ini that matches the Engine
    # Association property of the project's .uproject file.
    if test -z "$project_path"
        echo "guess_unreal_path_from_uproject did not get a project path." 1>&2
        echo ""
        return
    end
    set wanted_version (sed -n 's/^.*"EngineAssociation": "\(.*\)".*$/\1/p' "$project_path")
    if test -z "$wanted_version"
        echo "guess_unreal_path_from_uproject could not read Engine Association from $project_path." 1>&2
        echo ""
        return
    end
    # echo "Project requested engine version '$wanted_version'." 1>&2
    set wanted_version (echo $wanted_version | sed 's,\.,\\\\.,g')
    # echo "Install.ini search pattern: '$wanted_version'" 1>&2
    set install_path "$HOME/.config/Epic/UnrealEngine/Install.ini"
    if [ ! -f "$install_path" ]
       echo "Cannot determine Unreal Engine installation directory: $install_path does not exist."
       echo ""
    end
    set engine_line (grep -m1 "$wanted_version" "$install_path")
    # echo "Install.ini contains engine line '$engine_line'." 1>&2
    if test -z "$engine_line"
        # Strip trailing "\.0".
        set wanted_version (string sub --length (expr (string length "$wanted_version") - 3) "$wanted_version")
    end
    # echo "Install.ini search pattern: '$wanted_version'" 1>&2
    set install_path "$HOME/.config/Epic/UnrealEngine/Install.ini"
    set engine_line (grep -m1 "$wanted_version" "$install_path")
    # echo "Install.ini contains engine line '$engine_line'." 1>&2
    if test -z "$engine_line"
        echo "guess_unreal_path_from_uproject did not find an engine installation matching $wanted_version in $install_path." 1>&2
        echo ""
        return
    end
    set engine_path (echo "$engine_line" | cut -d '=' -f2)
    if test -z "$engine_path"
        echo "Did not find an engine path in the engine install entry line '$engine_line'." 1>&2
        echo ""
        return
    end
    echo "$engine_path"
end


# Script execution starts here.

set -x SDL_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR 0

if test -z "$argv[1]" -o  "$argv[1]" = "-h" -o "$argv[1]" = "--help"
    print_usage
end


# Get information about the current project.
if test (count *.uproject) -ne 1
    echo "Error: Directory "(pwd)" does not contain a .uproject file."
    exit 1
end
set project_path (readlink -f *.uproject)
if not test -f "$project_path"
    echo -e "\n\nNo .uproject file found, the project path '"(readlink -f .)"' is not a valid Unreal Engine project."
    exit 1
end
set project_dir (dirname "$project_path")
set project_name (basename "$project_path" .uproject)
set target_name $project_name"Editor"

set ue_root_source ""
if test -f "CMakeLists.txt"
    set ue_root (grep add_custom_target CMakeLists.txt | head -n1 | cut -d '"' -f2)
    set ue_root_source "CMakeLists.txt"
end
if test -n "$UE_ROOT"
    if test -n "$ue_root"
        echo "Warning: ue_root already set by $ue_root_source. Overwritten by "'$UE_ROOT'"."
    end
    set ue_root "$UE_ROOT"
    set ue_root_source "$UE_ROOT"
end
if test "(" "$argv[1]" = "generate" -o "$argv[1]" = "build" -o "$argv[1]" = "open" -o "$argv[1]" = "open-trace" ")" -a -n "$argv[2]"
    if test -n "$ue_root"
        echo "Warning: ue_root already set by $ue_root_source. Overwritten by command line argument."
    end
    set ue_root $argv[2]
    set ue_root_source "command line argument"
end
if test -z "$ue_root" -a -f "$project_path"
    set ue_root (guess_unreal_path_from_uproject)
    set ue_root_source "*.uproject and Install.ini"
end

if test -z "$ue_root"
    echo "Need either a CMakeLists.txt, the UE_ROOT environment variable, or an extra parameter with UE_ROOT know where Unreal Engine is installed."
    exit 1
end

if test -z "$ue_root"
    echo "Unreal Engine root directory isn't known. Either set the UE_ROOT environment variable, pass the path as the first parameter to the 'generate' command, or run from a directory that has a CMakeLists.txt file."
    exit 1
end

if test ! -d "$ue_root"
    echo "$ue_root_source found Unreal Engine root $ue_root, but that directory doesn't exist."
    exit 1
end
set ue_binary $ue_root/Engine/Binaries/Linux/UE4Editor
if test ! -x $ue_binary
    set ue_binary $ue_root/Engine/Binaries/Linux/UnrealEditor
end
set ue_build $ue_root/Engine/Build/BatchFiles/Linux/Build.sh
set ue_generate $ue_root/GenerateProjectFiles.sh
set ue_runuat $ue_root/Engine/Build/BatchFiles/RunUAT.sh

if not type -q "$ue_generate"
    # In installed builds we don't have the project generation script in the engine root.
    set ue_generate $ue_root/Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh
end


switch $argv[1]
    case info
        show_info
    case generate
        generate_project $argv[2]
    case build
        build_project
    case open
        open_project
    case buildopen
         build_project && \
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
