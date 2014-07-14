#!/bin/bash

KEY_PAIR=${PORT_TOOLS}/keys/platform
SIGN_APK=${PORT_TOOLS}/signapk.jar
PEMKEY=${KEY_PAIR}.x509.pem
PK8KEY=${KEY_PAIR}.pk8


function sign_file() {
	echo ">>>>>>>>>>Sign single file: $1<<<<<<<<<<"
	java -jar ${SIGN_APK} $PEMKEY $PK8KEY $1 $1.signed
	rm $1
	mv $1.signed $1
}

function sign_dir() {
	echo ">>>>>>>>Sign apks under dir $1<<<<<<<<<<"
    for apk in `find $1 -name "*.apk"`
    do
		java -jar ${SIGN_APK} $PEMKEY $PK8KEY $apk $apk.signed
		rm $apk
		mv $apk.signed $apk
    done
}

function sign_zip() {
	echo ">>>>>>>>>>Sign apks in zip $1<<<<<<<<<<"
	unzip $1 -d $1.out
    for apk in `find $1.out -name "*.apk"`
    do
		java -jar ${SIGN_APK} $PEMKEY $PK8KEY $apk $apk.signed
		rm $apk
		mv $apk.signed $apk
    done
    cd $1.out
    zip -r -q $1.apk.resigned .
    cd -
    mv $1.out/$1.apk.resigned $1.apk.resigned.zip
}

if [ -z $1 ]
then
	echo "usage: ./resign.sh sf file_path          - to sign single file "
	echo "       ./resign.sh dir dir_path          - to sign all apks under dir "
	echo "       ./resign.sh zip zip_path          - to sign all apks in zip package "
	exit 0
fi

if [ $1 == "sf" ]; then
	sign_file $2
	echo "Sign success"
fi

if [ $1 == "dir" ]; then
	sign_dir $2
	echo "Sign dir apks success"
fi

if [ $1 == "zip" ]; then
	sign_zip $2
	echo "Sign package apks success"
fi