#!/bin/bash

if [ $# -ne 2 ]; then
	echo -e "USAGE:\tcopy_fold.sh A B"
	echo -e ""
	exit 0
fi

if [ ! -e $1 ]; then
	echo -e "Warning : $1 is not exist, no action"
	exit 0
fi

if [ -f $1 ]; then
	echo -e "$1 : It's a file"
	cp $1 $2
	exit 0
fi

if [ ! -e $2 ]; then
	echo -e "$2 : not exist, copy "$1" as "$2""
	cp -rf $1 $2
else
	if [ `ls $1 | wc -l` -eq 0 ]; then
		echo -e "$1 has no subdir or subfiles, no action"
		exit 0
	else
		echo -e "Copy $1 subfiles into $2"
		cp -rf $1/* $2/
	fi
fi

