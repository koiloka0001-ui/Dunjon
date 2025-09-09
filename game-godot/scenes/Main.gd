extends Node2D

# Room management
var room_manager: Node
var current_room: Node2D
var current_room_id: String = "A1"  # Track current room ID

# Developer menu
var dev_menu: CanvasLayer

# Options menu
var options_menu: CanvasLayer

# Camera reference
var player_camera: Camera2D

func _ready() -> void:
	print("[Main] Scene loaded")
	
	# Get camera reference
	player_camera = $PlayerCamera
	
	# Create room manager
	room_manager = preload("res://systems/RoomManager.gd").new()
	add_child(room_manager)
	
	# Connect to room manager signals
	room_manager.room_loaded.connect(_on_room_loaded)
	room_manager.room_switched.connect(_on_room_switched)
	
	# Load the first room
	load_room("A1")
	
	# Create developer menu
	create_dev_menu()
	
	# Create options menu
	create_options_menu()
	
	# Handle CLI arguments for headless replay
	var args = OS.get_cmdline_args()
	var replay_arg_index = args.find("--replay")
	if replay_arg_index != -1 and args.size() > replay_arg_index + 1:
		var replay_file = args[replay_arg_index + 1]
		RecordingManager.start_playback(replay_file)
		DigestManager.start_digest_log(replay_file.replace(".jsonl", ".digest.jsonl"))
		print("[Main] CLI replay mode - loading:", replay_file)

func load_room(room_id: String) -> void:
	"""Load a room by ID"""
	
	print("[Main] 🏠 Loading room: ", room_id)
	
	if room_manager.load_room(room_id):
		current_room_id = room_id
		current_room = room_manager.current_room
		print("[Main] ✅ Room loaded successfully")
	else:
		print("[Main] ❌ Failed to load room")

func get_current_room_id() -> String:
	"""Get the current room ID for the dev menu"""
	return room_manager.get_current_room_id()

func _on_room_loaded(room_id: String) -> void:
	"""Handle room loaded signal"""
	print("[Main] 🎉 Room loaded signal received: ", room_id)

func _on_room_switched(from_room: String, to_room: String) -> void:
	"""Handle room switched signal"""
	print("[Main] 🔄 Room switched from ", from_room, " to ", to_room)

func create_dev_menu() -> void:
	"""Create and setup the developer room menu"""
	dev_menu = preload("res://ui/DevRoomMenu_working.tscn").instantiate()
	add_child(dev_menu)
	print("[Main] ✅ Developer menu created")
	print("[Main] Dev menu visible: ", dev_menu.visible)
	print("[Main] Dev menu in scene tree: ", dev_menu.is_inside_tree())

func create_options_menu() -> void:
	"""Create and setup the options menu"""
	options_menu = preload("res://scenes/ui/OptionsMenu_working.tscn").instantiate()
	add_child(options_menu)
	options_menu.visible = false
	print("[Main] ✅ Options menu created")
	print("[Main] Options menu visible: ", options_menu.visible)
	print("[Main] Options menu in scene tree: ", options_menu.is_inside_tree())

func toggle_options_menu() -> void:
	"""Toggle the options menu visibility"""
	if options_menu:
		options_menu.visible = !options_menu.visible
		print("[Main] Options menu toggled, visible: ", options_menu.visible)

func _process(_delta: float) -> void:
	# Debug hotkey for replay (only in non-headless mode)
	if not OS.has_feature("headless") and Input.is_action_just_pressed("debug_replay"):
		var replay_path = "res://../recordings/last.jsonl"
		RecordingManager.start_playback(replay_path)
		print("[Main] F10 pressed - starting replay from:", replay_path)
	
	# Options menu toggle
	if Input.is_action_just_pressed("options_menu"):
		toggle_options_menu()
	
	# Camera zoom controls
	handle_camera_zoom()

func handle_camera_zoom():
	"""Handle camera zoom input"""
	if not player_camera:
		return
	
	# Mouse wheel zoom
	var zoom_input = Input.get_axis("ui_zoom_in", "ui_zoom_out")
	if zoom_input != 0:
		if zoom_input > 0:
			player_camera.zoom_in(0.2)
		else:
			player_camera.zoom_out(0.2)
	
	# Keyboard zoom controls (Page Up/Down)
	if Input.is_action_just_pressed("ui_page_up"):
		player_camera.zoom_in(0.5)
	elif Input.is_action_just_pressed("ui_page_down"):
		player_camera.zoom_out(0.5)
	
	# Reset zoom with Home key
	if Input.is_action_just_pressed("ui_home"):
		player_camera.reset_zoom()

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
