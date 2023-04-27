#!/usr/bin/fish

set pattern $argv[1]
echo "argv[1]: '$argv[1]'."

if test -z "$pattern"
    echo "Usage: $argv[1] PATTERN"
    echo "Where pattern is e.g '*.jpg'."
    echo "Take care to have the pattern being passed and not expanded by the shell."
    exit 1
end

if test -f output.mp4
    echo "Output file already exitst."
    exit 1
end

ffmpeg -framerate 30 -pattern_type glob -i $pattern -c:v libx264 -r 30 -pix_fmt yuv420p output.mp4
