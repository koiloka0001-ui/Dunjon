extends Camera2D

## Player-following camera with zoom control
## Provides smooth camera following and zoom functionality

@export var follow_speed: float = 5.0
@export var default_zoom: float = 2.0
@export var min_zoom: float = 1.0
@export var max_zoom: float = 4.0
@export var zoom_speed: float = 2.0

var target_player: Node2D
var target_zoom: float
var is_zooming: bool = false

func _ready():
	# Set initial zoom
	zoom = Vector2(default_zoom, default_zoom)
	target_zoom = default_zoom
	
	# Make this camera the active one
	make_current()
	
	# Try to find the player, but don't worry if not found yet
	# The player will be found in _physics_process when it's spawned
	target_player = get_tree().get_first_node_in_group("player")
	if not target_player:
		print_debug("[PlayerCamera] No player found yet, will retry in _physics_process")

func _physics_process(delta):
	if not target_player:
		# Try to find player again
		target_player = get_tree().get_first_node_in_group("player")
		return
	
	# Follow the player smoothly
	var target_position = target_player.global_position
	global_position = global_position.lerp(target_position, follow_speed * delta)
	
	# Handle zoom
	if is_zooming:
		zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_speed * delta)
		
		# Check if we're close enough to target zoom
		if abs(zoom.x - target_zoom) < 0.01:
			zoom = Vector2(target_zoom, target_zoom)
			is_zooming = false

func set_zoom_level(new_zoom: float, smooth: bool = true):
	"""Set camera zoom level"""
	target_zoom = clamp(new_zoom, min_zoom, max_zoom)
	
	if smooth:
		is_zooming = true
	else:
		zoom = Vector2(target_zoom, target_zoom)
		is_zooming = false
	
	print_debug("[PlayerCamera] Zoom set to: ", target_zoom)

func zoom_in(amount: float = 0.5, smooth: bool = true):
	"""Zoom in by the specified amount"""
	set_zoom_level(target_zoom + amount, smooth)

func zoom_out(amount: float = 0.5, smooth: bool = true):
	"""Zoom out by the specified amount"""
	set_zoom_level(target_zoom - amount, smooth)

func reset_zoom(smooth: bool = true):
	"""Reset zoom to default level"""
	set_zoom_level(default_zoom, smooth)

func get_current_zoom() -> float:
	"""Get current zoom level"""
	return zoom.x

func set_follow_speed(speed: float):
	"""Set how fast the camera follows the player"""
	follow_speed = speed
