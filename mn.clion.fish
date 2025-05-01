#!/usr/bin/env fish

set num_matches (count ~/bin/clion/clion-*)
if test "$num_matches" -ne "1"
    echo "Found multiple (or no) CLion installations, don't know which one to launch." 1>&2
    ll -d ~/bin/clion/clion-*
    exit 1
end

set clion_dir ~/bin/clion/clion-*/bin

# With CLion 2024.3, or there about, the recommended entry point for CLion was
# changed from being a script to being a binary. Let's try it for a while.
if test -f "$clion_dir/clion"
   set clion_binary "$clion_dir/clion"
else
   set clion_binary "$clion_dir/clion.sh"
end

if test (count $argv) -eq 0
    echo "$clion_binary" (readlink -f .)
    "$clion_binary" (readlink -f .) >/dev/null 2>&1 &
else
    echo "$clion_binary" $argv
    "$clion_binary" $argv >/dev/null 2>&1 &
end
