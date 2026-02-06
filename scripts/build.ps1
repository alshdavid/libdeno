$ErrorActionPreference = "Stop"

$CURR_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $CURR_DIR

$OUT_DIR = Join-Path $ROOT_DIR "release"
$DENO_DIR = Join-Path $ROOT_DIR "deno"
$PATCH_DIR = Join-Path $ROOT_DIR "patches"
$LIBDENO_DIR = Join-Path $ROOT_DIR "libdeno"

$PROFILE = if ([string]::IsNullOrWhiteSpace($env:PROFILE)) { "debug" } else { $env:PROFILE }
$CARGO_PROFILE = if ($PROFILE -eq "debug") { "dev" } else { $PROFILE }
$CARGO_TARGET = $env:TARGET

[Console]::Error.WriteLine("ARCH: $($env:ARCH)")
[Console]::Error.WriteLine("OS: $($env:OS)")
[Console]::Error.WriteLine("CARGO_TARGET: $CARGO_TARGET")
[Console]::Error.WriteLine("CARGO_PROFILE: $CARGO_PROFILE")

if ([string]::IsNullOrWhiteSpace($CARGO_TARGET)) { 
    [Console]::Error.WriteLine("No CARGO_TARGET")
    exit 1 
}

Set-Location $DENO_DIR
cargo build -p libdeno --target "$CARGO_TARGET" --profile "$CARGO_PROFILE"

$TARGET_OUT_DIR = Join-Path $OUT_DIR $OS_ARCH
if (Test-Path $TARGET_OUT_DIR) { Remove-Item -Recurse -Force $TARGET_OUT_DIR }
New-Item -ItemType Directory -Force -Path $TARGET_OUT_DIR | Out-Null

$LIBNAME = "libdeno.a"
$EXT = "a"

if ($env:OS -eq "windows") {
    $LIBNAME = "deno.lib"
    $EXT = "lib"
}

$SOURCE_FILE = Join-Path $DENO_DIR "target/$CARGO_TARGET/$PROFILE/$LIBNAME"
$DEST_FILE = Join-Path $TARGET_OUT_DIR "libdeno.$EXT"

Copy-Item -Path $SOURCE_FILE -Destination $DEST_FILE -Force