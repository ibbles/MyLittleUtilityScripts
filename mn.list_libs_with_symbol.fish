#!/usr/bin/env fish

# Script that loops over all static and dynamic libraries in the current
# directory and searches them for a user-provided symbol name.
#
# Usage:
#  mn.list_libs_with_symbol.fish SYMBOL
#
# SYMBOL is a patterm passed to 'grep'.
#
# Example:
#  mn.list_libs_with_symbol.fish "vtable for MyClass\$"

if test (count $argv) -ne 1
   echo "Wrong number of arguments."
   exit 1
end

set symbol $argv[1]
if test -z "$symbol"
   echo "No symbol name given."
   exit 1
end

for lib in *.so* *.a
    # TODO Is there a way to do this that doesn't require two calls to 'nm -C'?
    # Buffer output in a temporary file?
    if nm -C "$lib" 2>/dev/null | grep -q "$symbol"
        echo "$lib"
        nm -C "$lib" | grep "$symbol"
    end
end
