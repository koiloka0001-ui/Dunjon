extends Node2D

## Room Viewer Tool
## A simple tool to preview rooms before loading them
## Usage: Add this script to a scene and call preview_room("A1")

var room_importer: Node

func _ready():
	# Create room importer
	room_importer = preload("res://systems/RoomImporter.gd").new()
	add_child(room_importer)
	print("[RoomViewer] Ready - use preview_room('A1') to preview a room")

func preview_room(room_id: String):
	"""Preview a room by loading it temporarily"""
	var room_path = "res://data/rooms/" + room_id + ".json"
	print("[RoomViewer] Previewing room: ", room_id)
	
	# Clear existing preview
	clear_preview()
	
	# Create preview container
	var preview_container = Node2D.new()
	preview_container.name = "RoomPreview"
	add_child(preview_container)
	
	# Load the room
	if room_importer.load_room_from_file(room_path, preview_container):
		print("[RoomViewer] ✅ Room preview loaded successfully")
		# Auto-remove after 10 seconds
		var timer = Timer.new()
		timer.wait_time = 10.0
		timer.one_shot = true
		timer.timeout.connect(func(): clear_preview())
		add_child(timer)
		timer.start()
	else:
		print("[RoomViewer] ❌ Failed to load room preview")

func clear_preview():
	"""Clear the current room preview"""
	var preview = get_node_or_null("RoomPreview")
	if preview:
		preview.queue_free()
		print("[RoomViewer] Preview cleared")

func _input(event):
	# Press R to reload current preview
	if event.is_action_pressed("ui_accept"):  # Space key
		# Get the last previewed room (you could store this in a variable)
		preview_room("A1")  # Default to A1 for testing
