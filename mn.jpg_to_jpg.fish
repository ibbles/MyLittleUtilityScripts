#!/usr/bin/env fish

set file $argv[1]


if test -z "$file"
    echo "No source file given." >&2
    exit 1
end

if test ! -f "$file"
    echo "Source file $file is not a file." >&2
    exit 1
end

set suffix (string sub --start -4 "$file")
if test "$suffix" != ".jpg"
    echo "Source file $file is not a .jpg" >&2
    exit 1
end

set name (basename "$file" .jpg)
echo "Name: $name"

# 50%: Visible artifacts, changing colors.
# 70%: Mostly fine, arifacts in high-contrast sharp edges.
convert "$file" -quality 70% "$name"_70_".jpg"
#convert "$file" -quality "$q"% "$name"_"$q"_".jpg"

#for q in 10 20 30 40 50 60 70 80 90 100
#    convert "$file" -quality "$q"% "$name"_"$q"_".jpg"
#end
