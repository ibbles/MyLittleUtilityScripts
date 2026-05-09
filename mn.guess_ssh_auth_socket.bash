#!/usr/bin/env bash
# Prints a shell assignment for SSH_AUTH_SOCK pointing to a working agent socket.
# Intended to be eval'd, not sourced:
#
#   Bash/Zsh:  eval "$(guess_ssh_auth_sock)"
#   Fish:      eval (guess_ssh_auth_sock --fish)
#
# Shell syntax is selected by --fish / --sh flag, or auto-detected via
# $FISH_VERSION (exported by Fish into child processes).

_shell=sh
case "$1" in
    --fish) _shell=fish ;;
    --sh)   _shell=sh   ;;
    "")     [[ -n "$FISH_VERSION" ]] && _shell=fish ;;
    *)      echo "usage: guess_ssh_auth_sock [--sh | --fish]" >&2; exit 1 ;;
esac

_emit() {
    if [[ "$_shell" == fish ]]; then
        echo "set -gx SSH_AUTH_SOCK $1"
    else
        echo "export SSH_AUTH_SOCK=$1"
    fi
}

# If the inherited value already works, re-emit it unchanged.
if [[ -n "$SSH_AUTH_SOCK" ]] && ssh-add -l &>/dev/null; then
    _emit "$SSH_AUTH_SOCK"
    exit 0
fi

_candidates=()

while IFS= read -r _c; do
    _candidates+=("$_c")
done < <(find /tmp /run/user 2>/dev/null \
              -maxdepth 4 \
              \( -name 'agent.*' -o -name 'S.ssh' -o -name 'openssh_agent' -o -name 'ssh' \) \
              -type s \
              2>/dev/null \
         | sort -t. -k2 -rn)

# Fallback: mine SSH_AUTH_SOCK out of other processes' environments.
if [[ ${#_candidates[@]} -eq 0 ]]; then
    # Strategy 1: walk the parent-process chain looking for sshd.  The sshd
    # process managing this connection holds the exact forwarded-agent socket.
    _pid=$$
    while [[ "$_pid" -gt 1 ]]; do
        _cmdline=$(tr '\0' ' ' < "/proc/$_pid/cmdline" 2>/dev/null)
        if [[ "$_cmdline" == sshd* ]]; then
            _c=$(grep -oP '(?<=SSH_AUTH_SOCK=)[^\0]+' \
                 "/proc/$_pid/environ" 2>/dev/null | head -1)
            if [[ -n "$_c" ]]; then
                _candidates+=("$_c")
                break
            fi
        fi
        _pid=$(awk '{print $4}' "/proc/$_pid/stat" 2>/dev/null)
    done

    # Strategy 2: pick the most-used socket value across all processes.
    # The socket inherited by the most processes is the session's primary
    # agent (e.g. GNOME Keyring with ~100 inheritors vs. niche alternatives
    # with only a handful).
    if [[ ${#_candidates[@]} -eq 0 ]]; then
        _c=$(
            find /proc -maxdepth 2 -name environ -readable 2>/dev/null \
            | xargs -I{} sh -c 'tr "\0" "\n" < "$1" 2>/dev/null' -- {} \
            | grep -oP '(?<=SSH_AUTH_SOCK=)\S+' \
            | sort | uniq -c | sort -rn \
            | awk 'NR==1 {print $2}'
        )
        [[ -n "$_c" ]] && _candidates+=("$_c")
    fi
fi

for _c in "${_candidates[@]}"; do
    if SSH_AUTH_SOCK="$_c" ssh-add -l &>/dev/null; then
        _emit "$_c"
        exit 0
    fi
done

echo "guess_ssh_auth_sock: no working SSH agent socket found" >&2
exit 1
