#!/usr/bin/fish

# Check command line arguments.
if test (count $argv) -ne 1
    echo "Wrong number of arguments, doing nothing." 1>&2
    exit 1
end

# Determine and verify input file.
set in_file $argv[1]
if not string match -q "*.enc" "$in_file"
    echo "Input file '$in_file' does not end with '.enc', doing nothing." 1>&2
    exit 1
end
if not test -f "$in_file"
    echo "Input file '$in_file' does not exists, doing no thing." 1>&2
    exit 1
end

# Determine and verify output file.
set out_file (string sub --start 1 --length (expr (string length "$in_file") "-" "4") "$in_file")
if test -f "$out_file"
    set out_file_collision "$out_file"
    set out_file "$out_file"".dec"
    echo -e "Output file '$out_file_collision'     already exists,\nusing       '$out_file' instead." 1>&2
end
if test -f "$out_file"
    echo "Outpuf file '$out_file' already exists, doing nothing." 1>&2
    exit 1
end

if not openssl enc -aes-256-cbc -pbkdf2 -d -in "$in_file" -out "$out_file"
    echo "Decrypt failed." 2>&1
    exit 1
end

if not test -f "$out_file"
    echo "Could not create output file '$out_file'." 1>&2
    exit 1
end

