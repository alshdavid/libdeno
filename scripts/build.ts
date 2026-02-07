#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run --allow-env
import * as path from "jsr:@std/path";

const DIRNAME = path.dirname(path.fromFileUrl(new URL(import.meta.url)));
const ROOT_DIR = path.dirname(DIRNAME);

const OUT_DIR = path.join(ROOT_DIR, 'release');
const DENO_DIR = path.join(ROOT_DIR, 'deno');
const PATCH_DIR = path.join(ROOT_DIR, 'patches');
const LIBDENO_DIR = path.join(ROOT_DIR, 'libdeno');

// Determine architecture
let ARCH = Deno.env.get("BUILD_ARCH") || "";
if (!ARCH) {
  const arch = Deno.build.arch;
  switch (arch) {
    case "x86_64":
      ARCH = "amd64";
      break;
    case "aarch64":
      ARCH = "arm64";
      break;
    default:
      ARCH = "";
  }
}

// Determine OS
let OS = Deno.env.get("BUILD_OS") || "";
if (!OS) {
  const os = Deno.build.os;
  switch (os) {
    case "darwin":
      OS = "macos";
      break;
    case "linux":
      OS = "linux";
      break;
    case "windows":
      OS = "windows";
      break;
    default:
      OS = "";
  }
}

const OS_ARCH = `${OS}-${ARCH}`;

// Determine cargo target
let CARGO_TARGET = Deno.env.get("TARGET") || "";
if (!CARGO_TARGET) {
  switch (OS_ARCH) {
    case "linux-amd64":
      CARGO_TARGET = "x86_64-unknown-linux-gnu";
      break;
    case "linux-arm64":
      CARGO_TARGET = "aarch64-unknown-linux-gnu";
      break;
    case "macos-amd64":
      CARGO_TARGET = "x86_64-apple-darwin";
      break;
    case "macos-arm64":
      CARGO_TARGET = "aarch64-apple-darwin";
      break;
    case "windows-amd64":
      CARGO_TARGET = "x86_64-pc-windows-msvc";
      break;
    case "windows-arm64":
      CARGO_TARGET = "aarch64-pc-windows-msvc";
      break;
    default:
      CARGO_TARGET = "";
  }
}

// Determine profile
const PROFILE = Deno.env.get("PROFILE") || "debug";

let CARGO_PROFILE = PROFILE;
if (CARGO_PROFILE === "debug") {
  CARGO_PROFILE = "dev";
}

// Log configuration
console.error(`ARCH: ${ARCH}`);
console.error(`OS: ${OS}`);
console.error(`CARGO_TARGET: ${CARGO_TARGET}`);
console.error(`CARGO_PROFILE: ${CARGO_PROFILE}`);


// Validate
if (!CARGO_TARGET) {
  console.error("No CARGO_TARGET");
  Deno.exit(1);
}

if (!CARGO_PROFILE) {
  console.error("No CARGO_PROFILE");
  Deno.exit(1);
}

// Build with cargo
const cargoProcess = new Deno.Command("cargo", {
  args: ["build", "-p", "libdeno", "--target", CARGO_TARGET, "--profile", CARGO_PROFILE],
  cwd: DENO_DIR
}).spawn();

const cargoStatus = await cargoProcess.status;
if (!cargoStatus.success) {
  Deno.exit(cargoStatus.code);
}

// Clean and create output directory
try {
  await Deno.remove(`${OUT_DIR}/${OS_ARCH}`, { recursive: true });
} catch {
  // Directory might not exist, ignore error
}
await Deno.mkdir(`${OUT_DIR}/${OS_ARCH}`, { recursive: true });

// Determine library name and extension
let LIBNAME = "libdeno.a";
let EXT = "a";
if (OS === "windows") {
  LIBNAME = "deno.lib";
  EXT = "lib";
}

// Copy library
const sourcePath = path.join(DENO_DIR, 'target', CARGO_TARGET, PROFILE, LIBNAME);
const destPath = path.join(OUT_DIR, OS_ARCH, `libdeno.${EXT}`);
await Deno.copyFile(sourcePath, destPath);