#!/usr/bin/env bash
set -e 

CURR_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname $CURR_DIR)

OUT_DIR="$ROOT_DIR/release"
DENO_DIR="$ROOT_DIR/deno"
PATCH_DIR="$ROOT_DIR/patches"
LIBDENO_DIR="$ROOT_DIR/libdeno"

TAG="$1"

rm -rf "$DENO_DIR"
mkdir -p "$DENO_DIR"
git config --global safe.directory '*'
git clone "https://github.com/denoland/deno.git" --branch "$TAG" --depth=1 "$DENO_DIR"
ln -s "$LIBDENO_DIR" "$DENO_DIR"

cd "$DENO_DIR"
git apply "$PATCH_DIR/deno.patch" 
git add .
git reset "$DENO_DIR/libdeno"
git reset "$DENO_DIR/Cargo.lock"

git status