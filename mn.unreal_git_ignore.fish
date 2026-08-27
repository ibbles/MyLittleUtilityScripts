#!/usr/bin/env fish

function add
    set pattern $argv[1]
    if ! grep -q "$pattern" .gitignore
        echo "$pattern" >> .gitignore
        echo "Added '$pattern'."
    end
end

add Binaries
add DerivedDataCache
add Intermediate
add Saved
add Makefile

