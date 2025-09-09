extends CanvasLayer

## Simplified Developer Room Menu

@onready var room_dropdown: OptionButton = $Control/MenuContainer/RoomSelection/RoomDropdown
@onready var load_button: Button = $Control/MenuContainer/LoadButton
@onready var close_button: Button = $Control/MenuContainer/CloseButton

var main_scene: Node

func _ready():
	print("[DevRoomMenu] Simple version ready")
	
	# Connect signals
	load_button.pressed.connect(_on_load_room_pressed)
	close_button.pressed.connect(_on_close_pressed)
	room_dropdown.item_selected.connect(_on_room_selected)
	
	# Get references to main scene
	main_scene = get_tree().current_scene
	print("[DevRoomMenu] Main scene: ", main_scene)
	
	# Scan for available rooms
	scan_available_rooms()
	
	# Hide by default
	visible = false
	print("[DevRoomMenu] DevRoomMenu ready, visible = ", visible)

func _input(event):
	if event.is_action_pressed("dev_menu"):
		print("[DevRoomMenu] Input detected! Toggling visibility...")
		toggle_visibility()
		get_viewport().set_input_as_handled()

func toggle_visibility():
	visible = !visible
	print("[DevRoomMenu] Visibility toggled to: ", visible)

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

func _on_room_selected(index: int):
	"""Handle room selection"""
	if index <= 0:
		return
	
	var room_id = room_dropdown.get_item_text(index)
	print("[DevRoomMenu] Room selected: ", room_id)

func get_current_room_id() -> String:
	"""Get the current room ID from the main scene"""
	if main_scene and main_scene.has_method("get_current_room_id"):
		return main_scene.get_current_room_id()
	return ""
