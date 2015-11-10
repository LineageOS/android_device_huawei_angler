#!/bin/bash -e

export VENDOR=huawei
export DEVICE_VENDOR=huawei
export DEVICE=angler
export PROPRIETARY_FILES=proprietary-blobs.txt

TMPDIR="/tmp/extractfiles.$$"
mkdir "$TMPDIR"

# relative to SMALIBASE defined by 2nd cli arg to this script
SMALIJAR=smali/build/libs/smali.jar
BAKSMALIJAR=baksmali/build/libs/baksmali.jar

# Only supports extract from filesystem

if [[ "$#" -ne 2 || ! -d "$1/vendor" || ! -d "$1/system" || ! -f "$2/$SMALIJAR" || ! -f "$2/$BAKSMALIJAR" ]]; then
    echo "Usage: $0 <path to root dir of extracted filesystem> <smali base dir for git clone https://github.com/JesusFreke/smali> >"
    echo "  root dir must contain at least system and vendor directions"
    echo "  smali base must contain built jar objects (within smali base run: ./gradew build)"
    exit 1
fi

COPY_FROM="$1"
SMALIBASE="$2"

function oat2dex()
{
    OFILE="$1"

    OAT="`dirname $OFILE`/oat/arm64/`basename $OFILE ."${OFILE##*.}"`.odex"
    if [ ! -e "$OAT" ]; then
        return 0
    fi

    java -jar "$SMALIBASE/$BAKSMALIJAR" -x -o "$TMPDIR/dexout" -c boot.oat -d "$COPY_FROM/system/framework/arm64" "$OAT"
    java -jar "$SMALIBASE/$SMALIJAR" "$TMPDIR/dexout" -o "$TMPDIR/classes.dex"
    rm -rf "$TMPDIR/dexout"
}

function extract() {
    OUTBASE="$2"
    for FILE in $(egrep -v '(^#|^$)' $1); do
        echo "Extracting $FILE ..."
        OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
        SRCFILE=$(echo ${PARSING_ARRAY[0]} | sed -e "s/^-//g")
        DESTFILE=${PARSING_ARRAY[1]}
        if [ -z "$DESTFILE" ]; then
            DESTFILE="$SRCFILE"
        fi
        DESTFILE=$(echo "$DESTFILE" | sed 's|^system/||')
        DESTDIR=$(dirname "$DESTFILE")
        if [ ! -d "$OUTBASE/$DESTDIR" ]; then
            mkdir -p "$OUTBASE/$DESTDIR"
        fi

        cp "$COPY_FROM/$SRCFILE" "$OUTBASE/$DESTFILE"

        # Fixup xml files
        if [[ "$OUTBASE/$DESTFILE" =~ .xml$ ]]; then
            xmlheader=$(grep '^<?xml version' "$OUTBASE/$DESTFILE")
            grep -v '^<?xml version' "$OUTBASE/$DESTFILE" > "$OUTBASE/$DESTFILE".temp
            (echo "$xmlheader"; cat "$OUTBASE/$DESTFILE".temp ) > "$OUTBASE/$DESTFILE"
            rm "$OUTBASE/$DESTFILE".temp
        fi
        if [[ "$DESTFILE" =~ .(apk|jar)$ ]]; then
            oat2dex "$COPY_FROM/$SRCFILE"
            if [ -e "$TMPDIR/classes.dex" ]; then
                zip -gjq "$OUTBASE/$DESTFILE" "$TMPDIR/classes.dex"
                rm "$TMPDIR/classes.dex"
                echo "Updated $OUTBASE/$DESTFILE from odex files"
            fi
        fi
    done
}

DEVICE_BASE="../../../vendor/$VENDOR/$DEVICE/proprietary"
rm -rf "$DEVICE_BASE"/*

# Extract the device specific files
extract "../../$DEVICE_VENDOR/$DEVICE/$PROPRIETARY_FILES" "$DEVICE_BASE"

# clean temp dir
rm -rf "$TMPDIR"

./setup-makefiles.sh
