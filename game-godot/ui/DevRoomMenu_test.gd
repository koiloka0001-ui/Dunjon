extends CanvasLayer

## Test version of Developer Room Menu

func _ready():
	print("[DevRoomMenu] Test version ready")
	visible = false

func _input(event):
	if event.is_action_pressed("dev_menu"):
		print("[DevRoomMenu] Input detected! Toggling visibility...")
		visible = !visible
		get_viewport().set_input_as_handled()
