#!/usr/bin/env fish

emacs --eval "(progn (magit-status) (delete-other-windows))" & disown
