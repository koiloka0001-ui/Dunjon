extends Node

## RoomImporter - Handles importing room data from JSON and instantiating entities
## Parses Tiled JSON export format and creates appropriate Godot nodes

# Entity scene references - loaded dynamically for better error handling
var player_scene: PackedScene
var enemy_scene: PackedScene

# Track spawned entities to prevent duplicates
var spawned_entities: Array[Node] = []

func import_room_from_json(room_data: Dictionary, parent_node: Node) -> void:
	"""Import a room from JSON data and add entities to the parent node"""
	
	print_debug("[RoomImporter] 📁 Starting room import from JSON data")
	
	# Clear previous entities
	clear_spawned_entities()
	
	# Parse layers
	if not room_data.has("layers"):
		push_error("Room data missing 'layers' array")
		return
	
	var entities_found = 0
	var tile_layers_found = 0
	
	print_debug("[RoomImporter] 📋 Total layers to process: ", room_data.layers.size())
	
	for i in range(room_data.layers.size()):
		var layer = room_data.layers[i]
		print_debug("[RoomImporter] 🔍 Processing layer ", i, ": ", layer.name, " (type: ", layer.type, ")")
		if layer.type == "objectgroup" and layer.name == "Entities":
			print_debug("[RoomImporter] 🎯 Found Entities layer, parsing objects...")
			entities_found = parse_entities_layer(layer, parent_node)
		elif layer.type == "tilelayer":
			print_debug("[RoomImporter] 🗺️ Found tile layer: ", layer.name)
			parse_tile_layer(layer, parent_node)
			tile_layers_found += 1
		else:
			print_debug("[RoomImporter] ⚠️ Skipping layer: ", layer.name, " (type: ", layer.type, ")")
	
	print_debug("[RoomImporter] 📊 Total objects processed: ", entities_found)
	print_debug("[RoomImporter] 🗺️ Total tile layers processed: ", tile_layers_found)

func parse_entities_layer(layer: Dictionary, parent_node: Node) -> int:
	"""Parse the Entities layer and spawn appropriate objects"""
	
	if not layer.has("objects"):
		print_debug("[RoomImporter] ⚠️ No objects found in Entities layer")
		return 0
	
	var object_count = layer.objects.size()
	print_debug("[RoomImporter] 🔍 Found ", object_count, " objects in Entities layer")
	
	for obj in layer.objects:
		parse_object(obj, parent_node)
	
	return object_count

func parse_tile_layer(layer: Dictionary, parent_node: Node) -> void:
	"""Parse a tile layer and create visual representation"""
	
	if not layer.has("data"):
		print_debug("[RoomImporter] ⚠️ No tile data found in layer: ", layer.name)
		return
	
	# Create a Control node for ColorRect children
	var layer_control = Control.new()
	layer_control.name = layer.name
	layer_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent_node.add_child(layer_control)
	
	# Parse CSV data
	var csv_data = layer.data.split("\n")
	var width = layer.width
	var height = layer.height
	
	print_debug("[RoomImporter] 🗺️ Parsing tile layer: ", layer.name, " (", width, "x", height, ")")
	
	for y in range(height):
		if y >= csv_data.size():
			break
		
		var row = csv_data[y].split(",")
		for x in range(width):
			if x >= row.size():
				break
			
			var tile_id = int(row[x])
			if tile_id > 0:  # Skip empty tiles (0)
				create_tile_visual(tile_id, x, y, layer_control)

func create_tile_visual(tile_id: int, x: int, y: int, parent: Control) -> void:
	"""Create a visual representation of a tile using Dunjon Tiles tileset"""
	
	# Calculate position for 32x32 tiles (no centering needed)
	var tile_position = Vector2(x * 32, y * 32)
	
	# Load the Dunjon Tiles tileset
	var tileset_texture = load("res://assets/tiles/dunjon_tileset.png")
	
	if not tileset_texture:
		# Fallback to individual assets if tileset not found
		create_tile_visual_fallback(tile_id, tile_position, parent)
		return
	
	# Create sprite for the tile
	var sprite = Sprite2D.new()
	sprite.texture = tileset_texture
	sprite.position = tile_position
	
	# Set up the region to show the correct tile from the tileset
	# Dunjon Tiles tileset: 96x32 pixels, 3 tiles of 32x32 each
	# Tile 0: empty (0,0) to (31,31)
	# Tile 1: ground (32,0) to (63,31) 
	# Tile 2: wall (64,0) to (95,31)
	
	match tile_id:
		0:  # Empty
			# Don't create anything for empty tiles
			return
		1:  # Ground
			sprite.region_enabled = true
			sprite.region_rect = Rect2(32, 0, 32, 32)  # Ground tile region
			parent.add_child(sprite)
			# print_debug("[RoomImporter] Ground tile placed at: ", tile_position)
		2:  # Wall
			sprite.region_enabled = true
			sprite.region_rect = Rect2(64, 0, 32, 32)  # Wall tile region
			parent.add_child(sprite)
			
			# Add collision shape for walls
			var static_body = StaticBody2D.new()
			static_body.position = tile_position + Vector2(16, 16)  # Center collision
			parent.add_child(static_body)
			
			var collision_shape = CollisionShape2D.new()
			var rectangle_shape = RectangleShape2D.new()
			rectangle_shape.size = Vector2(32, 32)  # Full tile size for collision
			collision_shape.shape = rectangle_shape
			static_body.add_child(collision_shape)
			
			# print_debug("[RoomImporter] Wall tile and collision at: ", tile_position)
		_:
			# Default fallback for unknown tile IDs
			create_tile_visual_fallback(tile_id, tile_position, parent)

func create_tile_visual_fallback(tile_id: int, tile_position: Vector2, parent: Control) -> void:
	"""Fallback method using individual assets or colored rectangles"""
	
	match tile_id:
		1:  # Ground
			var texture = load("res://assets/dirt_floor.png")
			if texture:
				var sprite = Sprite2D.new()
				sprite.texture = texture
				sprite.position = tile_position
				parent.add_child(sprite)
				print_debug("[RoomImporter] Ground tile (fallback) placed at: ", tile_position)
			else:
				# Fallback to colored rectangle
				var rect = ColorRect.new()
				rect.size = Vector2(32, 32)
				rect.position = tile_position
				rect.color = Color(0.55, 0.27, 0.07)  # Brown
				parent.add_child(rect)
				print_debug("[RoomImporter] Ground fallback rectangle at: ", tile_position)
		2:  # Wall
			var texture = load("res://assets/dungeon_wall.png")
			if texture:
				var sprite = Sprite2D.new()
				sprite.texture = texture
				sprite.position = tile_position
				parent.add_child(sprite)
				
				# Add collision shape for walls
				var static_body = StaticBody2D.new()
				static_body.position = tile_position + Vector2(16, 16)  # Center collision
				parent.add_child(static_body)
				
				var collision_shape = CollisionShape2D.new()
				var rectangle_shape = RectangleShape2D.new()
				rectangle_shape.size = Vector2(32, 32)  # Full tile size for collision
				collision_shape.shape = rectangle_shape
				static_body.add_child(collision_shape)
				
				print_debug("[RoomImporter] Wall tile (fallback) and collision at: ", tile_position)
			else:
				# Fallback to colored rectangle
				var rect = ColorRect.new()
				rect.size = Vector2(32, 32)
				rect.position = tile_position
				rect.color = Color(0.25, 0.25, 0.25)  # Dark gray
				parent.add_child(rect)
				print_debug("[RoomImporter] Wall fallback rectangle at: ", tile_position)
		_:
			# Default fallback for unknown tile IDs
			var rect = ColorRect.new()
			rect.size = Vector2(32, 32)
			rect.position = tile_position
			rect.color = Color(0.5, 0.5, 0.5)  # Default gray
			parent.add_child(rect)
			# print_debug("[RoomImporter] Unknown tile ID ", tile_id, " fallback at: ", tile_position)

func parse_object(obj: Dictionary, parent_node: Node) -> void:
	"""Parse a single object and spawn the appropriate entity"""
	
	# Get object type from properties
	var obj_type = get_object_type(obj)
	print_debug("[RoomImporter] 🔍 Processing object with type: '", obj_type, "'")
	
	match obj_type:
		"player_spawn":
			print_debug("[RoomImporter] 🎮 Player spawn marker detected!")
			spawn_player(obj, parent_node)
		"enemy_spawn":
			print_debug("[RoomImporter] 👹 Enemy spawn marker detected!")
			spawn_enemy(obj, parent_node)
		_:
			# Handle other entity types here in the future
			print_debug("[RoomImporter] ⚠️ Unknown object type: '", obj_type, "' - skipping")

func get_object_type(obj: Dictionary) -> String:
	"""Extract the type from object properties"""
	
	if not obj.has("properties"):
		return ""
	
	for prop in obj.properties:
		if prop.name == "type":
			return prop.value
	
	return ""

func spawn_player(obj: Dictionary, parent_node: Node) -> void:
	"""Spawn a player at the specified position"""
	
	# Check if player already exists
	if has_player_spawned():
		push_warning("Player already spawned in this room, skipping duplicate spawn")
		return
	
	# Load Player scene with error handling
	if not player_scene:
		player_scene = load("res://entities/player/Player.tscn")
		if player_scene == null:
			push_error("❌ Failed to load Player.tscn")
			return
	
	# Create player instance
	var player_instance = player_scene.instantiate()
	if player_instance == null:
		push_error("❌ Failed to instantiate Player scene")
		return
	
	# Set position (Tiled coordinates are already correct for 32x32 tiles)
	var spawn_pos = Vector2(obj.x, obj.y)
	player_instance.position = spawn_pos
	
	# Add to parent node
	parent_node.add_child(player_instance)
	spawned_entities.append(player_instance)
	
	print_debug("[RoomImporter] ✅ Player spawned at position: ", spawn_pos)
	
	# Debug: Draw a temporary rectangle to confirm positioning
	draw_debug_rectangle(parent_node, spawn_pos)

func spawn_enemy(obj: Dictionary, parent_node: Node) -> void:
	"""Spawn an enemy at the specified position"""
	
	# Load Enemy scene with error handling
	if not enemy_scene:
		enemy_scene = load("res://entities/enemy/Enemy.tscn")
		if enemy_scene == null:
			push_error("❌ Failed to load Enemy.tscn")
			return
	
	# Create enemy instance
	var enemy_instance = enemy_scene.instantiate()
	if enemy_instance == null:
		push_error("❌ Failed to instantiate Enemy scene")
		return
	
	# Set position (Tiled coordinates are already correct for 32x32 tiles)
	var spawn_pos = Vector2(obj.x, obj.y)
	enemy_instance.position = spawn_pos
	
	# Add to parent node
	parent_node.add_child(enemy_instance)
	spawned_entities.append(enemy_instance)
	
	print_debug("[RoomImporter] ✅ Enemy spawned at position: ", spawn_pos)
	
	# Debug: Draw a temporary rectangle to confirm positioning
	draw_debug_rectangle(parent_node, spawn_pos)

func has_player_spawned() -> bool:
	"""Check if a player has already been spawned"""
	
	for entity in spawned_entities:
		if entity.name == "Player":
			return true
	
	return false

func clear_spawned_entities() -> void:
	"""Remove all previously spawned entities"""
	
	for entity in spawned_entities:
		if is_instance_valid(entity):
			entity.queue_free()
	
	spawned_entities.clear()

func load_room_from_file(file_path: String, parent_node: Node) -> bool:
	"""Load a room from a JSON file and import it"""
	
	print_debug("[RoomImporter] 📂 Loading room from file: ", file_path)
	
	if not FileAccess.file_exists(file_path):
		push_error("Room file not found: " + file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open room file: " + file_path)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	print_debug("[RoomImporter] 📄 JSON file loaded successfully, parsing...")
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse JSON: " + json.get_error_message())
		return false
	
	var room_data = json.data
	if typeof(room_data) != TYPE_DICTIONARY:
		push_error("Invalid room data format")
		return false
	
	print_debug("[RoomImporter] ✅ JSON parsed successfully, importing room...")
	
	import_room_from_json(room_data, parent_node)
	return true

func draw_debug_rectangle(parent_node: Node, position: Vector2) -> void:
	"""Draw a temporary debug rectangle to confirm room tileset positioning"""
	
	# Create a simple debug rectangle
	var debug_rect = ColorRect.new()
	debug_rect.size = Vector2(32, 32)  # 32x32 pixel rectangle
	debug_rect.position = position
	debug_rect.color = Color.RED
	debug_rect.modulate.a = 0.5  # Semi-transparent
	
	parent_node.add_child(debug_rect)
	
	# Remove after 3 seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func(): debug_rect.queue_free(); timer.queue_free())
	parent_node.add_child(timer)
	timer.start()
	
	print_debug("[RoomImporter] 🔴 Debug rectangle drawn at: ", position, " (will disappear in 3 seconds)")
