$ErrorActionPreference = "Stop"

$CURR_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $CURR_DIR

$OUT_DIR     = Join-Path $ROOT_DIR "release"
$DENO_DIR    = Join-Path $ROOT_DIR "deno"
$PATCH_DIR   = Join-Path $ROOT_DIR "patches"
$LIBDENO_DIR = Join-Path $ROOT_DIR "libdeno"

$TAG = $args[0]
if ([string]::IsNullOrWhiteSpace($TAG)) {
    Write-Error "No tag provided. Usage: .\setup.ps1 <tag>"
    exit 1
}

if (Test-Path $DENO_DIR) { 
    Remove-Item -Recurse -Force $DENO_DIR 
}
New-Item -ItemType Directory -Force -Path $DENO_DIR | Out-Null

git config --global safe.directory '*'
git clone "https://github.com/denoland/deno.git" --branch "$TAG" --depth 1 "$DENO_DIR"

$SYMLINK_PATH = Join-Path $DENO_DIR "libdeno"
New-Item -ItemType SymbolicLink -Path $SYMLINK_PATH -Target $LIBDENO_DIR | Out-Null

Set-Location $DENO_DIR

$PATCH_FILE = Join-Path $PATCH_DIR "deno.patch"
git apply --ignore-space-change --ignore-whitespace $PATCH_FILE

git add .
git reset "libdeno"
git reset "Cargo.lock"

git status
