#! /bin/bash

atexit ()
{
	rm -f "$COPY_OF_CHECKOUT"
}

main ()
{
	local direction=$1
	local path_to_file=$2

	local options="-O"
	[[ "$direction" == "horizontal" ]] && options="-o"

	COPY_OF_CHECKOUT=${path_to_file}.svn_checkout

	svn cat "$path_to_file" > "$COPY_OF_CHECKOUT"
	vim -d $options "$path_to_file" "$COPY_OF_CHECKOUT"
}

# set -x
trap atexit EXIT
main
# set +x
