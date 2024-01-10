#!/bin/bash

echo "" > /tmp/mn.print_args.out
while [ "$1" != "" ] ; do
    echo "'$1'"
    echo "'$1'" >> /tmp/mn.print_args.out
    shift
done
