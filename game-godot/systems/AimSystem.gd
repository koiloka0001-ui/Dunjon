extends Node

@export var base_aim_speed: float = 5.0
@export var aim_snap_distance: float = 50.0

var target_position: Vector2
var current_aim_position: Vector2

func _ready() -> void:
	# Initialize aim position
	current_aim_position = Vector2.ZERO

func aim_towards(target: Vector2, current_pos: Vector2, delta: float) -> Vector2:
	target_position = target
	var aim_direction = (target - current_pos).normalized()
	
	# Get aim assist multiplier from options
	var aim_assist = OptionsManager.get_option("aim_assist")
	
	# Apply aim assist - higher values make aiming "stickier" to targets
	var assist_strength = aim_assist * 0.5  # Scale down for reasonable effect
	var assisted_direction = aim_direction.lerp(Vector2.ZERO, assist_strength)
	
	# Calculate aim speed with assist influence
	var aim_speed = base_aim_speed * (1.0 + aim_assist)
	
	# Move towards target with assist
	current_aim_position = current_aim_position.move_toward(target, aim_speed * delta)
	
	return current_aim_position

func get_aim_direction(from_pos: Vector2, to_pos: Vector2) -> Vector2:
	var raw_direction = (to_pos - from_pos).normalized()
	
	# Apply aim assist to make targeting more forgiving
	var aim_assist = OptionsManager.get_option("aim_assist")
	var assist_angle = aim_assist * 15.0  # Up to 15 degrees of assist
	
	# Add slight angle correction based on assist level
	var corrected_direction = raw_direction.rotated(assist_angle * 0.1)
	
	return corrected_direction

func is_aiming_at_target(from_pos: Vector2, to_pos: Vector2, tolerance: float = 20.0) -> bool:
	var distance = from_pos.distance_to(to_pos)
	var aim_assist = OptionsManager.get_option("aim_assist")
	
	# Increase tolerance based on aim assist
	var assisted_tolerance = tolerance * (1.0 + aim_assist)
	
	return distance <= assisted_tolerance
