#!/usr/bin/fish

# Usage: There are no arguments, just run the script standing in the folder
# with the .png files.

function wait_continue
    read -P "Press Enter to continue." line
end

function ask_confirm
    read -P "Continue? [y/n]: " line
    if test "$line" != "y"
        echo "Doing nothing."
        exit 2
    end
end

if test (count $argv) -ge 1
    echo "This script takes no  arguments." 2>&1
    exit 1
end

echo "This script converts PNG files to JPG files and the removes the PNG files."
echo "There are no arguments to this script, it converts all PNGs in the current directory."
echo "Do not create any new images in the current directory while this script is running."
echo "The current directory is "(pwd)"."
ask_confirm

echo "  Checking if any PNG file already have JPG file."
echo "  Any file listed is an existing JPG for a PNG."
echo "  Consider renaming either file,"
echo "  or moving the JPG somewhere else."
echo "  Or delete the PNG if the JPG is good enough."
wait_continue
for f in (find . -iname "*.png")
    ll (dirname "$f")/(basename "$f" .png).jpg 2>/dev/null
end
ask_confirm

echo "  Sanity-check for the conversion."
echo "  Look for output that seem weird."
wait_continue
for f in (find . -iname "*.png")
    set new_f (dirname "$f")/(basename "$f" .png).jpg
    echo "$f -> $new_f"
end
ask_confirm

echo "  Do the conversion."
echo "  Beware of any error output."
echo "  Should not delete all PNG files if there are any errors."
echo "  Find some other way to convert those files,"
echo "  For example using Krita."
echo "  If there are any warnings then compare the PNG file and the JPG file in an image viewer,"
echo "  if they look the same then it's probably fine."
ask_confirm
for f in (find . -iname "*.png")
    set new_f (dirname "$f")/(basename "$f" .png).jpg
    convert "$f" "$new_f"
end

echo "  Check that all PNGs have a corresponding JPG."
echo "  You should be no output from this."
wait_continue
for f in (find . -iname "*.png")
    ll (dirname "$f")/(basename "$f" .png).jpg >/dev/null
end


echo "  You may inspect individual image files here,"
echo "  to ensure the JPGs looks alright."
wait_continue

echo "  About to remove all PNG files."
echo "  Only continue if you are really sure."
ask_confirm
for f in (find . -iname "*.png")
    rm -f "$f"
end
