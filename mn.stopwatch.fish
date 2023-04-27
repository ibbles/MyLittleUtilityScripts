#!/usr/bin/fish

set start (date +%s)
set home (string repeat -n 16 '\b')
set clear_line (string repeat -n 16 ' ')

function duration_str
    #echo "0: $0"
    #echo "1: $1"
    #echo "argv: $argv[1]"
    set remaining $argv[1]
    #echo "remaining $remaining"

    set seconds (math $remaining % 60)  # Seconds that don't make a full minute.
    set remaining (math $remaining - $seconds)  # Seconds remaining of the total time.
    set remaining (math $remaining / 60)  # Convert seconds to minutes.

    set minutes (math $remaining % 60)  # Minutes that don't make a full hour.
    set remaining (math $remaining - $minutes)  # Minutes remaining of the total time.
    set remaining (math $remaining / 60)  # Convert minutes to hours.

    set hours (math $remaining % 24)  # Hours that don't make a full day.
    set remaining (math $remaining - $hours)  # Hours remaining of the total time.
    set remaining (math $remaining / 24)  # Convert hours to days.

    set days $remaining

    echo "$days d. $hours:$minutes:$seconds"
end

while true
    set now (date +%s)
    set elapsed (math $now - $start)
    #echo "Elapsed: $elapsed"
    echo -ne $home $clear_line $home
    echo -n (duration_str $elapsed)
    sleep 1
end

