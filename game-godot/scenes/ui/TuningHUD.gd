extends CanvasLayer

const CONFIG_PATH := "res://../config/tuning.json"

var tuning := {}

func _ready() -> void:
	load_tuning()
	build_ui()
	visible = false
	print("[TuningHUD] Ready - loaded ", tuning.size(), " tuning variables")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_tuning"):
		visible = !visible
		print("[TuningHUD] Toggled visibility: ", visible)

func load_tuning() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			tuning = parsed
			print("[TuningHUD] Loaded tuning config from: ", CONFIG_PATH)
		else:
			push_error("[TuningHUD] Invalid JSON in tuning config")
			use_defaults()
		file.close()
	else:
		push_error("[TuningHUD] Could not load tuning config, using defaults")
		use_defaults()

func use_defaults() -> void:
	tuning = {
		"player_speed": 200,
		"dash_distance": 150,
		"dash_cooldown": 0.5,
		"stamina_regen": 1.0,
		"enemy_speed": 100,
		"enemy_attack_cooldown": 1.0,
		"enemy_damage": 1,
		"attack_cooldown": 0.3,
		"ammo_max": 6,
		"reload_time": 1.2
	}
	save_tuning()

func save_tuning() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(tuning, "  "))
		file.close()
		print("[TuningHUD] Saved tuning config to: ", CONFIG_PATH)
	else:
		push_error("[TuningHUD] Could not save tuning config")

func build_ui() -> void:
	var vbox = $PanelContainer/VBoxContainer
	
	# Clear existing children
	for child in vbox.get_children():
		child.queue_free()

	# Add title
	var title_label = Label.new()
	title_label.text = "TUNING HUD"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color.YELLOW
	vbox.add_child(title_label)

	# Add separator
	var separator = HSeparator.new()
	vbox.add_child(separator)

	for key in tuning.keys():
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)

		# Variable name label
		var label = Label.new()
		label.text = key.replace("_", " ").capitalize()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(label)

		# Slider
		var slider = HSlider.new()
		slider.min_value = 0
		slider.max_value = tuning[key] * 2 if tuning[key] is float or tuning[key] is int else 10
		slider.step = 0.1
		slider.value = tuning[key]
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.connect("value_changed", Callable(self, "_on_slider_changed").bind(key))
		hbox.add_child(slider)

		# Value label
		var val_label = Label.new()
		val_label.text = str(tuning[key])
		val_label.name = key + "_value"
		val_label.size_flags_horizontal = Control.SIZE_SHRINK_END
		val_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		val_label.modulate = Color.CYAN
		hbox.add_child(val_label)

		vbox.add_child(hbox)

	# Add separator
	var separator2 = HSeparator.new()
	vbox.add_child(separator2)

	# Add preset buttons
	var preset_hbox = HBoxContainer.new()
	preset_hbox.add_theme_constant_override("separation", 10)
	
	# Save Preset button
	var save_button = Button.new()
	save_button.text = "Save Preset"
	save_button.pressed.connect(_on_save_preset_pressed)
	preset_hbox.add_child(save_button)
	
	# Load Preset button
	var load_button = Button.new()
	load_button.text = "Load Preset"
	load_button.pressed.connect(_on_load_preset_pressed)
	preset_hbox.add_child(load_button)
	
	vbox.add_child(preset_hbox)

	# Add instructions
	var instructions = Label.new()
	instructions.text = "Press 1 to toggle this HUD"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.modulate = Color.GRAY
	vbox.add_child(instructions)

func _on_slider_changed(value: float, key: String) -> void:
	tuning[key] = value
	save_tuning()

	var vbox = $PanelContainer/VBoxContainer
	var val_label = vbox.get_node(key + "_value")
	if val_label:
		val_label.text = str(value)
	
	print("[TuningHUD] Updated ", key, " to ", value)

# Get a tuning value (for other scripts to use)
func get_value(key: String, default_value = 0):
	return tuning.get(key, default_value)

# Set a tuning value programmatically
func set_value(key: String, value) -> void:
	tuning[key] = value
	save_tuning()
	
	# Update UI if visible
	if visible:
		var vbox = $PanelContainer/VBoxContainer
		var val_label = vbox.get_node(key + "_value")
		if val_label:
			val_label.text = str(value)
		var slider = val_label.get_parent().get_node("HSlider")
		if slider:
			slider.value = value

# Preset functionality
func _on_save_preset_pressed() -> void:
	# Simple input dialog for preset name
	var preset_name = "preset_" + str(Time.get_unix_time_from_system())
	save_preset(preset_name)

func _on_load_preset_pressed() -> void:
	# For now, load a default preset if it exists
	if FileAccess.file_exists("res://../tools/presets/easy.json"):
		load_preset("easy")
	else:
		print("[TuningHUD] No easy.json preset found")

func save_preset(name: String) -> void:
	var dir = DirAccess.open("res://../tools/presets")
	if not dir:
		DirAccess.make_dir_recursive_absolute("res://../tools/presets")

	var file = FileAccess.open("res://../tools/presets/%s.json" % name, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(tuning, "  "))
		file.close()
		print("[TuningHUD] Saved preset: ", name)
	else:
		push_error("[TuningHUD] Could not save preset: ", name)

func load_preset(name: String) -> void:
	var file = FileAccess.open("res://../tools/presets/%s.json" % name, FileAccess.READ)
	if not file:
		push_warning("[TuningHUD] Preset not found: ", name)
		return

	var content = file.get_as_text()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) == TYPE_DICTIONARY:
		tuning = parsed
		file.close()
		save_tuning()
		build_ui()
		print("[TuningHUD] Loaded preset: ", name)
	else:
		push_error("[TuningHUD] Invalid JSON in preset: ", name)
		file.close()

# Get list of available presets
func get_available_presets() -> Array:
	var presets = []
	var dir = DirAccess.open("res://../tools/presets")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json") and not file_name.begins_with("."):
				presets.append(file_name.get_basename())
			file_name = dir.get_next()
		dir.list_dir_end()
	return presets
