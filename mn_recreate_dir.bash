#!/usr/bin/env bash

function fail {
    echo "$1" >&2
    exit 1
}

to_recreate=`pwd`
cd ..
parent=`pwd`
if [ "${to_recreate}" == "${parent}" ] ; then
    echo "to_recreate: '${to_recreate}'."
    echo "parent: '${parent}'."
    fail "Could not change working directory."
fi

read -p "Delete '${to_recreate}'? [y/n] " do_delete
if [ "${do_delete}" != "y" ] ; then
    fail "Doing nothing."
fi

rm -rf "${to_recreate}"
mkdir "${to_recreate}"
cd "${to_recreate}"
