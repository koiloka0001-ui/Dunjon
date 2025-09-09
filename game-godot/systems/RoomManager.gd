extends Node

## RoomManager - Centralized room management system
## Handles loading, validation, and switching between rooms

signal room_loaded(room_id: String)
signal room_switched(from_room: String, to_room: String)

var room_importer: Node
var current_room: Node2D
var current_room_id: String = ""
var available_rooms: Array[String] = []

func _ready() -> void:
	"""Initialize the room manager"""
	print("[RoomManager] 🏠 Initializing room management system")
	
	# Create room importer
	room_importer = preload("res://systems/RoomImporter.gd").new()
	add_child(room_importer)
	
	# Scan for available rooms
	scan_available_rooms()
	
	print("[RoomManager] ✅ Room manager ready with ", available_rooms.size(), " rooms")

func scan_available_rooms() -> void:
	"""Scan the data/rooms directory for available room files"""
	var rooms_dir = "res://data/rooms/"
	var dir = DirAccess.open(rooms_dir)
	
	if dir == null:
		push_error("Could not open rooms directory: " + rooms_dir)
		return
	
	available_rooms.clear()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			var room_id = file_name.get_basename()
			available_rooms.append(room_id)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Sort rooms alphabetically
	available_rooms.sort()
	print("[RoomManager] 📋 Found rooms: ", available_rooms)

func load_room(room_id: String) -> bool:
	"""Load a room by ID"""
	if room_id not in available_rooms:
		push_error("Room not found: " + room_id)
		return false
	
	var room_path = "res://data/rooms/" + room_id + ".json"
	print("[RoomManager] 🏠 Loading room: ", room_id)
	
	# Clear existing room
	if current_room:
		var old_room_id = current_room_id
		current_room.queue_free()
		current_room = null
		room_switched.emit(old_room_id, room_id)
	
	# Create new room container
	current_room = Node2D.new()
	current_room.name = "CurrentRoom"
	add_child(current_room)
	
	# Load room using RoomImporter
	if room_importer.load_room_from_file(room_path, current_room):
		current_room_id = room_id
		room_loaded.emit(room_id)
		print("[RoomManager] ✅ Room loaded successfully: ", room_id)
		return true
	else:
		push_error("Failed to load room: " + room_id)
		current_room.queue_free()
		current_room = null
		return false

func get_current_room_id() -> String:
	"""Get the current room ID"""
	return current_room_id

func get_available_rooms() -> Array[String]:
	"""Get list of available room IDs"""
	return available_rooms.duplicate()

func validate_room(room_id: String) -> bool:
	"""Validate that a room file is properly formatted"""
	var room_path = "res://data/rooms/" + room_id + ".json"
	
	if not FileAccess.file_exists(room_path):
		push_error("Room file not found: " + room_path)
		return false
	
	var file = FileAccess.open(room_path, FileAccess.READ)
	if not file:
		push_error("Failed to open room file: " + room_path)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse room JSON: " + json.get_error_message())
		return false
	
	var room_data = json.data
	if typeof(room_data) != TYPE_DICTIONARY:
		push_error("Invalid room data format")
		return false
	
	# Check for required fields
	if not room_data.has("tilewidth") or not room_data.has("tileheight"):
		push_error("Room missing tile dimensions")
		return false
	
	if room_data.tilewidth != 32 or room_data.tileheight != 32:
		push_error("Room must use 32x32 tiles (found " + str(room_data.tilewidth) + "x" + str(room_data.tileheight) + ")")
		return false
	
	if not room_data.has("layers"):
		push_error("Room missing layers array")
		return false
	
	print("[RoomManager] ✅ Room validation passed: ", room_id)
	return true

func validate_all_rooms() -> Dictionary:
	"""Validate all available rooms and return results"""
	var results = {}
	
	for room_id in available_rooms:
		results[room_id] = validate_room(room_id)
	
	return results

func reload_current_room() -> bool:
	"""Reload the current room"""
	if current_room_id == "":
		push_warning("No current room to reload")
		return false
	
	return load_room(current_room_id)

