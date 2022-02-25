#!/usr/bin/env fish

while true
    set file (inotifywait -qe close_write (find . -iname "*.py") | cut -d ' ' -f 1)
    echo -e "\n\nFormatting $file."
    black "$file"
    flake8 "$file" --ignore=E501
    sleep 1
end
