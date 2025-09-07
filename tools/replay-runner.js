#!/usr/bin/env node

/**
 * Replay Runner
 * 
 * Usage:
 *   node tools/replay-runner.js recordings/2025-09-06_12-30-42.jsonl
 * 
 * Runs Godot in headless mode with a recording file.
 */

const { spawn } = require("child_process");
const path = require("path");

const args = process.argv.slice(2);
if (args.length < 1) {
  console.error("Usage: node tools/replay-runner.js <recording.jsonl>");
  process.exit(1);
}

const recordingPath = path.resolve(args[0]);

console.log(`[ReplayRunner] Running with recording: ${recordingPath}`);

const godot = spawn("godot", [
  "--headless",
  "--path", "game-godot",
  "--", "--replay", recordingPath
]);

godot.stdout.on("data", (data) => {
  process.stdout.write(data.toString());
});

godot.stderr.on("data", (data) => {
  process.stderr.write(data.toString());
});

godot.on("close", (code) => {
  console.log(`[ReplayRunner] Godot exited with code ${code}`);
  process.exit(code);
});
