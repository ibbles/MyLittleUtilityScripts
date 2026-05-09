# Source this file to locate a working SSH agent socket and set SSH_AUTH_SOCK.
# Useful when reconnecting to an existing shell (e.g. tmux/screen) where the
# original socket path has gone stale.

# If the current value already works, do nothing.
if [[ -n "$SSH_AUTH_SOCK" ]] && ssh-add -l &>/dev/null; then
    return 0
fi

_candidates=()

while IFS= read -r _candidate; do
    _candidates+=("$_candidate")
done < <(find /tmp /run/user 2>/dev/null \
              -maxdepth 4 \
              \( -name 'agent.*' -o -name 'S.ssh' -o -name 'openssh_agent' -o -name 'ssh' \) \
              -type s \
              2>/dev/null \
         | sort -t. -k2 -rn)   # newest PID last → try highest PIDs first

# Fallback: mine SSH_AUTH_SOCK out of other processes' environments.
if [[ ${#_candidates[@]} -eq 0 ]]; then
    # Strategy 1: walk the parent-process chain looking for sshd.  The sshd
    # process managing this connection holds the exact forwarded-agent socket.
    _pid=$$
    while [[ "$_pid" -gt 1 ]]; do
        _cmdline=$(tr '\0' ' ' < "/proc/$_pid/cmdline" 2>/dev/null)
        if [[ "$_cmdline" == sshd* ]]; then
            _candidate=$(grep -oP '(?<=SSH_AUTH_SOCK=)[^\0]+' \
                         "/proc/$_pid/environ" 2>/dev/null | head -1)
            if [[ -n "$_candidate" ]]; then
                _candidates+=("$_candidate")
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
        _candidate=$(
            find /proc -maxdepth 2 -name environ -readable 2>/dev/null \
            | xargs -I{} sh -c 'tr "\0" "\n" < "$1" 2>/dev/null' -- {} \
            | grep -oP '(?<=SSH_AUTH_SOCK=)\S+' \
            | sort | uniq -c | sort -rn \
            | awk 'NR==1 {print $2}'
        )
        [[ -n "$_candidate" ]] && _candidates+=("$_candidate")
    fi
fi

_found=""
for _candidate in "${_candidates[@]}"; do
    if SSH_AUTH_SOCK="$_candidate" ssh-add -l &>/dev/null; then
        _found="$_candidate"
        break
    fi
done

if [[ -n "$_found" ]]; then
    export SSH_AUTH_SOCK="$_found"
    echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
else
    echo "guess_ssh_auth_sock: no working SSH agent socket found" >&2
fi

unset _candidates _candidate _cmdline _pid _found
