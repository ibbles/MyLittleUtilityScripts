#!/bin/bash

function print_usage {
	echo "Usage: test_decrypt.bash ENCRYPTED_FILE"
}

if [ $# -ne 1 ] ; then
	echo "Wrong number of arguments." 1>&2
	print_usage
	exit 1
fi

if [ -z "$1" ] ; then
	echo "No filename specified." 1>&2
	print_usage
	exit 1
fi

file=$1
if [ ! -f "$file" ] ; then
	echo "Encrypted file $file does not exist." 1>&2
	exit 1
fi
if [ ! "${file: -4}" = ".enc" ] ; then
	echo "Filename $file does not end with '.enc'." 1>&2
	exit 1
fi

decrypt_file=${file%.enc}
if [ -f "$decrypt_file" ] ; then
	echo "Decrypted file $decrypt_file already exists." 1>&2
	exit 1
fi

compare_file=~/plaintext_secrets/"$decrypt_file"
if [ ! -f "$compare_file" ] ; then
	echo "No comparison file found at $compare_file."
	exit 1
fi

# Modifications to the filesystem starts here.

mn.decrypt_file.fish "$file"
if [ $? -ne 0 ] ; then
	echo "Decrypt of $file failed."
	exit 1
fi
if [ ! -f "$decrypt_file" ] ; then
	echo "Decrypt succeeded but did not find a file at $decrypt_file."
	echo "  Where is it?"
	exit 1
fi

md5sum "$decrypt_file" "$compare_file" | grep -v "$file" | sort
md5sum "$decrypt_file" | cut -d ' ' -f1 > /tmp/decrypt_main
md5sum "$compare_file" | cut -d ' ' -f1 > /tmp/decrypt_plaintext
diff /tmp/decrypt_main /tmp/decrypt_plaintext
rm "$decrypt_file"
rm /tmp/decrypt_main /tmp/decrypt_plaintext
