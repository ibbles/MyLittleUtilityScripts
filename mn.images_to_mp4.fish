#!/usr/bin/fish

set usage "$argv[1] PATTERN [FRAMERATE]"

set pattern $argv[1]
if test -z "$pattern"
    echo "Usage: $usage"
    echo "Where pattern is e.g '*.jpg'."
    echo "Take care to have the pattern being passed and not expanded by the shell."
    exit 1
end

set framerate $argv[2]
if test -z "$framerate"
    set framerate 30
end

set output "output.mp4"
if test -f "$output"
    echo "Output file $output already exitst."
    exit 1
end

set fish_trace 1
ffmpeg -framerate "$framerate" -pattern_type glob -i $pattern -c:v libx264 -r "$framerate" -pix_fmt yuv420p "$output"
