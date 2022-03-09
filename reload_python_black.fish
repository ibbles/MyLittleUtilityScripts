#!/usr/bin/env fish

if not type -q black
    echo "Black is not installed. Install with" >&2
    echo "  pip3 install black"
    exit 1
end

while true
    set file (inotifywait -qe close_write (find . -iname "*.py") | cut -d ' ' -f 1)
    if test -z "$file"
        continue
    end
    echo -e "\n\n\n\nFormatting $file."
    black "$file" --preview

    # E203: Whitespace before ':'.
    # https://github.com/psf/black/issues/315
    # W503: Line break efter binary operator.
    # https://www.python.org/dev/peps/pep-0008/#should-a-line-break-before-or-after-a-binary-operator
    flake8 "$file" --ignore=E203,W503 --max-line-length=88
    sleep 1
end
