#!/usr/bin/env bash
set -e 

CURR_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname $CURR_DIR)

OUT_DIR="$ROOT_DIR/release"
DENO_DIR="$ROOT_DIR/deno"
PATCH_DIR="$ROOT_DIR/patches"
LIBDENO_DIR="$ROOT_DIR/libdeno"

if [ "$ARCH" = "" ]; then
  case "$(uname -m)" in
    x86_64 | x86-64 | x64 | amd64) ARCH="amd64";;
    aarch64 | arm64) ARCH="arm64";;
    *) ARCH="";;
  esac
fi

if [ "$OS" = "" ]; then
  case "$(uname -s)" in
    Darwin) OS="macos";;
    Linux) OS="linux";;
    MINGW64_NT* | Windows_NT | MSYS_NT*) OS="windows";;
    *) OS="";;
  esac
fi

OS_ARCH="${OS}-${ARCH}"

CARGO_TARGET="$TARGET"
if [ "$CARGO_TARGET" = "" ]; then
  case "$OS_ARCH" in
    linux-amd64) CARGO_TARGET="x86_64-unknown-linux-gnu";;
    linux-arm64) CARGO_TARGET="aarch64-unknown-linux-gnu";;
    macos-amd64) CARGO_TARGET="x86_64-apple-darwin";;
    macos-arm64) CARGO_TARGET="aarch64-apple-darwin";;
    windows-amd64) CARGO_TARGET="x86_64-pc-windows-msvc";;
    windows-arm64) CARGO_TARGET="aarch64-pc-windows-msvc";;
    *) OS="";;
  esac
fi

if [ "$PROFILE" = "" ]; then
  PROFILE="debug"
fi

CARGO_PROFILE="$PROFILE"
if [ "$CARGO_PROFILE" = "debug" ]; then
  CARGO_PROFILE="dev"
fi

>&2 echo ARCH: $ARCH
>&2 echo OS: $OS
>&2 echo CARGO_TARGET $CARGO_TARGET
>&2 echo CARGO_PROFILE $CARGO_PROFILE

if [ "$CARGO_TARGET" = "" ]; then
  >&2 echo No CARGO_TARGET
  exit 1
fi

if [ "$CARGO_PROFILE" = "" ]; then
  >&2 echo No CARGO_PROFILE
  exit 1
fi

cd "$DENO_DIR" 
cargo build -p libdeno --target "$CARGO_TARGET" --profile "$CARGO_PROFILE"

rm -rf "$OUT_DIR/$OS_ARCH"
mkdir -p "$OUT_DIR/$OS_ARCH"

LIBNAME="libdeno.a"
if [ "$OS" = "windows" ]; then
  LIBNAME="deno.lib"
fi

EXT=".a"
if [ "$OS" = "windows" ]; then
  LIBNAME=".lib"
fi

cp "$DENO_DIR/target/$CARGO_TARGET/$PROFILE/$LIBNAME" "$OUT_DIR/$OS_ARCH/libdeno.$EXT"