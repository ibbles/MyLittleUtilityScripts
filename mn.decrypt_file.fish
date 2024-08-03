#!/usr/bin/fish

# Check command line arguments.
if test (count $argv) -ne 1
    echo "Wrong number of arguments." 1>&2
    exit 1
end

# Determine and verify input file.
set in_file $argv[1]
if not string match "*.enc" "$in_file"
    echo "Input file '$in_file' does not end with '.enc'" 1>&2
    exit 1
end
if not test -f "$in_file"
    echo "Input file '$in_file' does not exists." 1>&2
    exit 1
end

# Determine and verify output file.
set out_file (string sub --start 1 --length (expr (string length "$in_file") "-" "4") "$in_file")
if test -f "$out_file"
    echo "Outpuf file '$out_file' already exists." 1>&2
    exit 1
end

openssl enc -aes-256-cbc -pbkdf2 -d -in "$in_file" -out "$out_file"

