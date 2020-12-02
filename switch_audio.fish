#!/usr/bin/env fish

# Arguments: A list of output device indices to loop through.
#
# You can use
#   pactl list short sinks
# to list the devices available.

# This script does set intersection between the awailable set and the loop set
# to form a candidate set and then round-robin looping through the candidate
# set per invocation.
#
# How we control Pulse Audio:
#
# List all available:
#   pactl list short sinks
# Output format:
#   INDEX NAME MODULE SAMPLE_TYPE CHANNELS FREQ STATE
# STATE is RUNNING for the currently selected device.
# TODO: No it's not. It's RUNNING for devices playing audio
# See separate TODO below.
#
# Set a new default device:
#   pacmd set-default-sink INDEX
#



# The loop set is user-provided.
set loop_set $argv

# Get the awailable set and the currently selected device.
#
# TODO: grep for RUNNING is not the proper way to get the current default, it
# will select all devices that is currently playing audio regardless of if it's
# the default or not. Use `pacmd list-sinks` instead. The default
# See separate TODO above.
set awailable_set (pactl list short sinks | awk '{print $1}')
set current (pactl list short sinks | grep "RUNNING" | awk '{print $1}')

if test -z "$current"
   set current $awailable_set[1]
end

# Find the intersection between the loop set and the awailable set to form the
# candidate set.
set candidate_set
for device in $awailable_set
    if contains $device $loop_set
       set -a candidate_set $device
    end
end


echo "Current: '$current'."
for device in $candidate_set
    if test "$device" = "$current"
        echo -n ">"
    else
        echo -n " "
    end

    echo $device
end

# Round-robin through the candidate set.
# TODO: There must be a better way to do this.
set take_it 0 # Set when we find current, meaning that the next should be used.
set took_it 0 # Set when there was a next, must loop otherwise.
for device in $candidate_set
    if test "$take_it" = 1
       # $device is the next output to use.
       set took_it 1
       break
    end

    if test $device = $current
       # The device that we find in the next iteration is the one to use.
       set take_it 1
    end
end

# If there was no next iteration after finding current, or if current wasn't
# in the candidate set, then pick the first device.
if test $took_it = 0
   set device $candidate_set[1]
end

if test -z "$device"
    echo "Did not find a next device. Doing nothing." >&2
    exit 1
end

echo "Swith to $device"
pacmd set-default-sink $device
