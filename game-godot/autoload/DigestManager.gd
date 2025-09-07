extends Node

var file: FileAccess
var digest_logging := false
var frame_count := 0

# Start digest logging
func start_digest_log(file_path: String) -> void:
	file = FileAccess.open(file_path, FileAccess.WRITE)
	digest_logging = file != null
	frame_count = 0
	if digest_logging:
		print("[Digest] Started logging to:", file_path)

# Log game state for this frame
func log_frame_state(state: Dictionary) -> void:
	if not digest_logging or file == null:
		return
	var line = {"frame": frame_count, "state": state}
	file.store_line(JSON.stringify(line))
	frame_count += 1

# Stop digest logging
func stop_digest_log() -> void:
	if digest_logging and file != null:
		file.close()
		print("[Digest] Stopped logging")
	digest_logging = false
	file = null
