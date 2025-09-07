# Recordings Folder

- All game input recordings are stored here as JSONL files.
- One JSON object per line, e.g.:
  {"frame": 0, "inputs": {"left": true, "attack": false}}

## Naming Convention
- `<timestamp>.jsonl` for recorded sessions.
- `last.jsonl` may be a copy or symlink of the most recent run.