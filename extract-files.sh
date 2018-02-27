#!/bin/bash -e
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2018 The LineageOS Project
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

extract "$MY_DIR/lineage-proprietary-blobs.txt" "$SRC"

"$MY_DIR"/setup-makefiles.sh
