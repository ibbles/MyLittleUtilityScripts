#!/usr/bin/fish

if test (count $argv) -ne 1
	echo "Can only delete one directory at a time."
	exit 1
end

set directory "$argv[1]"
set directory_path (realpath "$directory")

if test ! -d "$directory_path"
	echo "$directory_path is not a directory."
	exit 1
end

read -P "Remove directory '$directory_path'? [y/n] " reply
if test "$reply" != "y"
	echo "Not removing"
	exit 1
end

# Cannot remove write-protected files, so un-write-protect them.
chmod +w -R "$directory_path"
if test $status -ne 0
	echo "Failed to change permissions."
	exit 1
end

command rm -r "$directory_path"
