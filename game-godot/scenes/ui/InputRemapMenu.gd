extends Control

const CONFIG_PATH := "res://../config/inputs.json"

var bindings := {}
var waiting_for_action: String = ""
var action_rows := {}

@onready var actions_container = $VBoxContainer/ActionsContainer
@onready var close_button = $VBoxContainer/Close

func _ready() -> void:
	load_bindings()
	populate_ui()
	
	# Connect close button
	close_button.pressed.connect(_on_close_pressed)

func load_bindings() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			bindings = parsed
		else:
			use_defaults()
		file.close()
	else:
		use_defaults()
		save_bindings()
	apply_bindings()

func use_defaults() -> void:
	bindings = {
		"move_left": ["A", "Left"],
		"move_right": ["D", "Right"],
		"move_up": ["W", "Up"],
		"move_down": ["S", "Down"],
		"attack": ["J", "Space"],
		"dash": ["K", "Shift"],
		"pause": ["Escape", "P"]
	}

func save_bindings() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(bindings, "  "))
		file.close()
		print("[InputRemap] Saved bindings to:", CONFIG_PATH)

func apply_bindings() -> void:
	# Clear all existing actions
	for action in bindings.keys():
		InputMap.action_erase_events(action)
		
		# Add new events for each key
		for key in bindings[action]:
			var ev = InputEventKey.new()
			ev.physical_keycode = OS.find_keycode_from_string(key)
			InputMap.action_add_event(action, ev)
	
	print("[InputRemap] Applied bindings to InputMap")

func populate_ui() -> void:
	# Clear existing rows
	for child in actions_container.get_children():
		child.queue_free()
	action_rows.clear()
	
	# Create rows for each action
	for action in bindings.keys():
		create_action_row(action)

func create_action_row(action: String) -> void:
	var hbox = HBoxContainer.new()
	actions_container.add_child(hbox)
	
	# Action name label
	var action_label = Label.new()
	action_label.text = action.replace("_", " ").capitalize()
	action_label.custom_minimum_size.x = 120
	hbox.add_child(action_label)
	
	# Current keys label
	var keys_label = Label.new()
	keys_label.text = ", ".join(bindings[action])
	keys_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(keys_label)
	
	# Change button
	var change_button = Button.new()
	change_button.text = "Change"
	change_button.pressed.connect(_on_change_button_pressed.bind(action))
	hbox.add_child(change_button)
	
	# Store reference for updating
	action_rows[action] = {
		"hbox": hbox,
		"keys_label": keys_label,
		"change_button": change_button
	}

func _on_change_button_pressed(action: String) -> void:
	waiting_for_action = action
	print("[InputRemap] Press a new key now for:", action)
	
	# Show instruction
	var instruction_label = Label.new()
	instruction_label.text = "Press a new key now..."
	instruction_label.modulate = Color.YELLOW
	actions_container.add_child(instruction_label)
	
	# Disable all change buttons
	for row in action_rows.values():
		row.change_button.disabled = true
	
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if waiting_for_action != "" and event is InputEventKey and event.pressed:
		var key_str = OS.get_keycode_string(event.physical_keycode)
		
		# Remove from other actions if already bound
		for action in bindings.keys():
			if key_str in bindings[action]:
				bindings[action].erase(key_str)
		
		# Assign to this action (replace all existing keys)
		bindings[waiting_for_action] = [key_str]
		
		# Save and apply
		save_bindings()
		apply_bindings()
		
		# Update UI
		populate_ui()
		
		# Clean up
		waiting_for_action = ""
		set_process_input(false)
		
		print("[InputRemap] Bound '", key_str, "' to '", waiting_for_action, "'")

func _on_close_pressed() -> void:
	queue_free()
