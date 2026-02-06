#!/usr/bin/env bash
set -e 

CURR_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname $CURR_DIR)

OUT_DIR="$ROOT_DIR/release"
DENO_DIR="$ROOT_DIR/deno"
PATCH_DIR="$ROOT_DIR/patches"
LIBDENO_DIR="$ROOT_DIR/libdeno"

cd "$DENO_DIR"
git add .
git reset "$DENO_DIR/libdeno"
git reset "$DENO_DIR/Cargo.lock"
git diff --staged > "$PATCH_DIR/deno.patch"