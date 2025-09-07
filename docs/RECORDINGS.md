# Replay Recording Specification

## Folder
- All files are stored in `/recordings/` at project root.
- This folder is versioned with `.gitkeep` but actual recordings are ignored in `.gitignore`.

## File Naming
- Files are named using ISO timestamp format:

`YYYY-MM-DD_HH-MM-SS.jsonl`

Example: `2025-09-06_12-30-42.jsonl`

- A symlink or copy named `last.jsonl` may always point to the most recent recording.

## File Format
- Each file is **JSON Lines**: one JSON object per line.
- Schema:
```json
{
  "frame": <int>,
  "inputs": {
    "left": <bool>,
    "right": <bool>,
    "up": <bool>,
    "down": <bool>,
    "attack": <bool>,
    "dash": <bool>
  }
}
```

Example:
```
{"frame": 0, "inputs": {"left": true, "attack": false}}
{"frame": 1, "inputs": {"left": true, "attack": true}}
```

## Usage
- Engine writes these during active recording.
- Tools may read them for replay, determinism checking, and debugging.
