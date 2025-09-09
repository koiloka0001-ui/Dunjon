extends CanvasLayer

## Developer Room Menu
## Allows hot-swapping between rooms during development

@onready var room_dropdown: OptionButton = $Control/MenuContainer/RoomSelection/RoomDropdown
@onready var load_button: Button = $Control/MenuContainer/LoadButton
@onready var close_button: Button = $Control/MenuContainer/CloseButton
@onready var preview_container: Control = $Control/MenuContainer/PreviewContainer
@onready var preview_label: Label = $Control/MenuContainer/PreviewContainer/PreviewLabel
@onready var preview_image: TextureRect = $Control/MenuContainer/PreviewContainer/PreviewImage

var room_importer: Node
var main_scene: Node

func _ready():
	print("[DevRoomMenu] DevRoomMenu _ready() called")
	
	# Connect signals
	load_button.pressed.connect(_on_load_room_pressed)
	close_button.pressed.connect(_on_close_pressed)
	room_dropdown.item_selected.connect(_on_room_selected)
	
	# Get references to main scene and room importer
	main_scene = get_tree().current_scene
	print("[DevRoomMenu] Main scene: ", main_scene)
	
	# Access the room_importer variable directly from the main scene
	if main_scene.has_method("get") and main_scene.get("room_importer"):
		room_importer = main_scene.room_importer
		print("[DevRoomMenu] ✅ Got room_importer reference")
	else:
		print("[DevRoomMenu] ❌ Could not access room_importer from main scene")
		room_importer = null
	
	# Scan for available rooms
	scan_available_rooms()
	
	# Hide by default
	visible = false
	print("[DevRoomMenu] DevRoomMenu ready, visible = ", visible)

func _input(event):
	if event.is_action_pressed("dev_menu"):
		print("[DevRoomMenu] Input detected! Toggling visibility...")
		toggle_visibility()
		get_viewport().set_input_as_handled()  # Prevent the event from propagating

func scan_available_rooms():
	"""Scan for available room files using RoomManager"""
	
	# Clear existing options
	room_dropdown.clear()
	
	# Add default option
	room_dropdown.add_item("Select a room...")
	
	# Get available rooms from RoomManager
	var available_rooms = main_scene.room_manager.get_available_rooms()
	var current_room_id = get_current_room_id()
	
	for i in range(available_rooms.size()):
		var room_id = available_rooms[i]
		room_dropdown.add_item(room_id)
		print("[DevRoomMenu] Found room: ", room_id)
		
		# Select current room if it matches
		if room_id == current_room_id:
			room_dropdown.selected = i + 1  # +1 because of the "Select a room..." item
	
	print("[DevRoomMenu] ✅ Scanned ", available_rooms.size(), " rooms total")
	if current_room_id != "":
		print("[DevRoomMenu] Current room: ", current_room_id)

func _on_load_room_pressed():
	"""Load the selected room"""
	var selected_index = room_dropdown.selected
	if selected_index <= 0:  # First item is "Select a room..."
		print("[DevRoomMenu] ❌ No room selected")
		return
	
	var room_id = room_dropdown.get_item_text(selected_index)
	
	print("[DevRoomMenu] 🏠 Loading room: ", room_id)
	
	# Load the room using the main scene's room loading system
	if main_scene.has_method("load_room"):
		main_scene.load_room(room_id)
		print("[DevRoomMenu] ✅ Room loaded successfully")
		# Hide menu after successful load
		visible = false
	else:
		print("[DevRoomMenu] ❌ Main scene does not have load_room method")

func _on_close_pressed():
	"""Close the developer menu"""
	visible = false

func get_current_room_id() -> String:
	"""Get the current room ID from the main scene"""
	if main_scene and main_scene.has_method("get_current_room_id"):
		return main_scene.get_current_room_id()
	
	# Fallback: try to get from the current room node
	var current_room = main_scene.get_node("CurrentRoom") if main_scene else null
	if current_room:
		# Try to extract room ID from the room's metadata or name
		var room_name = current_room.name
		if room_name.begins_with("Room_"):
			return room_name.substr(5)  # Remove "Room_" prefix
		elif room_name == "CurrentRoom":
			# Default fallback
			return "A1"
	
	return ""

func _on_room_selected(index: int):
	"""Handle room selection in dropdown"""
	if index <= 0:  # First item is "Select a room..."
		clear_preview()
		return
	
	var room_id = room_dropdown.get_item_text(index)
	show_room_preview(room_id)

func show_room_preview(room_id: String):
	"""Show a preview of the selected room"""
	var room_path = "res://data/rooms/" + room_id + ".json"
	print("[DevRoomMenu] Showing preview for room: ", room_id)
	
	# Simple text-based preview for now
	show_room_info(room_id, room_path)

func show_room_info(room_id: String, room_path: String):
	"""Show room information as text preview"""
	if not FileAccess.file_exists(room_path):
		show_preview_error("Room file not found")
		return
	
	var file = FileAccess.open(room_path, FileAccess.READ)
	if not file:
		show_preview_error("Failed to open room file")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		show_preview_error("Failed to parse room data")
		return
	
	var room_data = json.data
	var info_text = "Room: " + room_id + "\n"
	info_text += "Size: " + str(room_data.width) + "x" + str(room_data.height) + "\n"
	
	# Count doors and entities
	var door_count = 0
	var entity_count = 0
	
	for layer in room_data.layers:
		if layer.type == "objectgroup":
			if layer.name == "Entities":
				entity_count = layer.objects.size() if layer.has("objects") else 0
			elif layer.name == "Metadata":
				if layer.has("objects"):
					for obj in layer.objects:
						if obj.has("properties"):
							for prop in obj.properties:
								if prop.name == "type" and prop.value == "door":
									door_count += 1
	
	info_text += "Doors: " + str(door_count) + "\n"
	info_text += "Entities: " + str(entity_count) + "\n"
	
	# Show basic room layout info
	info_text += "\nLayout: Basic dungeon room\n"
	info_text += "Tiles: Ground + Walls\n"
	
	preview_label.text = info_text
	preview_image.texture = null
	preview_container.visible = true

func create_preview_texture(preview_scene: Node2D, room_id: String):
	"""Create a texture preview of the room"""
	# Wait a frame for the room to be fully loaded
	await get_tree().process_frame
	
	# Create a viewport for rendering
	var viewport = SubViewport.new()
	viewport.size = Vector2(320, 240)  # Small preview size
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	
	# Add the preview scene to the viewport
	viewport.add_child(preview_scene)
	
	# Position the camera to show the room
	var camera = Camera2D.new()
	camera.position = Vector2(160, 120)  # Center of a 20x15 room (320x240 pixels)
	preview_scene.add_child(camera)
	
	# Force render
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await get_tree().process_frame
	
	# Get the texture
	var texture = viewport.get_texture()
	if texture:
		preview_image.texture = texture
		preview_label.text = "Preview: " + room_id
		preview_container.visible = true
		print("[DevRoomMenu] Preview created for room: ", room_id)
	else:
		show_preview_error("Failed to create preview texture")
	
	# Clean up
	viewport.queue_free()

func show_preview_error(message: String):
	"""Show an error message in the preview area"""
	preview_label.text = "Error: " + message
	preview_image.texture = null
	preview_container.visible = true

func clear_preview():
	"""Clear the preview area"""
	preview_container.visible = false
	preview_label.text = ""
	preview_image.texture = null

func toggle_visibility():
	"""Toggle the visibility of the developer menu"""
	visible = !visible
	print("[DevRoomMenu] Menu visibility: ", visible)
	if visible:
		# Refresh room list when opening
		scan_available_rooms()
		# Set focus to prevent immediate closing
		room_dropdown.grab_focus()
		# Clear preview when opening
		clear_preview()
