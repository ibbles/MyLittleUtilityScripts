#!/usr/bin/fish


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
echo "  If there are any warnings that compare the PNG file and the JPG file,"
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

echo "  Remove the PNG files."
echo "  Only continue if you are really sure."
ask_confirm
for f in (find . -iname "*.png")
    rm -f "$f"
end


echo "Moving on."