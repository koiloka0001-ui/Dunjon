extends Node

## Script to check individual Brute JPG sprite dimensions

func _ready():
	print("Checking Brute individual JPG sprite dimensions...")
	check_all_sprites()

func check_all_sprites():
	# Check Brute variant 1 files (using as example)
	var brute_variant = 1
	var sprite_files = [
		"res://assets/Brute/Brute " + str(brute_variant) + " down idle.JPG",
		"res://assets/Brute/Brute " + str(brute_variant) + " left idle.JPG", 
		"res://assets/Brute/Brute " + str(brute_variant) + " right idle.JPG",
		"res://assets/Brute/Brute " + str(brute_variant) + " up idle.JPG",
		"res://assets/Brute/Brute " + str(brute_variant) + " down-facing walking.JPG",
		"res://assets/Brute/Brute " + str(brute_variant) + " left walking.JPG",
		"res://assets/Brute/Brute " + str(brute_variant) + " right walking.JPG",
		"res://assets/Brute/Brute " + str(brute_variant) + " up walking.JPG"
	]
	
	print("Checking Brute variant ", brute_variant, " files:")
	for sprite_path in sprite_files:
		var texture = load(sprite_path)
		if texture:
			var width = texture.get_width()
			var height = texture.get_height()
			print(sprite_path.get_file(), ": ", width, "x", height)
			
			# Check if dimensions are suitable for 32x32 game tiles
			if width >= 32 and height >= 32:
				print("  -> Good size for 32x32 game tiles")
			else:
				print("  -> May need resizing for 32x32 game tiles")
		else:
			print("Failed to load: ", sprite_path)
	
	# Also check if other variants exist
	print("\nChecking for other Brute variants:")
	for variant in range(2, 5):  # Check variants 2, 3, 4
		var sample_file = "res://assets/Brute/Brute " + str(variant) + " down idle.JPG"
		var texture = load(sample_file)
		if texture:
			print("Brute variant ", variant, " found: ", texture.get_width(), "x", texture.get_height())
		else:
			print("Brute variant ", variant, " not found")
