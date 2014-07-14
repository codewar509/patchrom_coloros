#!/bin/bash

echo "Build the full update package"
rm -rf new-update/
cp -rf update/ new-update/
rm -rf new-update/system/app/*
echo "${PORT_BUILD}/ColorSystem/*"
cp -rf ${PORT_BUILD}/ColorSystem/* new-update/system
cp -rf out/framework new-update/system

#we will use $(CUSTOM_UPDATE) to cover, so you need put your change file or some apk can't be deleted 
if [ -d ${CUSTOM_UPDATE} ]
then
	echo "custom: ${CUSTOM_UPDATE}"
	cp -rf ${CUSTOM_UPDATE}/* new-update/
fi

cd new-update
zip -q -r -y ${PWD}/color-update.zip *
cd -