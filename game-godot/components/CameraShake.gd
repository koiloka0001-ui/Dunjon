extends Node

@export var shake_intensity: float = 1.0
@export var shake_duration: float = 0.5
@export var shake_frequency: float = 20.0

var camera: Camera2D
var shake_timer: float = 0.0
var original_offset: Vector2

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	if camera:
		original_offset = camera.offset

func _process(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		apply_shake()
	else:
		# Return to original position
		if camera:
			camera.offset = original_offset

func apply_shake() -> void:
	if not camera:
		return
	
	# Get screen shake multiplier from options
	var shake_multiplier = OptionsManager.get_option("screen_shake")
	var current_intensity = shake_intensity * shake_multiplier
	
	# Apply shake with reduced intensity based on options
	var shake_x = sin(Time.get_time_dict_from_system()["second"] * shake_frequency) * current_intensity
	var shake_y = cos(Time.get_time_dict_from_system()["second"] * shake_frequency * 1.1) * current_intensity
	
	camera.offset = original_offset + Vector2(shake_x, shake_y)

func start_shake(intensity: float = 1.0, duration: float = 0.5) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
