#!/usr/bin/env fish


while true
    set used (nvidia-smi --query --display=MEMORY | grep "FB Memory Usage" -A3 | grep "Used" | tr -s ' ' | cut -d ' ' -f 4)
    set timestamp (date -Iseconds)
    echo $timestamp $used >> /tmp/VRAM_usage.dat
    sleep 10
end
