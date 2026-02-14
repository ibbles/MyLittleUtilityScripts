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

dirname=`basename "${to_recreate}"`
read -p "Type '${dirname}' to delete '${to_recreate}': " do_delete
if [ "${do_delete}" != "${dirname}" ] ; then
    fail "Doing nothing."
    exit 1
fi

rm -rf "${to_recreate}"
mkdir "${to_recreate}"
cd "${to_recreate}"
