#!/usr/env fish

while true
    sleep 1
    inotifywait .clang-format
    if ! g++ *.cpp -o main.exe
        notify-send "Compilation failed"
    else
        set failure "false"
        for f in (find \( -iname "*.h" -or -iname "*.cpp" \) )
            if ! clang-format -style=file -i "$f"
                set failure "true"
            end
        end
        if test "$failure" = "true"
            notify-send "Formatting failed."
        else
            notify-send "Formatting done."
        end
    end
end
