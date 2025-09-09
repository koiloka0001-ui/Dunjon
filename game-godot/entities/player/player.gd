extends CharacterBody2D

## Player character controller with HFSM structure
## Handles movement, input, and state-based behavior

# Player stats
@export var max_health: int = 6
@export var max_stamina: int = 5
@export var move_speed_px_s: float = 200.0

# TuningHUD reference
var tuning_hud: Node

var health: int
var stamina: int

# HFSM State Management
var current_state: PlayerState
var state_stack: Array[PlayerState] = []

# Input handling
var inputs: Dictionary = {}
var last_input_direction: Vector2 = Vector2.RIGHT  # Store last non-zero input direction for dash

func _ready():
	# Get TuningHUD reference
	tuning_hud = get_node("/root/TuningHUD")
	
	# Add to player group for easy finding
	add_to_group("player")
	
	# Initialize stats
	health = max_health
	stamina = max_stamina
	
	# Center the sprite properly
	var sprite = $Sprite
	if sprite:
		sprite.offset = Vector2(-16, -16)  # Center the 32x32 sprite
		# Add a colored rectangle as placeholder
		var rect = ColorRect.new()
		rect.size = Vector2(32, 32)
		rect.position = Vector2(-16, -16)
		rect.color = Color.BLUE
		add_child(rect)
	
	# Start in IdleState
	change_state(IdleState.new())
	
	# Connect to events
	# TODO: Connect to room_cleared signal when RoomGates system is implemented
	# EventBus.room_cleared.connect(_on_room_cleared)

func _physics_process(delta):
	# Debug: Check if any key is pressed at all
	if Input.is_anything_pressed():
		print("[Player] Something is pressed!")
	
	# Get inputs (handles replay mode)
	inputs = get_inputs()
	
	# Handle movement input directly here for consistent behavior
	handle_movement_input()
	
	# Update current state
	if current_state:
		current_state.update(delta)
		current_state.handle_input(inputs)
	
	# Apply movement
	move_and_slide()

func handle_movement_input():
	"""Handle movement input using Input.get_vector for smooth control"""
	# Debug individual key presses
	var left_pressed = Input.is_action_pressed("move_left")
	var right_pressed = Input.is_action_pressed("move_right")
	var up_pressed = Input.is_action_pressed("move_up")
	var down_pressed = Input.is_action_pressed("move_down")
	
	# Test built-in UI actions as well
	var ui_left_pressed = Input.is_action_pressed("ui_left")
	var ui_right_pressed = Input.is_action_pressed("ui_right")
	var ui_up_pressed = Input.is_action_pressed("ui_up")
	var ui_down_pressed = Input.is_action_pressed("ui_down")
	
	# Debug any key press
	if left_pressed or right_pressed or up_pressed or down_pressed:
		print("[Player] Custom key pressed - Left:", left_pressed, " Right:", right_pressed, " Up:", up_pressed, " Down:", down_pressed)
	
	if ui_left_pressed or ui_right_pressed or ui_up_pressed or ui_down_pressed:
		print("[Player] UI key pressed - Left:", ui_left_pressed, " Right:", ui_right_pressed, " Up:", ui_up_pressed, " Down:", ui_down_pressed)
	
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Also try built-in UI actions
	var ui_input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Use UI input if custom input doesn't work
	if input_vector.length() == 0 and ui_input_vector.length() > 0:
		input_vector = ui_input_vector
		print("[Player] Using UI input vector: ", input_vector)
	
	# Debug input detection
	if input_vector.length() > 0:
		print("[Player] Input detected: ", input_vector)
	
	# Store last non-zero direction for dash
	if input_vector.length() > 0:
		last_input_direction = input_vector.normalized()
		print("[Player] Last input direction updated: ", last_input_direction)
	
	# Apply movement based on input
	if input_vector.length() > 0:
		# Use tuning value if available, otherwise use default
		var speed = move_speed_px_s
		if tuning_hud and tuning_hud.has_method("get_value"):
			speed = tuning_hud.get_value("player_speed", move_speed_px_s)
		velocity = input_vector.normalized() * speed
		print("[Player] Moving with velocity: ", velocity)
	else:
		velocity = Vector2.ZERO

func get_inputs() -> Dictionary:
	# Check if we're in replay mode
	if RecordingManager.playing_back:
		return RecordingManager.get_replay_inputs()
	
	# Normal input handling using the new input map actions
	return {
		"left": Input.is_action_pressed("move_left"),
		"right": Input.is_action_pressed("move_right"),
		"up": Input.is_action_pressed("move_up"),
		"down": Input.is_action_pressed("move_down"),
		"attack": Input.is_action_just_pressed("attack") if InputMap.has_action("attack") else false,
		"dash": Input.is_action_just_pressed("dash") if InputMap.has_action("dash") else false
	}

func change_state(new_state: PlayerState):
	if current_state:
		current_state.exit()
		print("[Player] Exiting state: ", current_state.get_state_name())
	
	current_state = new_state
	current_state.player = self
	current_state.enter()
	print("[Player] Entering state: ", current_state.get_state_name())

func push_state(new_state: PlayerState):
	if current_state:
		state_stack.push_back(current_state)
	change_state(new_state)

func pop_state():
	if state_stack.size() > 0:
		change_state(state_stack.pop_back())

# Event handlers
func _on_room_cleared():
	print_debug("[Player] Room cleared!")

# Input-based state transitions
func handle_dash_input():
	if current_state and current_state.can_dash():
		change_state(DashState.new())

func handle_damage():
	if current_state and current_state.can_be_hurt():
		change_state(HurtState.new())

# Base State Class
class PlayerState:
	var player: CharacterBody2D
	
	func enter():
		pass
	
	func exit():
		pass
	
	func update(_delta: float):
		# Base state update - can be overridden by subclasses
		pass
	
	func handle_input(_inputs: Dictionary):
		# Base state input handling - can be overridden by subclasses
		pass
	
	func can_dash() -> bool:
		return false
	
	func can_be_hurt() -> bool:
		return false

# Idle State
class IdleState extends PlayerState:
	func _init():
		pass
	
	func get_state_name() -> String:
		return "IdleState"
	
	func enter():
		print("[IdleState] Entered")
	
	func handle_input(inputs: Dictionary):
		# Check for dash input first
		if inputs.get("dash", false):
			player.handle_dash_input()
			return
		
		# Check for movement input
		var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_vector.length() > 0:
			player.change_state(RunState.new())
			return
		
		# Check for attack input
		if inputs.get("attack", false):
			player.change_state(AttackState.new())
			return
	
	func can_dash() -> bool:
		return true
	
	func can_be_hurt() -> bool:
		return true

# Run State
class RunState extends PlayerState:
	func _init():
		pass
	
	func get_state_name() -> String:
		return "RunState"
	
	func enter():
		print("[RunState] Entered")
	
	func update(_delta: float):
		# Movement is now handled in _physics_process
		# Check if we should transition to idle (no input)
		var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_vector.length() == 0:
			player.change_state(IdleState.new())
		# Delta is available for any time-based logic if needed
	
	func handle_input(inputs: Dictionary):
		# Check for dash input first
		if inputs.get("dash", false):
			player.handle_dash_input()
			return
		
		# Check for attack input
		if inputs.get("attack", false):
			player.change_state(AttackState.new())
			return
	
	func can_dash() -> bool:
		return true
	
	func can_be_hurt() -> bool:
		return true

# Dash State
class DashState extends PlayerState:
	var dash_timer: float = 0.0
	var dash_duration: float = 0.5  # Increased duration for more noticeable dash
	var dash_speed: float = 400.0
	
	func _init():
		pass
	
	func get_state_name() -> String:
		return "DashState"
	
	func enter():
		print("[DashState] Entered")
		dash_timer = 0.0
		# Use cursor direction for dash
		var dash_direction = get_cursor_direction()
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2.RIGHT  # Fallback if no cursor direction
		
		# Increase dash speed to 5x normal movement speed (or use tuning value)
		var dash_multiplier = 5.0
		if player.tuning_hud and player.tuning_hud.has_method("get_value"):
			dash_multiplier = player.tuning_hud.get_value("dash_distance", 5.0)  # Use tuning value directly as multiplier
		var dash_velocity = dash_direction * (player.move_speed_px_s * dash_multiplier)
		player.velocity = dash_velocity
		print_debug("[DashState] Dashing in direction: ", dash_direction, " with velocity: ", dash_velocity)
	
	func get_cursor_direction() -> Vector2:
		"""Get direction from player to mouse cursor"""
		var mouse_pos = player.get_global_mouse_position()
		var player_pos = player.global_position
		var direction = (mouse_pos - player_pos).normalized()
		print_debug("[DashState] Mouse pos: ", mouse_pos, " Player pos: ", player_pos, " Direction: ", direction)
		return direction
	
	func update(delta: float):
		dash_timer += delta
		if dash_timer >= dash_duration:
			# Return to previous state or idle
			player.change_state(IdleState.new())
	
	func can_be_hurt() -> bool:
		return false  # Invulnerable during dash

# Attack State
class AttackState extends PlayerState:
	var attack_timer: float = 0.0
	var attack_duration: float = 0.3
	
	func _init():
		pass
	
	func get_state_name() -> String:
		return "AttackState"
	
	func enter():
		print_debug("[AttackState] Entered")
		attack_timer = 0.0
		# Stop movement during attack
		player.velocity = Vector2.ZERO
	
	func update(delta: float):
		attack_timer += delta
		if attack_timer >= attack_duration:
			player.change_state(IdleState.new())
	
	func can_be_hurt() -> bool:
		return true

# Hurt State
class HurtState extends PlayerState:
	var hurt_timer: float = 0.0
	var invuln_duration: float = 1.0
	
	func _init():
		pass
	
	func get_state_name() -> String:
		return "HurtState"
	
	func enter():
		print_debug("[HurtState] Entered")
		hurt_timer = 0.0
		# Stop movement during hurt
		player.velocity = Vector2.ZERO
	
	func update(delta: float):
		hurt_timer += delta
		if hurt_timer >= invuln_duration:
			player.change_state(IdleState.new())
	
	func can_be_hurt() -> bool:
		return false  # Invulnerable during hurt state
