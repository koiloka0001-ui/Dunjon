extends Node2D

func _ready() -> void:
	print("[Main] Scene loaded")
	
	# Handle CLI arguments for headless replay
	var args = OS.get_cmdline_args()
	var replay_arg_index = args.find("--replay")
	if replay_arg_index != -1 and args.size() > replay_arg_index + 1:
		var replay_file = args[replay_arg_index + 1]
		RecordingManager.start_playback(replay_file)
		DigestManager.start_digest_log(replay_file.replace(".jsonl", ".digest.jsonl"))
		print("[Main] CLI replay mode - loading:", replay_file)

func _process(_delta: float) -> void:
	# Debug hotkey for replay (only in non-headless mode)
	if not OS.has_feature("headless") and Input.is_action_just_pressed("debug_replay"):
		var replay_path = "res://../recordings/last.jsonl"
		RecordingManager.start_playback(replay_path)
		print("[Main] F10 pressed - starting replay from:", replay_path)

# Input wrapper function for replay mode
func get_inputs() -> Dictionary:
	if RecordingManager.playing_back:
		return RecordingManager.get_replay_inputs()
	return {
		"left": Input.is_action_pressed("ui_left"),
		"right": Input.is_action_pressed("ui_right"),
		"up": Input.is_action_pressed("ui_up"),
		"down": Input.is_action_pressed("ui_down"),
		"attack": Input.is_action_pressed("attack"),
		"dash": Input.is_action_pressed("dash")
	}
