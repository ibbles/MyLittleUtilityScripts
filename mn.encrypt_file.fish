#!/usr/bin/fish

if test (count $argv) -ne 1
    echo "Wrong number of arguments."
    exit 1
end

set in_file $argv[1]
set out_file "$in_file"".enc"

if not test -f "$in_file"
    echo "Input file '$in_file' does not exists."
    exit 1
end

if test -f "$out_file"
    echo "Outpuf file '$out_file' already exists."
    exit 1
end

if not openssl enc -aes-256-cbc -pbkdf2 -e -in "$in_file" -out "$out_file"
    echo "Encrypt failed." 2>&1
    exit 1
end

if not test -f "$out_file"
    echo "Could not create output file '$out_file'." 1>&2
    exit 1
end

chmod --reference="$in_file" "$out_file"
