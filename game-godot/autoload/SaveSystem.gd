extends Node

# Save system for managing game state persistence
# Follows project conventions: JSON format, user data dir, versioned saves

signal manual_save_done

func get_save_path() -> String:
	var base_path := OS.get_user_data_dir()
	var dir := base_path.path_join("Dunjon")
	DirAccess.make_dir_recursive_absolute(dir)
	return dir

func write_save(data: Dictionary) -> void:
	var dir = get_save_path()
	var save_file = dir.path_join("savegame.json")

	rotate_backups(save_file)

	var file = FileAccess.open(save_file, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()
	else:
		push_warning("Failed to write save file: %s" % save_file)

func read_save() -> Dictionary:
	var save_file = get_save_path().path_join("savegame.json")
	if not FileAccess.file_exists(save_file):
		return get_default_state()

	var file = FileAccess.open(save_file, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var result = JSON.parse_string(content)
		if typeof(result) == TYPE_DICTIONARY:
			return result
	return get_default_state()

func rotate_backups(save_file: String) -> void:
	var bak1 = save_file + ".bak1"
	var bak2 = save_file + ".bak2"

	if FileAccess.file_exists(bak1):
		if FileAccess.file_exists(bak2):
			DirAccess.remove_absolute(bak2)
		DirAccess.rename_absolute(bak1, bak2)

	if FileAccess.file_exists(save_file):
		DirAccess.rename_absolute(save_file, bak1)

func autosave() -> void:
	var state = collect_current_state()
	write_save(state)

func collect_current_state() -> Dictionary:
	return {
		"player": {
			"name": "Hero",
			"level": 1,
		},
		"inventory": [],
		"room": "A1",
		"health": 6,
		"stamina": 100,
		"options": {}
	}

func get_default_state() -> Dictionary:
	return {
		"player": {
			"name": "Hero",
			"level": 1,
		},
		"inventory": [],
		"room": "A1",
		"health": 6,
		"stamina": 100,
		"options": {}
	}

func _ready() -> void:
	set_process(true)
	if EventBus.room_cleared.is_connected(autosave) == false:
		EventBus.room_cleared.connect(autosave)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save_manual"):
		autosave()
		emit_signal("manual_save_done")
