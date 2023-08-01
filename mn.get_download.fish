#!/usr/bin/fish

ls -d -t ~/Downloads/* | head -n 1
mv (ls -d -t ~/Downloads/* | head -n 1) .
