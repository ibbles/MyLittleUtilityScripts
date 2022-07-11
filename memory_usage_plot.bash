#!/usr/bin/env bash

pid=$1
if [ -z "$pid" ] ; then
	echo "Did not get a pid." 1>&2
	echo "Usage: $0 PID" 1>&2
	exit 1
fi


file="memory_usage.dat"
if [ -e "$file" ] ; then
	echo "Error: Output file $file already exists."
	exit 1
fi

time_start=$(date +%s)

echo "Duration,Clock,Time Stamp,RAM MiB,VRAM MiB" > "$file"
while true ; do
	time_now=$(date +%s)
	duration=$(expr $time_now - $time_start)
        clock=$(date +%H:%M:%S)
	mem_usage_k=$(ps v $pid | tail -n 1 | awk '{print $8}')
	mem_usage_m=$(expr $mem_usage_k / 1024 )
	vmem_usage_m=$(nvidia-smi -q | grep "FB Memory Usage" -A3 | grep Used | awk '{print $3}')
	echo "$duration,$clock,$time_now,$mem_usage_m,$vmem_usage_m" >> "$file"
	sleep 10
done
