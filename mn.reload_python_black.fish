#!/usr/bin/env fish


set do_exit false
if not type -q black
    echo "Black is not installed. Install with" >&2
    echo "  <Figure out how to detect the Python binary currently executing, then print:>" >&2
    echo "       $PATH_TO_PYTHON -m pip install -U black" >&2
    echo "  pip3 install black" >&2
    set do_exit true
end

if not type -q flake8
    echo "Flake8 is not installed. Install with" >&2
    echo "  sudo apt install flake8" >&2
    set do_exit true
end

if not type -q inotifywait
    echo "inotifywait is not installed. Install with" >&2
    echo "  sudo apt install inotify-tools" >&2
    set do_exit true
end

if test "$do_exit" = "true"
    exit 1
end

argparse --name=mn.reload_python_black 'h/help' 'noformat' 'linelength=' -- $argv
or exit 1

if test -n "$_flag_help"
   echo "Usage:"
   echo "mn.reload_python_black.fish --linelength=100"
   exit 0
end

set linelength 88
if test -n "$_flag_linelength"
   echo "Line length: $_flag_linelength"
end

while true
    set file (inotifywait -e close_write,move_self (find . -iname "*.py" -or -iname "*.agxPy") | cut -d ' ' -f 1)
    echo "Woke for file '$file'."
    if test -z "$file"
        continue
    end

    if test -z "$_flag_noformat"
        echo -e "\n\n\n\nFormatting $file."
        black "$file" --preview
    end

    # E203: Whitespace before ':'.
    # https://github.com/psf/black/issues/315
    # W503: Line break efter binary operator.
    # https://www.python.org/dev/peps/pep-0008/#should-a-line-break-before-or-after-a-binary-operator
    flake8 "$file" --ignore=E203,W503 --max-line-length=$_flag_linelength
    sleep 1
end
