#!/usr/bin/env fish


while true
    set used (nvidia-smi --query --display=MEMORY | grep "FB Memory Usage" -A3 | grep "Used" | tr -s ' ' | cut -d ' ' -f 4)
    set xorg (nvidia-smi | grep Xorg | awk '{print $8}' | cut -d 'M' -f1)
    #set timestamp (date "+%Y-%m-%dT%H:%M:%S")
    set timestamp (date "+%s")
    echo $timestamp $used $xorg >> /tmp/VRAM_usage.dat
    sleep 60
end
