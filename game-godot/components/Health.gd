extends Node

@export var max_health: float = 100.0
@export var damage_flash_duration: float = 0.1

var current_health: float
var damage_flash_timer: float = 0.0
var sprite: Sprite2D

signal health_changed(new_health: float)
signal health_depleted()

func _ready() -> void:
	current_health = max_health
	sprite = get_parent().get_node("Sprite2D") if get_parent().has_node("Sprite2D") else null

func _process(delta: float) -> void:
	if damage_flash_timer > 0.0:
		damage_flash_timer -= delta
		update_damage_flash()

func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health)
	
	# Apply damage flash if enabled in options
	if OptionsManager.get_option("damage_flash"):
		start_damage_flash()
	
	if current_health <= 0.0:
		health_depleted.emit()

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health)

func start_damage_flash() -> void:
	damage_flash_timer = damage_flash_duration

func update_damage_flash() -> void:
	if not sprite:
		return
	
	# Flash between normal and red color
	var flash_alpha = sin(damage_flash_timer * 50.0) * 0.5 + 0.5
	sprite.modulate = Color(1.0, 1.0 - flash_alpha, 1.0 - flash_alpha, 1.0)
	
	if damage_flash_timer <= 0.0:
		sprite.modulate = Color.WHITE
