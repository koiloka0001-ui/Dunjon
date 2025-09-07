#!/usr/bin/env node

/**
 * Test Replay Runner
 * 
 * Simple test to verify the replay runner works
 */

const { exec } = require("child_process");
const path = require("path");

console.log("[TestReplay] Testing replay runner...");

const testRecording = path.resolve("recordings/test-recording.jsonl");
const command = `node tools/replay-runner.js "${testRecording}"`;

console.log(`[TestReplay] Running: ${command}`);

exec(command, (error, stdout, stderr) => {
  if (error) {
    console.error(`[TestReplay] Error: ${error}`);
    return;
  }
  
  console.log(`[TestReplay] stdout: ${stdout}`);
  if (stderr) {
    console.log(`[TestReplay] stderr: ${stderr}`);
  }
  
  console.log("[TestReplay] Test completed successfully!");
});
