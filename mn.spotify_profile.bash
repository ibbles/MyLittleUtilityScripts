#!/bin/bash

# Spotify Profile - A profile switcher for Spotify.
#
# Spotify stores profile information in $HOME/.config/spotify or
# $HOME/snap/spotify/current/.config/spotify. ('current is a symlink pointing to
# another sibling directory. Sometimes 67, sometimes 68.) This directory is
# created whenever Spotify is launched. By replacing this directory with a
# symlink we can redirect that symlink to switch between profiles.
#
# In the following text the $HOME/.config/spotify or
# $HOME/snap/spotify/current/.config/spotify directory is called PROFILE_HOME.
#
# Make sure Spotify is closed before running this script or making any
# manual changes to PROFILE_HOME.
#
# To create a profile from the current session rename
#   PROFILE_HOME
# to
#   PROFILE_HOME_PROFILE
# where PROFILE is the name you want to give the profile.
#
# For example:
#  $ mv $HOME/.config/spotify $HOME/.config/spotify_HeavyMetal
#  $ mv $HOME/snap/spotify/current/.config/spotify $HOME/snap/spotify/current/.config/spotify_HeavyMetal
#
# A suggestion is to name it whatever is stored in the autologin.username
# attribute in the SPOTIFY_HOME/prefs file, though sometimes that's some hash
# string instead of the actual user name.
#
# Then launch Spotify again to configure your second profile, close
# Spotify, and rename the folder to whatever you want that profile to be
# named, according to the instructions above. Repeat for as many
# profiles as you wish.
#
# To activate a profile make sure Spotify is closed and run this script with the
# profile name, i.e., the PROFILE part of the directory name, as its sole
# argument.
#
# For example:
#  $ spotify_profile.bash HeavyMetal
#
# to switch to the profile stored in $HOME/.config/spotify_HeavyMetal or
# $HOME/snap/spotify/current/.config/spotify_HeavyMetal.
#
# If you have 'dialog' installed then you can run this script with no arguments
# and a list of available profiles will be presented.



# Print a message to stderr.
function log {
	echo $@ >&2
}

# Print an error message to stderr and then exit.
function bail {
	log "Error: $1"
	exit 1
}

# Print a message to stderr and then exit.
function stop {
	log $1
	exit 1
}

function log_profiles {
	log "Available profiles:"
	for dir in `ls -d -1 "${base_dir}_"*` ; do
		dir=`basename "${dir}"`
		name=${dir##spotify_}
		log "  ${name}"
	done
}

# Spotify must not be running when switching profile.
if pidof "spotify" > /dev/null 2>&1 ; then
    stop "Close Spotify before switching profile."
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

# The profile to switch to. First we try to read it from the next command line
# parameter.
profile=$1

# Check if we got a profile from the command line.
if [ -z "${profile}" ] && command -v dialog ; then
	# We did not, but we have the 'dialog' command so we can ask the
	# user for a profile interactively.

	# Generate a list of available profiles.
	profiles=()
	for profile_dir in `ls -d -1 "${base_dir}_"*` ; do
		profile_dir=`basename "${profile_dir}"`
		name=${profile_dir##spotify_}
		profiles+=("$name")
	done

	# Build menu items from the profile list.
	menu_items=()
	for i in "${!profiles[@]}" ; do
		# 'dialog' takes an (id, label) pair for each menu entry. Here the id is
		# the index in the profiles array and the label is the name of the
		# profile.
		menu_items+=($i)
		menu_items+=(${profiles[$i]})
	done

	# Display the menu to the user.
	choice=$(dialog --menu "Select a profile." 30 50 30 \
		${menu_items[@]} 2>&1 >/dev/tty)
	clear
	if [ $? -ne 0 ] ; then
		bail "Selection aborted, doing nothing."
	fi

	# Read the profile selection.
	profile=${profiles[$choice]}
fi

# By this point we should have a profile. If not, print usage and exit.
if [ -z "${profile}" ] ; then
	log "Usage: $0 PROFILE"
	log_profiles
	exit 1
fi

# Ensure that the wanted profile exists.
if [ ! -d "${base_dir}_${profile}" ] ; then
	log "No profile named '${profile}'."
	log_profiles
	exit 1
fi

# Make sure the base directory isn't a real directory. If it is then
# we can't create our symlink. Must check for symlink explicitly because
# -d treats a symlink to a directory as a directory.
if [ -d "${base_dir}" ] && [ ! -h "${base_dir}" ] ; then
	bail "Base directory '${base_dir}' is a directory and not a symlink."
fi

# Check if the base directory already is a symlink. If so, remove it.
# Unless it's a symlink to the selected profile. If so, exit.
if [ -h "${base_dir}" ] ; then
	target=`readlink -f "${base_dir}"`
	if [ "${target}" == "${base_dir}_${profile}" ] ; then
		echo "Selected profile already active."
		exit 0
	fi

	# He's the dangerous part. Make damn sure all the quotes and such
	# are at the right place so we don't delete something we shouldn't.
	rm "${base_dir}"
fi

# At this point there should be nothing at the base directory.
if [ -e "${base_dir}" ] ; then
	bail "Could not delete ${base_dir}."
fi

# Get the directory name for the selected profile.
# This is what the symlink will be pointing to.
profile_dir_name=$(basename "${base_dir}_${profile}")

# All preparations complete, activate the new profile.
set -x
ln -s "${profile_dir_name}" "${base_dir}"
