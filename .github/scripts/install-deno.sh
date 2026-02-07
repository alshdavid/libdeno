#!/usr/bin/sh
set -e

ARCH=""
case "$(uname -m)" in
  x86_64 | x86-64 | x64 | amd64) ARCH="amd64";;
  aarch64 | arm64) ARCH="arm64";;
  *) ARCH="";;
esac

OS=""
case "$(uname -s)" in
  Darwin) OS="macos";;
  Linux) OS="linux";;
  MINGW64_NT* | Windows_NT | MSYS_NT*) OS="windows";;
  *) OS="";;
esac

>&2 echo ARCH: $ARCH
>&2 echo OS: $OS

export OS_ARCH="${OS}-${ARCH}"
echo "export OS_ARCH=\"${OS_ARCH}\""

if ! [ "$GITHUB_ENV" = "" ]; then
  echo "OS_ARCH=${OS_ARCH}" >> $GITHUB_ENV
fi

URL=""
case "$OS-$ARCH" in
  linux-amd64)    URL="https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip";;
  linux-arm64)    URL="https://github.com/denoland/deno/releases/latest/download/deno-aarch64-unknown-linux-gnu.zip";;
  macos-amd64)    URL="https://github.com/denoland/deno/releases/latest/download/deno-x86_64-apple-darwin.zip";;
  macos-arm64)    URL="https://github.com/denoland/deno/releases/latest/download/deno-aarch64-apple-darwin.zip";;
  windows-amd64)  URL="https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip";;
  windows-arm64)  URL="";;
esac

if [ "$URL" = "" ]; then
  >&2 echo "Cannot find installer for Deno"
  exit 1
fi

>&2 echo URL: $URL
>&2 echo

case "$OS-$ARCH" in
  linux-amd64)    wget $URL -O /tmp/deno.zip && unzip /tmp/deno.zip -d /usr/local/bin;;
  linux-arm64)    wget $URL -O /tmp/deno.zip && unzip /tmp/deno.zip -d /usr/local/bin;;
  macos-amd64)    wget $URL -O /tmp/deno.zip && unzip /tmp/deno.zip -d /usr/local/bin;;
  macos-arm64)    wget $URL -O /tmp/deno.zip && unzip /tmp/deno.zip -d /usr/local/bin;;
  windows-amd64)  wget $URL -O /tmp/deno.zip && unzip /tmp/deno.zip -d /usr/bin;;
  windows-arm64)  wget $URL -O /tmp/deno.zip && unzip /tmp/deno.zip -d /usr/bin;;
esac