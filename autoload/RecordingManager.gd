extends Node

var file := null
var recording := false
var frame_count := 0

func start_recording(file_path: String) -> void:
	file = FileAccess.open(file_path, FileAccess.WRITE)
	recording = file != null
	frame_count = 0
	if recording:
		print("[Recording] Started:", file_path)

func record_frame(inputs: Dictionary) -> void:
	if not recording or file == null:
		return
	var line = {"frame": frame_count, "inputs": inputs}
	file.store_line(JSON.stringify(line))
	frame_count += 1

func stop_recording() -> void:
	if recording and file != null:
		file.close()
		print("[Recording] Stopped")
	recording = false
	file = null
