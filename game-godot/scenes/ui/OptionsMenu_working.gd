extends CanvasLayer

## Options Menu - Modeled after TuningHUD

@onready var screen_shake_slider = $PanelContainer/VBoxContainer/ScreenShake/HSlider
@onready var damage_flash_toggle = $PanelContainer/VBoxContainer/DamageFlash/CheckBox
@onready var aim_assist_slider = $PanelContainer/VBoxContainer/AimAssist/HSlider
@onready var difficulty_dropdown = $PanelContainer/VBoxContainer/Difficulty/OptionButton
@onready var input_remap_button = $PanelContainer/VBoxContainer/InputRemap

func _ready() -> void:
	load_from_options()
	visible = false
	print("[OptionsMenu] Ready - loaded options menu")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("options_menu"):
		visible = !visible
		print("[OptionsMenu] Toggled visibility: ", visible)

func load_from_options() -> void:
	screen_shake_slider.value = OptionsManager.get_option("screen_shake")
	damage_flash_toggle.button_pressed = OptionsManager.get_option("damage_flash")
	aim_assist_slider.value = OptionsManager.get_option("aim_assist")

	difficulty_dropdown.clear()
	for d in ["easy", "normal", "hard"]:
		difficulty_dropdown.add_item(d.capitalize())
	var current = OptionsManager.get_option("difficulty")
	difficulty_dropdown.select(["easy", "normal", "hard"].find(current))

func on_screen_shake_changed(value: float) -> void:
	OptionsManager.set_option("screen_shake", value)

func on_damage_flash_changed(value: bool) -> void:
	OptionsManager.set_option("damage_flash", value)

func on_aim_assist_changed(value: float) -> void:
	OptionsManager.set_option("aim_assist", value)

func on_difficulty_changed(index: int) -> void:
	var val = ["easy", "normal", "hard"][index]
	OptionsManager.set_option("difficulty", val)

func _on_input_remap_pressed() -> void:
	var input_remap_menu = preload("res://scenes/ui/InputRemapMenu.tscn").instantiate()
	get_parent().add_child(input_remap_menu)
