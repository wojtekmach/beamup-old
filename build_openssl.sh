#!/bin/bash

if [ $# -ne 1 ]; then
  echo Usage:
  echo
  echo "    ./build_openssl.sh VERSION"
  echo 
  echo Examples:
  echo
  echo "    ./build_openssl.sh 1.1.1g"
  echo
  exit 1
fi

set -euox pipefail

wd=$PWD
openssl_version=$1
beamup_dir=/tmp/beamup
src_root_dir=$beamup_dir/src/openssl
src_dir=${src_root_dir}/${openssl_version}
dest_root_dir=$beamup_dir/installs/openssl
dest_dir=${dest_root_dir}/${openssl_version}
archive_root_dir=$beamup_dir/archives
archive_path=${archive_root_dir}/openssl-${openssl_version}-macos.tar.gz

mkdir -p $src_root_dir
mkdir -p $dest_root_dir
mkdir -p $archive_root_dir

if [ ! -d "${src_dir}" ]; then
  cd $src_root_dir
  curl -C - -O https://www.openssl.org/source/openssl-${openssl_version}.tar.gz
  tar xvzf openssl-${openssl_version}.tar.gz
  mv openssl-${openssl_version} $src_dir
fi

if [ ! -d "${dest_dir}" ]; then
  cd $src_dir
  ./config --prefix=$dest_dir
  make
  make install_sw
fi

if [ ! -f $archive_path ]; then
  cd $dest_root_dir
  tar czf $archive_path ${openssl_version}/
fi

cd $wd
