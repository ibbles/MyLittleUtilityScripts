#!/usr/bin/env bash

while true ; do
    if host www.dn.se > /dev/null ; then
        echo "Connected!"
    else
        echo "No internet!"
    fi
    sleep 60
done
