extends Node

var file: FileAccess
var recording := false
var playing_back := false
var frame_count := 0
var replay_data := []
var replay_index := 0

# Start recording
func start_recording(file_path: String) -> void:
	file = FileAccess.open(file_path, FileAccess.WRITE)
	recording = file != null
	frame_count = 0
	if recording:
		print("[Recording] Started:", file_path)

# Record one frame
func record_frame(inputs: Dictionary) -> void:
	if not recording or file == null:
		return
	var line = {"frame": frame_count, "inputs": inputs}
	file.store_line(JSON.stringify(line))
	frame_count += 1

# Stop recording
func stop_recording() -> void:
	if recording and file != null:
		file.close()
		# Copy to last.jsonl for easy replay access
		var last_path = "res://../recordings/last.jsonl"
		var source_file = FileAccess.open(file.get_path(), FileAccess.READ)
		var dest_file = FileAccess.open(last_path, FileAccess.WRITE)
		if source_file and dest_file:
			while not source_file.eof_reached():
				var line = source_file.get_line()
				if line.strip_edges() != "":
					dest_file.store_line(line)
			source_file.close()
			dest_file.close()
			print("[Recording] Copied to last.jsonl")
		print("[Recording] Stopped")
	recording = false
	file = null

# Start playback
func start_playback(file_path: String) -> void:
	replay_data.clear()
	var replay_file = FileAccess.open(file_path, FileAccess.READ)
	if replay_file:
		while not replay_file.eof_reached():
			var line = replay_file.get_line()
			if line.strip_edges() != "":
				replay_data.append(JSON.parse_string(line))
		replay_file.close()
		playing_back = true
		replay_index = 0
		print("[Replay] Loaded:", file_path)

# Get inputs for this frame during playback
func get_replay_inputs() -> Dictionary:
	if not playing_back or replay_index >= replay_data.size():
		return {}
	var frame_inputs = replay_data[replay_index]["inputs"]
	replay_index += 1
	return frame_inputs

# Stop playback
func stop_playback() -> void:
	playing_back = false
	replay_data.clear()
	replay_index = 0
	print("[Replay] Stopped")
