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

if not openssl enc -aes-256-cbc -pbkdf2 -d -in "$in_file"
    echo "Decrypt failed." 2>&1
    exit 1
end
