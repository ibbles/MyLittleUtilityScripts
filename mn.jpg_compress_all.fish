#!/usr/bin/env fish

set should_exit false

if ! command -q convert
    echo >&2 "'convert' now available, often part of the 'imagemagick' package."
    set should_exit true
end

if test -d compressed
    echo >&2 "Work directory 'compressed' already exists. Not doing anything."
    set should_exit true
end

if test -d original
    echo >&2 "Work directory 'original' already exists. Doing nothing."
    set should_exit true
end

if test "$should_exit" = true
    exit 1
end


set files *.jpg
set num_files (count $files)


set to_line_start (echo -e '\r')
set fill_char " "
set width $COLUMNS
set clear_prompt $to_line_start(string repeat -n $width $fill_char)$to_line_start


mkdir compressed original
echo "Num files: $num_files"set counter 0
for jpg in $files
    set counter (math $counter + 1)
    echo -n $clear_prompt
    echo -n "Compressing '$jpg' ($counter / $num_files)."
    convert "$jpg" -quality 70% "compressed/$jpg"
    mv "$jpg" "original/$jpg"
end

echo
echo "Original images are in 'original/'."
echo "Compressed images are in 'compressed'."

