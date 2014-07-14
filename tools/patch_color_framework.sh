#!/bin/bash

# $1: the android smali code  $2: the color smali code $3: the destination smali code

if [ $# -ne 4 ];then
	echo -e "USAGE:\tpatchcolor.sh android_smali_dir color_smali_dir dst_smali_dir sourcechange.txt"
	echo -e "\tAll the above need to be absolute path"
	exit
fi

PWD=`pwd`
android_smali_dir=$1
color_smali_dir=$2
dst_smali_dir=$3
temp_dir=$PWD/temp
temp_android_smali_dir=$temp_dir/android_smali
temp_color_smali_dir=$temp_dir/color_smali
temp_dst_smali_orig_dir=$temp_dir/dst_smali_orig
temp_dst_smali_patched_dir=$temp_dir/dst_smali_patched
reject_dir=$temp_dir/reject
SOURCE_CHANGE_TXT=$4
dst_orig_dir=${PWD}/.orig

rm -rf $temp_dir

echo "<<<<<<<<<<<<<<< create temp directory to store the android, color source and destination smali code with .line removed. <<<<<<<<<<<<<<<<<<"
mkdir -p $temp_android_smali_dir
mkdir -p $temp_color_smali_dir
mkdir -p $temp_dst_smali_orig_dir
#mkdir -p $temp_dst_smali_patched_dir
mkdir -p $reject_dir

cp -r $android_smali_dir/*.jar.out $temp_android_smali_dir
cp -r $color_smali_dir/*.jar.out $temp_color_smali_dir
cp -r $dst_smali_dir/*.jar.out $temp_dst_smali_orig_dir

function find_changed_files() {
	echo "copy file from $1 to $1.change"
	cat ${SOURCE_CHANGE_TXT} | while read line;
	do
		file_all_name=${line##*/}
		filename=${file_all_name%%.*}
		extension=${file_all_name##*.}

		echo "${line} ${filename} "
		for file in `find $1 -path "*/oppo/*" -prune -o -name "$filename.smali" -print -o -name "$filename\\\$*.smali" -print`
		do
			file_path=${file%/*}
			real_file_path=${file_path#*$1}
			echo "${file_path}------${real_file_path}"
			mkdir -p $1.change/${real_file_path}
			mv ${file} $1.change/${real_file_path}
		done

	done
	
	for file in `find $1 -path "*/oppo/*"`
	do
		file_path=${file%/*}
		real_file_path=${file_path#*$1}
		echo "${file_path}------${real_file_path}"
		mkdir -p $1.change/${real_file_path}
		mv ${file} $1.change/${real_file_path}
	done
	
	mv $1 $1.nochange
	mv $1.change $1
}

find_changed_files $temp_android_smali_dir
find_changed_files $temp_color_smali_dir
find_changed_files $temp_dst_smali_orig_dir

${PORT_TOOLS}/rmline.sh $temp_android_smali_dir source
${PORT_TOOLS}/rmline.sh $temp_color_smali_dir source
${PORT_TOOLS}/rmline.sh $temp_dst_smali_orig_dir source

echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< copy temp folds, and remove some .* lines over! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

mv $dst_smali_dir $dst_orig_dir
cp -r $temp_dst_smali_orig_dir $dst_smali_dir
#cp -r $temp_dst_smali_orig_dir $temp_dst_smali_patched_dir

function apply_color_patch() {
	echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
	echo "<<< compute the difference between $temp_android_smali_dir and $temp_color_smali_dir"
	cd $temp_color_smali_dir
#	echo "find ./ -name "$1.smali" -o -name "$1\\\$*.smali""
	for file in `find ./ -name "*.smali"`
	do
		echo "function:deal $file"
	       	if [ -f $temp_android_smali_dir/$file ]
	       	then
	        	diff $temp_android_smali_dir/$file $file > /dev/null || {
						diff -B -c $temp_android_smali_dir/$file $file > $file.diff
				}
	       	else
	       		touch $file.diff
	       		dst_filename=$dst_smali_dir/$file
	       		mkdir -p ${dst_filename%/*}
	       		cp $file $dst_smali_dir/$file
	        	echo "$file does not exist at $temp_android_smali_dir, copy it!"
	       	fi
	done

	cd $dst_smali_dir

	echo "<<< apply the patch into the $dst_smali_dir"
	cd $temp_color_smali_dir
	for file in `find ./ -name "*.diff"`
	do
		mkdir -p $reject_dir/`dirname $file`
		echo "function:patch $dst_smali_dir/${file%.diff} -r $reject_dir/${file%.diff}.rej < $file"
        	patch $dst_smali_dir/${file%.diff} -Nr $reject_dir/${file%.diff}.rej < $file
	done
	
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

apply_color_patch

#cd ${color_smali_dir}
#find ./ -name "oppo" -type d | xargs -i cp -rf {} ${dst_smali_dir}/{}
cp -r $dst_smali_dir $temp_dst_smali_patched_dir

cd $temp_dst_smali_orig_dir
for file in `find ./ -name "*.smali"`
do
   	rm -f $file.diff
   	echo "-------------------------${file}"
   	echo "-------------------------diff -B -c $file ${dst_smali_dir}/$file > $file.diff"
   	diff -B -c $file $dst_orig_dir/$file > $file.diff
   	echo "--------------------patch -f $dst_smali_dir/$file -r /dev/null < $file.diff >/dev/null 2>&1"
   	patch -f $dst_smali_dir/$file -r /dev/null < $file.diff >/dev/null 2>&1
	rm -f $file.diff
done

cp -rf ${temp_dst_smali_orig_dir}.nochange/* $dst_smali_dir

echo "$dst_orig_dir"
rm -rf $dst_orig_dir

find $dst_smali_dir -name "*.smali.orig" -exec rm {} \;
find $temp_dst_smali_patched_dir -name "*.smali.orig" -exec rm {} \;
#rm -rf ${PWD}/.orig



#apply_color_patch android.policy.jar.out
#apply_color_patch services.jar.out
#apply_color_patch framework.jar.out
#apply_color_patch pm.jar.out
#apply_color_patch telephony-common.jar.out

echo
echo
echo ">>> patch color into target framework is done. Please look at $reject_dir to resolve any conflicts!"
