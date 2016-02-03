#!/bin/bash -e

vendor=huawei
device=angler
build=mmb29q

factory_url=https://dl.google.com/dl/android/aosp/angler-mmb29q-factory-239acdde.tgz
factory_md5=bc44a06770f886c6896daecef2bd7d77


self_dir="$(dirname $(readlink -f $0))"
proprietary_files=$self_dir/proprietary-blobs.txt
device_base=$ANDROID_BUILD_TOP/vendor/$vendor/$device/proprietary

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
  local cachedir=$ANDROID_BUILD_TOP/.fetchcache # need a better location
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

function build_smali(){
  local outdir="$1"
  rm -rf $outdir
  git clone https://github.com/JesusFreke/smali $outdir
  cd $outdir
  ./gradlew build
  cd -
}

function oat2dex(){
  local file="$1"
  local tmpdir="$2"

  local smali_jar=$tmpdir/smali/smali/build/libs/smali.jar
  local baksmali_jar=$tmpdir/smali/baksmali/build/libs/baksmali.jar

  if [ ! -f "$smali_jar" ]; then
    build_smali "$tmpdir/smali"
  fi

  if [ ! -e "`dirname $file`/oat/arm/`basename $file ."${file##*.}"`.odex" ] && [ ! -e "`dirname $file`/oat/arm64/`basename $file ."${file##*.}"`.odex" ]; then
    return 0
  fi

  mkdir -p $tmpdir/dexout
  for x in "`dirname $file`/oat/arm/`basename $file ."${file##*.}"`.odex" "`dirname $file`/oat/arm64/`basename $file ."${file##*.}"`.odex"; do
    [ ! -e "$x" ] && continue
    java -jar "$baksmali_jar" -x -o "$tmpdir/dexout" -c boot.oat -d "$tmpdir/system/framework/arm64" -d "$mpdir/system/framework/arm" "$x"
    ls -l $tmpdir/dexout | wc -l
  done
  java -jar "$smali_jar" "$tmpdir/dexout" -o "$tmpdir/classes.dex"
  rm -rf "$tmpdir/dexout"
}

function unpack_factory(){
  local factory_url=$1
  local factory_md5=$2
  local outdir=$3
  local factory_file=$(fetch "$factory_url" "$factory_md5")
  local device=$(basename $factory_file | sed 's/\(^\w\+\).*/\1/g')
  local build=$(basename $factory_file | sed 's/^\w\+-\([a-z0-9]\+\)-.*/\1/g')

  mkdir -p $outdir/extracted

  tar -C "$outdir" -xvzf "$factory_file"

  unzip  -d $outdir -o $outdir/$device-$build/image-$device-${build}.zip

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

function extract(){
  local factory_url=$1
  local factory_md5=$2
  local proprietary_files=$3
  local outbase=$4
  local tmpdir="/tmp/extract-files/$device/$build"

  mkdir -p $4
  mkdir -p $tmpdir

  unpack_factory "$factory_url" "$factory_md5" "$tmpdir"

  for file in $(egrep -v '(^#|^$)' $proprietary_files); do
      echo "Extracting $file ..."
      oldifs=$IFS IFS=":" parsing_array=($file) IFS=$oldifs
      srcfile=$(echo ${parsing_array[0]} | sed -e "s/^-//g")
      destfile=${parsing_array[1]}
      if [ -z "$destfile" ]; then
          destfile="$srcfile"
      fi
      destfile=$(echo "$destfile" | sed 's|^system/||')
      destdir=$(dirname "$destfile")
      if [ ! -d "$outbase/$destdir" ]; then
          mkdir -p "$outbase/$destdir"
      fi

      cp "$tmpdir/$srcfile" "$outbase/$destfile"

      # Fixup xml files
      if [[ "$outbase/$destfile" =~ .xml$ ]]; then
          xmlheader=$(grep '^<?xml version' "$outbase/$destfile")
          grep -v '^<?xml version' "$outbase/$destfile" > "$outbase/$destfile".temp
          (echo "$xmlheader"; cat "$outbase/$destfile".temp ) > "$outbase/$destfile"
          rm "$outbase/$destfile".temp
      fi
      if [[ "$destfile" =~ .(apk|jar)$ ]]; then
          oat2dex "$tmpdir/$srcfile" $tmpdir
          if [ -e "$tmpdir/classes.dex" ]; then
              zip -gjq "$outbase/$destfile" "$tmpdir/classes.dex"
              rm "$tmpdir/classes.dex"
              echo "Updated $outbase/$destfile from odex files"
          fi
      fi
  done

}

checkutils simg2img unzip md5sum sudo wget

extract "$factory_url" "$factory_md5" "$proprietary_files" "$device_base"

bash $self_dir/setup-makefiles.sh
