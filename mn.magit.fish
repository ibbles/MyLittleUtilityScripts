#!/usr/bin/env fish

set common_args $argv --eval "(progn (magit-status) (delete-other-windows))"
if contains -- "-nw" $argv
    emacs $common_args
else
    emacs $common_args & disown
end
