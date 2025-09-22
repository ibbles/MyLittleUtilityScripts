#!/usr/bin/env bash

pidstat -u -p ALL 1 2 \
    | awk '$3 ~ /^[0-9]+$/ && $8 != "%CPU" { if ($8+0 > max) { max=$8+0; pid=$3; cmd=$10 } }
           END { if (pid) printf "%s %.1f%%\n", cmd, max }'
