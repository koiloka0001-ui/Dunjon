extends Node

var options := {}
const CONFIG_PATH := "res://../config/options.json"

func _ready() -> void:
	load_options()

func load_options() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			options = parsed
		else:
			push_warning("[OptionsManager] Invalid JSON, using defaults.")
			use_defaults()
		file.close()
	else:
		push_warning("[OptionsManager] Config not found, using defaults.")
		use_defaults()
	save_options() # ensure file exists

func save_options() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(options, "  "))
		file.close()
		print("[OptionsManager] Saved options")

func use_defaults() -> void:
	# Defaults should match docs/OPTIONS.md
	options = {
		"screen_shake": 0.5,
		"damage_flash": true,
		"aim_assist": 0.25,
		"difficulty": "normal"
	}

func get_option(key: String):
	if options.has(key):
		return options[key]
	return null

func set_option(key: String, value) -> void:
	options[key] = value
	save_options()
