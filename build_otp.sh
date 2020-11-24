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
archive_path=${archive_root_dir}/otp-${otp_version}-macos.tar.gz

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
  openssl_dir="${beamup_dir}/installs/openssl/1.1.1g"
  export RELEASE_ROOT=$dest_dir
  cd $src_dir
  ./otp_build autoconf

  ./configure --disable-dynamic-ssl-lib --with-ssl="${openssl_dir}" --enable-dirty-schedulers --enable-builtin-zlib --without-javac

  make -j$(getconf _NPROCESSORS_ONLN)
  make release
  make release_docs DOC_TARGETS="chunks"
  make install
fi

if [ ! -f $archive_path ]; then
  cd $dest_root_dir
  tar czf $archive_path ${otp_version}/
fi

cd $wd

# # post-install
# ./Install -sasl $PWD
