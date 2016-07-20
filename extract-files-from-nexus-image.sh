#!/bin/bash -e
export VENDOR=huawei
export DEVICE=angler
export BUILD=mtc19x
export FACTORY_URL=https://dl.google.com/dl/android/aosp/angler-mtc19x-factory-83a34810.tgz
export FACTORY_MD5=0667d2bc7d65ee0dc104ebe5236edbbe

# Load extractutils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

REPO_ROOT="$MY_DIR"/../../..

function build_smali(){
  local outdir="$1"
  rm -rf $outdir
  git clone https://github.com/JesusFreke/smali $outdir
  cd $outdir
  git checkout v2.1.2
  ./gradlew build
  cd -
}

function md5verify(){
  local md5=$1
  local file=$2
  md5sum --quiet -c <( echo "$md5 $file" )
  if [ $? -ne 0 ]; then
    echo "$file failed MD5 hash check"
    return 1
  fi
}

function fetch(){
  local url=$1
  local md5=$2
  local cachedir=$REPO_ROOT/.fetchcache # need a better location
  local outfile=$cachedir/${url##*/}

  mkdir -p $cachedir

  if [ ! -f $outfile ]; then
    wget "$url" -O "$outfile"
  fi
  if md5verify "$md5" "$outfile"; then
    echo $outfile
  else
    rm $outfile
    fetch $url $md5
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
  local factory_file=$(fetch "$FACTORY_URL" "$FACTORY_MD5")
  local device=$(basename $factory_file | sed 's/\(^\w\+\).*/\1/g')
  local build=$(basename $factory_file | sed 's/^\w\+-\([a-z0-9]\+\)-.*/\1/g')

  mkdir -p $outdir/extracted

  tar -C "$outdir" -xvzf "$factory_file"

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
export SMALI_BASE="$TMPDIR/smali"
export SMALIJAR="$SMALI_BASE/smali/build/libs/smali.jar"
export BAKSMALIJAR="$SMALI_BASE/baksmali/build/libs/baksmali.jar"
build_smali "$SMALI_BASE"

unpack_factory "$TMPDIR"

export SRC="$TMPDIR"
"$MY_DIR"/extract-files.sh "$TMPDIR"
