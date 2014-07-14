#!/bin/bash

PWD=`pwd`
SOURCE_CHANGE_TXT=$PWD/$1
android_dir=$PWD/$2
color_dir=$PWD/$3
temp_dir=$PWD/tmpdir

mkdir -p temp_dir

cat $SOURCE_CHANGE_TXT | while read line;
do
	echo "++++++++++++++++++++${PWD}++++++++++++++++++++++"
	cd $color_dir
	echo $line
	file_all_name=${line##*/}
	filename=${file_all_name%%.*}
	extension=${file_all_name##*.}
	if [ ${extension} = java -o ${extension} = aidl ]
	then
		echo $filename
		for file in `find ./ -name "$filename.smali" -o -name "$filename\\\$*.smali"`
		mkdir -p $android_dir/`dirname $file`
		cp $color_dir/$file $android_dir/$file
		
#		apply_color_patch_new $filename
#		cd $temp_dst_smali_orig_dir
#		for difffile in `find ./ -name "$filename.smali" -o -name "$filename\\\$*.smali"`
#		do
#    		rm -f $difffile.diff
#    		echo "-------------------------${difffile}"
#    		echo "-------------------------diff -B -c $difffile ${dst_orig_dir}/$difffile > $difffile.diff"
#    		diff -B -c $difffile ${dst_orig_dir}/$difffile > $difffile.diff
#    		echo "--------------------patch -f $dst_smali_dir/$difffile -r /dev/null < $difffile.diff >/dev/null 2>&1"
#    		patch -f $dst_smali_dir/$difffile -r /dev/null < $difffile.diff >/dev/null 2>&1
#			rm -f $difffile.diff
#		done
	fi
	echo ""
done

#cp -rf $android_dir 