#!/usr/bin/env fish

set file "$HOME/VRAM_usage.dat"

if test -f "$file"
   # echo "File already exists, not writing header."
else
   # echo "File created, writing header."
   echo "Time Total XOrg" > "$file"
end

while true
    set used (nvidia-smi --query --display=MEMORY | grep "FB Memory Usage" -A3 | grep "Used" | tr -s ' ' | cut -d ' ' -f 4)
    set xorg (nvidia-smi | grep Xorg | awk '{print $8}' | cut -d 'M' -f1)
    #set timestamp (date "+%Y-%m-%dT%H:%M:%S")
    set timestamp (date "+%s")
    echo $timestamp $used $xorg >> "$file"
    sleep 600
end
