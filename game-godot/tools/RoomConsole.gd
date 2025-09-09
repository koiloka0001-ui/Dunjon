extends Node

## Room Console Tool
## Provides console commands for room management and previewing
## Usage: Call these functions from the console or other scripts

var room_importer: Node

func _ready():
	room_importer = preload("res://systems/RoomImporter.gd").new()
	add_child(room_importer)
	print("[RoomConsole] Ready - available commands:")
	print("  - list_rooms() - List all available rooms")
	print("  - room_info('A1') - Get info about a specific room")
	print("  - preview_room('A1') - Preview a room in the current scene")

func list_rooms():
	"""List all available rooms"""
	var rooms_dir = "res://data/rooms/"
	var dir = DirAccess.open(rooms_dir)
	
	if dir == null:
		print("[RoomConsole] ❌ Could not open rooms directory")
		return []
	
	var rooms = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			var room_id = file_name.get_basename()
			rooms.append(room_id)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	print("[RoomConsole] Available rooms: ", rooms)
	return rooms

func room_info(room_id: String):
	"""Get detailed information about a room"""
	var room_path = "res://data/rooms/" + room_id + ".json"
	
	if not FileAccess.file_exists(room_path):
		print("[RoomConsole] ❌ Room file not found: ", room_path)
		return null
	
	var file = FileAccess.open(room_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("[RoomConsole] ❌ Failed to parse room data")
		return null
	
	var room_data = json.data
	print("[RoomConsole] Room Info for ", room_id, ":")
	print("  Size: ", room_data.width, "x", room_data.height)
	print("  Layers: ", room_data.layers.size())
	
	# Analyze layers
	for layer in room_data.layers:
		print("  Layer: ", layer.name, " (", layer.type, ")")
		if layer.type == "objectgroup" and layer.has("objects"):
			print("    Objects: ", layer.objects.size())
			for obj in layer.objects:
				if obj.has("properties"):
					for prop in obj.properties:
						if prop.name == "type":
							print("      - ", prop.value)
	
	return room_data

func preview_room(room_id: String):
	"""Preview a room by temporarily loading it"""
	print("[RoomConsole] Previewing room: ", room_id)
	
	# This would need to be called from a scene that can display the room
	# For now, just show the room info
	room_info(room_id)
