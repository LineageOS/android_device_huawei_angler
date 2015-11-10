#!/bin/bash

export VENDOR=huawei
export DEVICE_VENDOR=huawei
export DEVICE=angler
export PROPRIETARY_FILES=proprietary-blobs.txt

# Check to see if the user passed a folder in to extract from rather than adb pull
if [ $# -eq 1 ]; then
    COPY_FROM=$1
    test ! -d "$COPY_FROM" && echo error reading dir "$COPY_FROM" && exit 1
fi

set -e

function extract() {
    for FILE in `egrep -v '(^#|^$)' $1`; do
        echo "Extracting /system/$FILE ..."
        OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
        FILE=`echo ${PARSING_ARRAY[0]} | sed -e "s/^-//g"`
        DEST=${PARSING_ARRAY[1]}
        if [ -z $DEST ]; then
            DEST=$FILE
        fi
        DIR=`dirname $FILE`
        if [ ! -d $2/$DIR ]; then
            mkdir -p $2/$DIR
        fi
        if [ "$COPY_FROM" = "" ]; then
            # Try destination target first
            if [ -f /system/$DEST ]; then
                adb pull /system/$DEST $2/$DEST
            else
                # if file does not exist try OEM target
                if [ "$?" != "0" ]; then
                    adb pull /system/$FILE $2/$DEST
                fi
            fi
        else
            # Try destination target first
            if [ -f $COPY_FROM/$DEST ]; then
                cp $COPY_FROM/$DEST $2/$DEST
            else
                # if file does not exist try OEM target
                if [ "$?" != "0" ]; then
                    cp $COPY_FROM/$FILE $2/$DEST
                fi
            fi
        fi
        # Fixup xml files
        if [[ "$2/$DEST" =~ .xml$ ]]; then
            xmlheader=$(grep '^<?xml version' "$2/$DEST")
            grep -v '^<?xml version' "$2/$DEST" > "$2/$DEST".temp
            (echo "$xmlheader"; cat "$2/$DEST".temp ) > "$2/$DEST"
            rm "$2/$DEST".temp
        fi
    done
}

DEVICE_BASE="../../../vendor/$VENDOR/$DEVICE/proprietary"
rm -rf "$DEVICE_BASE"/*

# Extract the device specific files
extract "../../$DEVICE_VENDOR/$DEVICE/$PROPRIETARY_FILES" "$DEVICE_BASE"

./setup-makefiles.sh
