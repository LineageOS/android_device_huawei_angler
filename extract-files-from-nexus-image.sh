#!/bin/bash -e
#
# Copyright (C) 2016 The CyanogenMod Project
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
export BUILD=mtc20l
export FACTORY_URL=https://dl.google.com/dl/android/aosp/angler-mtc20l-factory-a74ad54f.zip
export FACTORY_SHA256=a74ad54f0deab52cd869f81c85597212fe1a38228ddbfbbf370f9ec9a8ab142a

# Load extractutils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

REPO_ROOT="$MY_DIR"/../../..

function sha256verify(){
  local sha256=$1
  local file=$2
  sha256sum --quiet -c <( echo "$sha256 $file" )
  if [ $? -ne 0 ]; then
    echo "$file failed SHA256 hash check"
    return 1
  fi
}

function fetch(){
  local url=$1
  local sha256=$2
  local cachedir=$REPO_ROOT/.fetchcache # need a better location
  local outfile=$cachedir/${url##*/}

  mkdir -p $cachedir

  if [ ! -f $outfile ]; then
    wget "$url" -O "$outfile"
  fi
  if sha256verify "$sha256" "$outfile"; then
    echo $outfile
  else
    rm $outfile
    fetch $url $sha256
  fi
}

function checkutils() {
  local utils="$@"
  for util in $utils; do
    echo -n " * Checking for $util..."
    which $util 2>&1 > /dev/null
    if [ $? -eq 0 ]; then
      printf " ok!\n";
    else
      printf " not found!\n";
      exit 1;
    fi
  done
}

function unpack_factory(){
  local outdir=$1
  local factory_file=$(fetch "$FACTORY_URL" "$FACTORY_SHA256")
  local device=$(basename $factory_file | sed 's/\(^\w\+\).*/\1/g')
  local build=$(basename $factory_file | sed 's/^\w\+-\([a-z0-9]\+\)-.*/\1/g')

  mkdir -p $outdir/extracted
  local extension="$(echo "$factory_file" | sed 's/.*\.//g')"
  case "$extension" in tgz) tar -C "$outdir" -xvzf "$factory_file";;
                       zip) unzip -d "$outdir" "$factory_file";;
                       *) echo "Unhandled factory image extension: $extension"; exit 1;;
  esac

  unzip  -d $outdir -o $outdir/$DEVICE-$BUILD/image-$DEVICE-${BUILD}.zip
  echo -e "If you are asked to enter your password for sudo,\nroot is needed for mounting images to pull files from them"
  for image in system vendor; do
    simg2img $outdir/${image}.img $outdir/${image}.ext4.img
    mkdir -p $outdir/${image}_mount

    # I really hate using sudo here but I see no other choice
    # Any other ideas to extract these are welcome
    sudo mount -o loop $outdir/${image}.ext4.img $outdir/${image}_mount
    sudo cp -r $outdir/${image}_mount $outdir/$image
    sudo umount $outdir/${image}_mount
    sudo rm -rf $outdir/${image}_mount
    sudo chown -R $USER $outdir/${image}
  done
}

checkutils simg2img unzip md5sum sudo wget

TMPDIR="/tmp/extract-files/$DEVICE/$BUILD"
mkdir -p "$TMPDIR"

unpack_factory "$TMPDIR"

export SRC="$TMPDIR"
"$MY_DIR"/extract-files.sh "$TMPDIR"
