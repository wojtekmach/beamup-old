#!/bin/bash
# Downloads and installs OpenSSL, OTP, and Elixir.
#
# Usage: bash install.sh

set -euo pipefail

elixirup_dir=$HOME/.elixirup
tmp_dir=$elixirup_dir/tmp
installs_dir=$elixirup_dir/installs
bin_dir=$elixirup_dir/bin

echo "==> Installing to ${elixirup_dir}"
mkdir -p $elixirup_dir
mkdir -p $tmp_dir
mkdir -p $bin_dir
cd $tmp_dir

otp_version=23.0.2
otp_install_dir=$installs_dir/otp/$otp_version
otp_build_dir=/tmp/elixirup/installs/otp/$otp_version

if [ ! -d $otp_install_dir ]; then
  echo
  echo "==> Installing OTP ${otp_version}"
  url=https://github.com/wojtekmach/elixirup/raw/master/archives/otp-${otp_version}-macos.tar.gz
  echo "==> Downloading $url"
  curl -L -O $url
  mkdir -p $installs_dir/otp
  tar xzf otp-${otp_version}-macos.tar.gz --cd $installs_dir/otp
  $otp_install_dir/Install -sasl $otp_install_dir
  
  for i in $otp_install_dir/bin/*; do
    ln -s $i $bin_dir
  done
fi

echo
echo "==> Testing OTP"
$bin_dir/erl -version

elixir_version=1.10.3
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
echo "Binaries are installed in $HOME/.elixirup/bin. Add them to you your \$PATH:"
echo
echo "    export PATH=\$HOME/.elixirup/bin:\$PATH"
echo
