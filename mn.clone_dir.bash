#!/bin/bash

####
##
## This is a script that clones a directory into another.
##
## Example usage:
##    mn.clone_dir.bash to /media/backups/some_directory
##
## Takes two arguments, the first to dictate the direction of transfer and the
## second selects a folder to compare with and copy from/to. This is called the
## remote folder. The current working directory is always taken as one of the
## copy to/from folders, the local folder.
##
## Uses rsync to do the actual copying.
##
####

usage="Usage: $0 to|from <path> \nEx:\n $0 to /media/backups/some_directory\nEx:\n $0 from /media/backups/some_directory"

## Check number of argument.
if [ $# -ne 2 ] ; then
    echo -e $usage
    exit
fi


## Check direction argument.
if [[ "$1" == "to"  ||  "$1" == "from" ]] ; then
    direction=$1
    shift
else
    echo "'$1' is not a valid direction"
    echo -e $usage
    exit
fi

## Check remote folder argument.
## Can be either a directory on the local machine or an remote URL.
## We make sure there always is a / at the end of the path to make sure
## rsync compares the contents of the folders and not the folders themselves.
## We don't want to create a directory with the name of the source directory
## in the target directory.
if [[ "$1" == *"@"*":"* ]] ; then
    # This looks like an SSH connection,
    # can't verify if the directory exists or not.
    # TODO: Is there a more reliable way to do this detection?
    remote="${1}/"
    shift
else
    if [ -d "$1" ] ; then
        remote="${1}/"
        shift
    else
        echo "Remote directory '$1' does not exist."
        echo -e $usage
        exit
    fi
fi


## Give a name to the local current working directory.
## Add a trailing / on this as well, for the same reason as for the remote.
local=`pwd`
local="${local}/"

## Find the source and destination directories.
if [ "$direction" == "from" ] ; then
    target=$local
    source=$remote
elif [ "$direction" == "to" ] ; then
    target=$remote
    source=$local
else
    echo "Direction must be one of 'to' and 'from'. Was '${direction}'."
    echo -e $usage
    exit
fi

echo "Copy operation is '${source}' -> '${target}'."

## rsync arguments.
argsAlways="-savz --delete --progress -O --no-owner --no-group"
argsDry="-ni"

## Make a dry run.
set -x
rsync $argsAlways $argsDry "$source" "$target"
set +x

## Ask user for confirmation.
echo "Does the above look alright? [y/n]"
read answer
if [ "$answer" != "y" ] ; then
    echo "doing nothing"
    exit
fi


## Do actual data copying.
set -x
rsync $argsAlways "$source" "$target"
set +x
