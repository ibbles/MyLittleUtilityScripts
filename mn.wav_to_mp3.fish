#!/usr/bin/fish

# Script that converts .wav files to .mp3 files.
# Optionally adds a suffix to the end of the name, right before '.mp3'.

set usage "Usage: mn.wav_to_mp3.fish INPUT_FILE [OUTPUT_FILE_SUFFIX]"

function fail
    echo "Error: $argv[1]" 1>&2
    echo $usage
    exit 1
end

# Parse input file argument.
set in_file $argv[1]
if test -z "$in_file"
    fail "No file to convert given."
end
if test ! -f "$in_file"
    fail "File '$in_file' does not exist."
end

# Parse optional output file argument.
set suffix $argv[2]

# Build output file name.
set out_file (string replace --regex "\.wav\$" "$suffix.mp3" "$in_file")
# No check for existing file, we assume ffmpeg will ask for confirmation if the
# output file already exists.

# Do the conversion.
ffmpeg -i "$in_file" -acodec mp3 -ab 96k "$out_file"
