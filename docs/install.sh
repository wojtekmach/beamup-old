#!/bin/bash
# Downloads and installs OTP and Elixir.
#
# Usage: bash install.sh

set -euo pipefail

beamup_dir=$HOME/.beamup
tmp_dir=$beamup_dir/tmp
installs_dir=$beamup_dir/installs
bin_dir=$beamup_dir/bin

echo "==> Installing to ${beamup_dir}"
mkdir -p $beamup_dir
mkdir -p $tmp_dir
mkdir -p $bin_dir
cd $tmp_dir

otp_version=23.1.4
otp_install_dir=$installs_dir/otp/$otp_version
otp_build_dir=/tmp/beamup/installs/otp/$otp_version

if [ ! -d $otp_install_dir ]; then
  echo
  echo "==> Installing OTP ${otp_version}"
  otp_basename=otp-${otp_version}-$(uname -sm | tr '[:upper:]' '[:lower:]' | tr ' ' '-').tar.gz
  url=https://github.com/wojtekmach/beamup/raw/master/archives/${otp_basename}
  echo "==> Downloading $url"
  curl --fail -L -O $url
  mkdir -p $installs_dir/otp
  tar xzf $otp_basename --cd $installs_dir/otp
  $otp_install_dir/Install -sasl $otp_install_dir
  
  for i in $otp_install_dir/bin/*; do
    ln -s $i $bin_dir
  done
fi

echo
echo "==> Testing OTP"
$bin_dir/erl -version

elixir_version=1.11.2
elixir_install_dir=$installs_dir/elixir/$elixir_version

if [ ! -d $elixir_install_dir ]; then
  echo
  echo "==> Installing Elixir ${elixir_version}"
  elixir_basename=v${elixir_version}-otp-23.zip
  url=https://repo.hex.pm/builds/elixir/${elixir_basename}
  echo "==> Downloading $url"
  curl -L -O $url
  mkdir -p $elixir_install_dir
  unzip -q -d $elixir_install_dir $elixir_basename

  for i in $elixir_install_dir/bin/*; do
    ln -s $i $bin_dir
  done
fi

echo
echo "==> Testing Elixir"
export PATH="${bin_dir}:${PATH}"
$bin_dir/elixir --version

echo
echo "==> Testing Elixir + SSL"
$bin_dir/elixir -e "IO.inspect :ssl.versions()"

echo
echo "==> Installation complete"
echo
echo "Binaries are installed in $HOME/.beamup/bin. Add them to you your \$PATH:"
echo
echo "    export PATH=\$HOME/.beamup/bin:\$PATH"
echo
