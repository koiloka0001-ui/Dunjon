extends Node

var difficulty_multipliers := {
	"easy": {
		"enemy_health": 0.7,
		"enemy_damage": 0.6,
		"enemy_speed": 0.8,
		"spawn_rate": 0.7,
		"player_health": 1.3
	},
	"normal": {
		"enemy_health": 1.0,
		"enemy_damage": 1.0,
		"enemy_speed": 1.0,
		"spawn_rate": 1.0,
		"player_health": 1.0
	},
	"hard": {
		"enemy_health": 1.4,
		"enemy_damage": 1.3,
		"enemy_speed": 1.2,
		"spawn_rate": 1.3,
		"player_health": 0.8
	}
}

var current_difficulty: String = "normal"
var current_multipliers: Dictionary

func _ready() -> void:
	load_difficulty_settings()

func load_difficulty_settings() -> void:
	current_difficulty = OptionsManager.get_option("difficulty")
	current_multipliers = difficulty_multipliers.get(current_difficulty, difficulty_multipliers["normal"])
	print("[DifficultyManager] Loaded difficulty: ", current_difficulty)

func get_enemy_health_multiplier() -> float:
	return current_multipliers.get("enemy_health", 1.0)

func get_enemy_damage_multiplier() -> float:
	return current_multipliers.get("enemy_damage", 1.0)

func get_enemy_speed_multiplier() -> float:
	return current_multipliers.get("enemy_speed", 1.0)

func get_spawn_rate_multiplier() -> float:
	return current_multipliers.get("spawn_rate", 1.0)

func get_player_health_multiplier() -> float:
	return current_multipliers.get("player_health", 1.0)

func apply_difficulty_to_enemy(enemy: Node) -> void:
	# Apply health scaling
	var health_component = enemy.get_node("Health") if enemy.has_node("Health") else null
	if health_component:
		health_component.max_health *= get_enemy_health_multiplier()
		health_component.current_health = health_component.max_health
	
	# Apply speed scaling
	if enemy.has_method("set_speed"):
		var base_speed = enemy.get("base_speed") if enemy.has_method("get") else 100.0
		enemy.set_speed(base_speed * get_enemy_speed_multiplier())

func apply_difficulty_to_player(player: Node) -> void:
	# Apply health scaling
	var health_component = player.get_node("Health") if player.has_node("Health") else null
	if health_component:
		health_component.max_health *= get_player_health_multiplier()
		health_component.current_health = health_component.max_health

func get_difficulty_display_name() -> String:
	match current_difficulty:
		"easy":
			return "Easy"
		"normal":
			return "Normal"
		"hard":
			return "Hard"
		_:
			return "Normal"
