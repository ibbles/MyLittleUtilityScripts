#!/bin/bash

df -lh | grep -e Filesystem -e /dev/nv -e /dev/sd --color=never | awk 'NR<2{print $0;next}{print $0| "sort -rhk 2"}'
