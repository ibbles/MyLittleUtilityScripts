#!/bin/bash

# Print a message to stderr.
function log {
	echo $@ >&2
}

# Print an error message to stderr and then exit.
function bail {
	log "Error: $1"
	exit 1
}

function ensure_spotify_closed {
    # Can't switch profile while Spotify is running.  If it is, then try to close
    # it.
    if pidof "spotify" >/dev/null ; then
        log "Spotify is running, closing it."
        if command -v pkill >/dev/null ; then
            pkill --exact -15 spotify
        fi
        # Give spotify a few seconds to shut down."
        for i in $(seq 5) ; do
            if ! pidof "spotify" >/dev/null ; then
                break;
            fi
            sleep 1
        done
        if pidof "spotify" >/dev/null ; then
            bail "Spotify running, can't switch profile."
        fi
    fi
}


ensure_spotify_closed

# Make sure we don't try to switch profile while Spotify is running.
if pidof "spotify" > /dev/null ; then
    bail "Spotify is running, can't swith profile."
fi

# The directory that Spotify store the current profile in. The goal of
# this script is to place a symlink here pointing to the actual profile
# directory. The actual profile directory is created by starting Spotify
# without a base_dir, logging in, configuring all the in-app settings,
# and then exiting Spotify. This will create base_dir with all those
# settings. Rename that directory to spotify_PROFILE where PROFILE is
# the name of that profile.
snap_dir="$HOME/snap/spotify"
if [ -d "$snap_dir" ] ; then
    base_dir="${snap_dir}/current/.config/spotify"
else
    base_dir="$HOME/.config/spotify"
fi

# Generate a list of available profiles.
profiles=()
for profile_dir in `ls -d -1 "${base_dir}_"*` ; do
	profile_dir=`basename "${profile_dir}"`
	name=${profile_dir##spotify_}
	profiles+=("$name")
done

#echo "Got these profiles:"
#mn.print_args.bash ${profiles[@]}

# Make sure the current profile is a symlink.
if [ ! -h "${base_dir}" ] ; then
    bail "Base directory '${base_dir}' is a directory and not a symlink."
fi

# Find the name of the current profile.
link_target=$(readlink -f "${base_dir}")
link_name=$(basename "${link_target}")
current_profile=${link_name##spotify_}
#log "Current profile: ${current_profile}."


# Find the index of the current profile.
current_index=-1
for i in "${!profiles[@]}" ; do
    if [[ "${profiles[$i]}" == "${current_profile}" ]]; then
        current_index=$i
        break
    fi
done

# Check if the current profile was found
if [[ $current_index -eq -1 ]] ; then
    bail "Current profile not found in the array."
fi

# Calculate the index of the next profile.
next_index=$(( (current_index + 1) % ${#profiles[@]} ))

# Set the next_profile variable
next_profile="${profiles[$next_index]}"

#log "Next profile: $next_profile"
mn.spotify_profile.bash "${next_profile}"
