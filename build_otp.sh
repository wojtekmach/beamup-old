#!/bin/bash

if [ $# -ne 1 ]; then
  echo Usage:
  echo
  echo "    ./build_otp.sh VERSION"
  echo 
  echo Examples:
  echo
  echo "    ./build_otp.sh 23.0.2"
  echo
  exit 1
fi

set -euox pipefail

wd=$PWD
otp_version=$1
beamup_dir=/tmp/beamup
src_root_dir=$beamup_dir/src/otp
src_dir=${src_root_dir}/${otp_version}
dest_root_dir=$beamup_dir/installs/otp
dest_dir=${dest_root_dir}/${otp_version}
archive_root_dir=$beamup_dir/archives
otp_basename=otp-${otp_version}-$(uname -sm | tr '[:upper:]' '[:lower:]' | tr ' ' '-').tar.gz
archive_path=${archive_root_dir}/otp-${otp_basename}

mkdir -p $src_root_dir
mkdir -p $dest_root_dir
mkdir -p $archive_root_dir

if [ ! -d "${src_dir}" ]; then
  cd $src_root_dir
  ref=OTP-${otp_version}
  curl -L -O https://github.com/erlang/otp/archive/${ref}.tar.gz
  ls
  tar xvzf ${ref}.tar.gz
  mv otp-${ref} $src_dir
fi

if [ ! -d "${dest_dir}" ]; then
  export RELEASE_ROOT=$dest_dir
  cd $src_dir
  export ERL_TOP=`pwd`
  ./otp_build autoconf

  # Note for macos:
  # We can't rely on built-in libressl since macos doesn't ship with header files.
  # Thus we assume the build machine has openssl installed via brew install openssl,
  # sudo port install openssl, etc, and we statically link it so the end-use doesn't
  # need to have it.
  ./configure --with-ssl --disable-ssl-dynamic-lib
  make -j$(getconf _NPROCESSORS_ONLN)
  make release
  make release_docs DOC_TARGETS="chunks"
fi

if [ ! -f $archive_path ]; then
  cd $dest_root_dir
  tar czf $archive_path ${otp_version}/
fi

cd $wd
cp $archive_path $wd/archives
