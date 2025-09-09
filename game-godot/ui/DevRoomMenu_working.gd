extends CanvasLayer

## Developer Room Menu - Modeled after TuningHUD

@onready var room_dropdown: OptionButton = $PanelContainer/VBoxContainer/RoomSelection/RoomDropdown
@onready var load_button: Button = $PanelContainer/VBoxContainer/LoadButton
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var main_scene: Node
var available_rooms: Array = []

func _ready() -> void:
	# Get main scene reference
	main_scene = get_tree().current_scene
	
	# Connect signals
	load_button.pressed.connect(_on_load_room_pressed)
	close_button.pressed.connect(_on_close_pressed)
	room_dropdown.item_selected.connect(_on_room_selected)
	
	# Scan for available rooms
	scan_available_rooms()
	visible = false
	print("[DevRoomMenu] Ready - loaded room menu")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("dev_menu"):
		visible = !visible
		print("[DevRoomMenu] Toggled visibility: ", visible)

func get_available_rooms() -> Array:
	"""Get available rooms from RoomManager"""
	if main_scene and main_scene.has_method("get") and main_scene.get("room_manager"):
		return main_scene.room_manager.get_available_rooms()
	return []

func scan_available_rooms():
	"""Scan for available room files using RoomManager"""
	
	# Clear existing options
	room_dropdown.clear()
	
	# Add default option
	room_dropdown.add_item("Select a room...")
	
	# Get available rooms from RoomManager
	available_rooms = get_available_rooms()
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
	if main_scene and main_scene.has_method("load_room"):
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
	"""Get current room ID from main scene"""
	if main_scene and main_scene.has_method("get_current_room_id"):
		return main_scene.get_current_room_id()
	return ""
