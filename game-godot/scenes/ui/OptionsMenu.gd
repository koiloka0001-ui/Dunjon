extends CanvasLayer

@onready var screen_shake_slider = $Control/VBoxContainer/ScreenShake/HSlider
@onready var damage_flash_toggle = $Control/VBoxContainer/DamageFlash/CheckBox
@onready var aim_assist_slider = $Control/VBoxContainer/AimAssist/HSlider
@onready var difficulty_dropdown = $Control/VBoxContainer/Difficulty/OptionButton
@onready var input_remap_button = $Control/VBoxContainer/InputRemap

func _ready() -> void:
	load_from_options()

	# Connect signals
	screen_shake_slider.value_changed.connect(on_screen_shake_changed)
	damage_flash_toggle.toggled.connect(on_damage_flash_changed)
	aim_assist_slider.value_changed.connect(on_aim_assist_changed)
	difficulty_dropdown.item_selected.connect(on_difficulty_changed)
	input_remap_button.pressed.connect(_on_input_remap_pressed)

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
