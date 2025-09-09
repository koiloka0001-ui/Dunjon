extends Node

var options := {}
const CONFIG_PATH := "res://../config/options.json"
const INPUT_CONFIG_PATH := "res://../config/inputs.json"

func _ready() -> void:
	load_options()
	load_input_bindings()

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

func load_input_bindings() -> void:
	"""Load and apply input bindings from config file at startup"""
	var file := FileAccess.open(INPUT_CONFIG_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			apply_input_bindings(parsed)
			print("[OptionsManager] Loaded input bindings from: ", INPUT_CONFIG_PATH)
		else:
			push_warning("[OptionsManager] Invalid JSON in input config, using defaults")
			use_default_input_bindings()
		file.close()
	else:
		push_warning("[OptionsManager] Input config not found, using defaults")
		use_default_input_bindings()

func use_default_input_bindings() -> void:
	"""Apply default input bindings"""
	var default_bindings = {
		"move_left": ["A", "Left"],
		"move_right": ["D", "Right"],
		"move_up": ["W", "Up"],
		"move_down": ["S", "Down"],
		"attack": ["J", "Space"],
		"dash": ["K", "Shift"],
		"pause": ["Escape", "P"]
	}
	apply_input_bindings(default_bindings)

func apply_input_bindings(bindings: Dictionary) -> void:
	"""Apply input bindings to InputMap"""
	# Only clear and recreate actions that are in our config file
	for action in bindings.keys():
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
		else:
			InputMap.add_action(action)
		
		# Add new events for each key
		for key in bindings[action]:
			var ev = InputEventKey.new()
			ev.physical_keycode = OS.find_keycode_from_string(key)
			InputMap.action_add_event(action, ev)
	
	print("[OptionsManager] Applied input bindings to InputMap")
