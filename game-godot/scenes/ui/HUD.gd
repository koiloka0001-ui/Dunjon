extends CanvasLayer

var hearts: Array = []
var stamina: Array = []
var ammo: Array = []

@onready var save_flash: Label

func _ready() -> void:
	print("[HUD] Script starting...")
	print("[HUD] Node type: ", get_class())
	print("[HUD] Parent: ", get_parent())

	# Create health section
	var health_label = Label.new()
	health_label.text = "HEALTH: "
	health_label.modulate = Color.RED
	health_label.position = Vector2(50, 50)
	add_child(health_label)
	
	# Add heart symbols
	for i in range(3):
		var heart = Label.new()
		heart.text = "❤️"
		heart.modulate = Color.RED
		heart.position = Vector2(120 + i * 30, 50)
		add_child(heart)
		hearts.append(heart)
	
	# Create stamina section
	var stamina_label = Label.new()
	stamina_label.text = "STAMINA: "
	stamina_label.modulate = Color.GREEN
	stamina_label.position = Vector2(50, 80)
	add_child(stamina_label)
	
	# Add stamina blocks
	for i in range(5):
		var block = Label.new()
		block.text = "▮"
		block.modulate = Color.GREEN
		block.position = Vector2(120 + i * 20, 80)
		add_child(block)
		stamina.append(block)
	
	# Create ammo section
	var ammo_label = Label.new()
	ammo_label.text = "AMMO: "
	ammo_label.modulate = Color.YELLOW
	ammo_label.position = Vector2(50, 110)
	add_child(ammo_label)
	
	# Add ammo dots
	for i in range(3):
		var dot = Label.new()
		dot.text = "●"
		dot.modulate = Color.YELLOW
		dot.position = Vector2(120 + i * 20, 110)
		add_child(dot)
		ammo.append(dot)
	
	# Add empty ammo dots
	for i in range(3):
		var empty_dot = Label.new()
		empty_dot.text = "○"
		empty_dot.modulate = Color.GRAY
		empty_dot.position = Vector2(200 + i * 20, 110)
		add_child(empty_dot)
		ammo.append(empty_dot)
	
	print("[HUD] All elements created successfully!")
	
	# Add a big obvious test label to see if script is running
	var test_label = Label.new()
	test_label.text = "HUD SCRIPT IS RUNNING!"
	test_label.modulate = Color(1, 1, 0) # bright yellow
	test_label.position = Vector2(50, 200)
	add_child(test_label)
	
	# Create save flash label
	save_flash = Label.new()
	save_flash.text = "Game Saved"
	save_flash.modulate = Color.GREEN
	save_flash.position = Vector2(50, 250)
	save_flash.visible = false
	add_child(save_flash)
	
	# Connect to SaveSystem signal
	SaveSystem.manual_save_done.connect(_on_manual_save_done)

func set_health(value: int, max_health: int) -> void:
	print("[HUD] Setting health: ", value, "/", max_health)
	# Update existing heart labels
	var full_hearts = value / 2
	var half_heart = value % 2
	for i in range(hearts.size()):
		if i < full_hearts:
			hearts[i].text = "❤️"
			hearts[i].modulate = Color.RED
		elif i == full_hearts and half_heart == 1:
			hearts[i].text = "♥︎"
			hearts[i].modulate = Color.ORANGE
		else:
			hearts[i].text = "🖤"
			hearts[i].modulate = Color.GRAY

func set_stamina(value: int, max_stamina: int) -> void:
	print("[HUD] Setting stamina: ", value, "/", max_stamina)
	# Update existing stamina labels
	for i in range(stamina.size()):
		if i < value:
			stamina[i].text = "▮"
			stamina[i].modulate = Color.GREEN
		else:
			stamina[i].text = "▯"
			stamina[i].modulate = Color.GRAY

func set_ammo(value: int, max_ammo: int) -> void:
	print("[HUD] Setting ammo: ", value, "/", max_ammo)
	# Update existing ammo labels
	for i in range(ammo.size()):
		if i < value:
			ammo[i].text = "●"
			ammo[i].modulate = Color.YELLOW
		else:
			ammo[i].text = "○"
			ammo[i].modulate = Color.GRAY

func _on_manual_save_done():
	save_flash.text = "Game Saved"
	save_flash.visible = true
	await get_tree().create_timer(2.0).timeout
	save_flash.visible = false
