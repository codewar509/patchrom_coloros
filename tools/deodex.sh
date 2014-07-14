#!/bin/bash

PWD=`pwd`
SMALI=${PORT_TOOLS}/smali
BAKSMALI=${PORT_TOOLS}/baksmali
OUT_SMALI=${PORT_ROOT}/device/smali_out
#SIGNAPK_JAR=${PORT_TOOLS}/signapk.jar
#SIGNAPK=${PORT_TOOLS}/sign.sh
#KEYPATH=${PORT_BUILD}/res-build/oppo-security
#PEMKEY=$KEYPATH/platform.x509.pem
#PK8KEY=$KEYPATH/platform.pk8

mkdir -p $OUT_SMALI 

function deodex_one_file() {
    if [ "$1" = '-a' ]
    then
        apilevel=$2
        file=$3
        out=${OUT_SMALI}/${file}_out
        tofile=${file/odex/$4} 
        echo "processing $tofile"
        $BAKSMALI -a $apilevel -o $out -d framework -I -x $file || exit -2
    else
        file=$1
        out=${OUT_SMALI}/${file}_out
        tofile=${file/odex/$2}
        echo "processing $tofile $out"
        $BAKSMALI -o $out -d framework -I -x $file || exit -2
    fi
    $SMALI $out -o classes.dex || exit -2
    jar uf $tofile classes.dex
    rm classes.dex
    #rm -rf $out
    rm $file
    
    #oppo.zyx:add sign
    #echo "extension: ${${tofile}##*.}"
    #java -Xmx512M -jar $SIGNAPK PEMKEY PK8KEY ${tofile} ${tofile}.signed
    #$ZIPALIGN 4 $tofile $tofile.aligned
    #$ZIPALIGN 4 ${tofile}.signed $tofile.aligned
    #mv $tofile.aligned $tofile
}

#usage
if [ $1 = '--help' ] 
then
    echo "usage: ./deodex.sh [-a APILevel] absolute_path_to_ota_zip_file"
    echo "  -a    specify APILevel, default Level is 15"
    exit 0
fi    

if [ ! -x $BAKSMALI -o ! -x $SMALI ]
then
     echo "Error: Can not find tool baksmali/smali"
     exit -1
fi

if [ $1 = '-a' ]
then 
    apilevel=$2
    orignzip=$3
else
    orignzip=$1
fi

temppath=`pwd`
tempdir=`mktemp -p $temppath -d tempdir.XXX`
echo "temp dir: $tempdir"
echo "unzip $stockzip to $tempdir"
unzip -q $orignzip -d $tempdir

if [ -d $tempdir/system ]
then
    cd $tempdir/system
elif [ -d $tempdir/SYSTEM ]
then
    cd $tempdir/SYSTEM
else
    echo "can't find system or SYSTEM dir in $tempdir"
    exit -1
fi

ls framework/core.odex > /dev/null
if [ $? -eq 0 ] 
then
    if [ $1 = '-a' ]
    then
        deodex_one_file -a $apilevel framework/core.odex jar
    else
        deodex_one_file framework/core.odex jar
    fi
fi

ls framework/*.odex > /dev/null
if [ $? -eq 0 ]
then
    for file in framework/*.odex
    do
        if [ $1 = '-a' ]
        then
            deodex_one_file -a $apilevel $file jar
        else
            deodex_one_file $file jar
        fi
    done
fi

ls app/*.odex > /dev/null
if [ $? -eq 0 ]
then
    for file in app/*.odex
    do
        if [ $1 = '-a' ]
        then
            deodex_one_file -a $apilevel $file apk
        else
            deodex_one_file $file apk
        fi
    done
fi

cd $tempdir
echo "zip deodexed update package!!!"

zip -q -r -y update.deodexed.zip .
echo "${PWD}"
cd ${PORT_ROOT}/device
mv $tempdir/update.deodexed.zip update.deodexed.zip
rm -rf $tempdir
rm -rf ${OUT_SMALI}

echo "deodex ${orignzip} ok"
echo "output package is update.deodexed.zip"


