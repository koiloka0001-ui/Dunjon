extends Node2D

# Player stats
@export var max_health: int = 6
@export var max_stamina: int = 5
@export var max_ammo: int = 6

var health: int
var stamina: int
var ammo: int

# HUD reference
@onready var hud = get_tree().root.get_node("Main/HUD")

# Movement
@export var move_speed: float = 200.0
var velocity: Vector2 = Vector2.ZERO

# Input handling
var inputs: Dictionary = {}

func _ready() -> void:
	print("[Player] Initializing...")
	
	# Initialize stats
	health = max_health
	stamina = max_stamina
	ammo = max_ammo
	
	# Initialize HUD
	if hud:
		hud.set_health(health, max_health)
		hud.set_stamina(stamina, max_stamina)
		hud.set_ammo(ammo, max_ammo)
		print("[Player] HUD initialized")
	else:
		print("[Player] WARNING: HUD not found!")

func _physics_process(delta: float) -> void:
	# Get inputs (handles replay mode)
	inputs = get_inputs()
	
	# Handle movement
	handle_movement(delta)
	
	# Handle actions
	handle_actions()
	
	# Regenerate stamina
	regen_stamina(delta)

func get_inputs() -> Dictionary:
	# Check if we're in replay mode
	if RecordingManager.playing_back:
		return RecordingManager.get_replay_inputs()
	
	# Normal input handling
	return {
		"left": Input.is_action_pressed("ui_left"),
		"right": Input.is_action_pressed("ui_right"),
		"up": Input.is_action_pressed("ui_up"),
		"down": Input.is_action_pressed("ui_down"),
		"attack": Input.is_action_just_pressed("attack") if InputMap.has_action("attack") else false,
		"dash": Input.is_action_just_pressed("dash") if InputMap.has_action("dash") else false
	}

func handle_movement(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if inputs.get("left", false):
		velocity.x -= 1
	if inputs.get("right", false):
		velocity.x += 1
	if inputs.get("up", false):
		velocity.y -= 1
	if inputs.get("down", false):
		velocity.y += 1
	
	velocity = velocity.normalized() * move_speed
	position += velocity * delta

func handle_actions() -> void:
	# Attack
	if inputs.get("attack", false):
		shoot()
	
	# Dash
	if inputs.get("dash", false):
		dash()

func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	
	if hud:
		hud.set_health(health, max_health)
	
	print("[Player] Took ", amount, " damage. Health: ", health, "/", max_health)
	
	if health <= 0:
		die()

func heal(amount: int) -> void:
	health += amount
	health = clamp(health, 0, max_health)
	
	if hud:
		hud.set_health(health, max_health)
	
	print("[Player] Healed ", amount, ". Health: ", health, "/", max_health)

func use_stamina(amount: int) -> bool:
	if stamina >= amount:
		stamina -= amount
		if hud:
			hud.set_stamina(stamina, max_stamina)
		print("[Player] Used ", amount, " stamina. Stamina: ", stamina, "/", max_stamina)
		return true
	else:
		print("[Player] Not enough stamina! Need: ", amount, ", Have: ", stamina)
		return false

func regen_stamina(delta: float) -> void:
	if stamina < max_stamina:
		stamina = min(stamina + delta * 10, max_stamina)  # 10 stamina per second
		if hud:
			hud.set_stamina(stamina, max_stamina)

func shoot() -> void:
	if ammo > 0:
		ammo -= 1
		if hud:
			hud.set_ammo(ammo, max_ammo)
		print("[Player] Shot! Ammo: ", ammo, "/", max_ammo)
	else:
		print("[Player] Out of ammo!")

func reload() -> void:
	ammo = max_ammo
	if hud:
		hud.set_ammo(ammo, max_ammo)
	print("[Player] Reloaded! Ammo: ", ammo, "/", max_ammo)

func dash() -> void:
	if use_stamina(2):  # Dash costs 2 stamina
		print("[Player] Dashed!")
		# Add dash effect here (movement boost, invincibility, etc.)
	else:
		print("[Player] Can't dash - not enough stamina!")

func die() -> void:
	print("[Player] DIED!")
	# Add death logic here

# Debug functions for testing
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space key
		take_damage(1)
		print("[Player] DEBUG: Took 1 damage")
	elif event.is_action_pressed("ui_cancel"):  # Escape key
		heal(1)
		print("[Player] DEBUG: Healed 1 health")
	elif event.is_action_pressed("ui_select"):  # Enter key
		reload()
		print("[Player] DEBUG: Reloaded")
