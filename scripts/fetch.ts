#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run --allow-env

const CURR_DIR = new URL(".", import.meta.url).pathname;
const ROOT_DIR = new URL("..", import.meta.url).pathname;

const OUT_DIR = `${ROOT_DIR}/release`;
const DENO_DIR = `${ROOT_DIR}/deno`;
const PATCH_DIR = `${ROOT_DIR}/patches`;
const LIBDENO_DIR = `${ROOT_DIR}/libdeno`;

const TAG = Deno.args[0];

if (!TAG) {
  console.error("Error: TAG argument required");
  Deno.exit(1);
}

// Remove existing deno directory
try {
  await Deno.remove(DENO_DIR, { recursive: true });
} catch {
  // Directory might not exist, ignore error
}

// Create deno directory
await Deno.mkdir(DENO_DIR, { recursive: true });

// Configure git safe directory
const gitConfigProcess = new Deno.Command("git", {
  args: ["config", "--global", "safe.directory", "*"],
}).spawn();

await gitConfigProcess.status;

// Clone deno repository
console.error(`Cloning deno repository (tag: ${TAG})...`);
const cloneProcess = new Deno.Command("git", {
  args: [
    "clone",
    "https://github.com/denoland/deno.git",
    "--branch",
    TAG,
    "--depth=1",
    DENO_DIR,
  ],
}).spawn();

const cloneStatus = await cloneProcess.status;
if (!cloneStatus.success) {
  console.error("Failed to clone repository");
  Deno.exit(cloneStatus.code);
}

// Create symlink
const symlinkTarget = `${DENO_DIR}/libdeno`;
try {
  await Deno.remove(symlinkTarget);
} catch {
  // Symlink might not exist, ignore error
}

await Deno.symlink(LIBDENO_DIR, symlinkTarget);

// Change to deno directory and apply patch
Deno.chdir(DENO_DIR);

// Apply patch
const applyProcess = new Deno.Command("git", {
  args: ["apply", '--ignore-space-change', '--ignore-whitespace', `${PATCH_DIR}/deno.patch`],
}).spawn();

const applyStatus = await applyProcess.status;
if (!applyStatus.success) {
  console.error("Failed to apply patch");
  Deno.exit(applyStatus.code);
}

// Git add all changes
const addProcess = new Deno.Command("git", {
  args: ["add", "."],
}).spawn();

await addProcess.status;

// Reset libdeno
const resetLibdenoProcess = new Deno.Command("git", {
  args: ["reset", `${DENO_DIR}/libdeno`],
}).spawn();

await resetLibdenoProcess.status;

// Reset Cargo.lock
const resetCargoProcess = new Deno.Command("git", {
  args: ["reset", `${DENO_DIR}/Cargo.lock`],
}).spawn();

await resetCargoProcess.status;

// Show git status
const statusProcess = new Deno.Command("git", {
  args: ["status"],
  stdout: "inherit",
  stderr: "inherit",
}).spawn();

await statusProcess.status;
