#!/usr/bin/fish


if test (count $argv) -eq 0
    set name "Screenshot"
else if test (count $argv) -eq 1
    set name $argv[1]
else
    echo "Too many arguments."
    echo "Usage: "(basename (status -f))" [NAME]"
    exit 1
end

echo "Name: $name"

while true
    sleep 1
    spectacle -abno ~/{$name}"_"(date "+%Y%m%d_%H%M%S")".png"
end
