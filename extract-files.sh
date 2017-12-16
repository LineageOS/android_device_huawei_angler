#!/bin/bash -e
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

export VENDOR=huawei
export DEVICE=angler

# Load extractutils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

REPO_ROOT="$MY_DIR"/../../..
ROM_ROOT="$REPO_ROOT"
HELPER=
for x in "${REPO_ROOT}"/vendor/*; do
  if [ -f "$x/build/tools/extract_utils.sh" ]; then
    HELPER="$x/build/tools/extract_utils.sh"
    break;
  fi
done
if [ ! -f "$HELPER" ]; then
  echo "Unable to find helper script at $HELPER"
  exit 1
fi
. "$HELPER"

if [ $# -eq 0 ]; then
  SRC=adb
else
  if [ $# -eq 1 ]; then
     SRC=$1
  else
     echo "$0: bad number of arguments"
     echo ""
     echo "usage: $0 [PATH_TO_EXPANDED_ROM]"
     echo ""
     echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
     echo "the device using adb pull."
     exit 1
  fi
fi

setup_vendor "$DEVICE" "$VENDOR" "$REPO_ROOT"

# Extract the device specific files that always occur in /system
extract "$MY_DIR/lineage-proprietary-blobs.txt" "$SRC"

## Handle blobs that may be in /system OR /vendor (only occurs when extracting from nexus images)

# if we're extracting from factory images, pre-hardlink missing blobs from /vendor to /system
if [ "$SRC" != "adb" ]; then
  for file in $(egrep -v '(^#|^$)' "$MY_DIR"/lineage-proprietary-blobs-vendorimg.txt); do

     oldifs=$IFS IFS=":" parsing_array=($file) IFS=$oldifs

     srcfile=$(echo ${parsing_array[0]} | sed -e "s/^-//g")
     destfile=${parsing_array[1]}
     if [ -z "$destfile" ]; then
       destfile="$srcfile"
     fi
     destdir=$(dirname "$destfile")

     if [ -f $SRC/system/$destfile ]; then
       #skip already hardlinked files
       continue;
     fi

     if [ ! -d "$SRC/system/$destdir" ]; then
       mkdir -p "$SRC/system/$destdir"
     fi

     ln -f $SRC/vendor/$srcfile $SRC/system/$destfile
  done
fi

# Extract "sometimes system" blobs
extract "$MY_DIR/lineage-proprietary-blobs-vendorimg.txt" "$SRC"

"$MY_DIR"/setup-makefiles.sh
