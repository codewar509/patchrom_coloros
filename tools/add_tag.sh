#!/bin/bash

grep targetSdkVersion out/framework-res/AndroidManifest.xml
if [ $? -ne 0 ]
then
    sed -i '3r ForWrite.txt' out/framework-res/AndroidManifest.xml
fi
