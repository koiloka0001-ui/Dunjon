extends Node

## Helper script to set up Brute enemy animations using individual JPG files
## Run this script in Godot to automatically configure all 8 animations

func _ready():
	print("Setting up Brute enemy animations from individual JPG files...")
	setup_brute_animations()

func setup_brute_animations():
	"""Set up all 8 Brute animations from individual JPG files"""
	
	# Load the Enemy scene
	var enemy_scene = load("res://entities/enemy/Enemy.tscn")
	if not enemy_scene:
		push_error("Could not load Enemy.tscn")
		return
	
	var enemy_instance = enemy_scene.instantiate()
	if not enemy_instance:
		push_error("Could not instantiate Enemy scene")
		return
	
	var sprite = enemy_instance.get_node("Sprite")
	if not sprite:
		push_error("Could not find Sprite")
		return
	
	# Create new SpriteFrames resource
	var sprite_frames = SpriteFrames.new()
	
	# Brute variant to use (1-4, using Brute 1 as default)
	var brute_variant = 1
	
	# Animation data - cycling through all 4 Brute variants
	var animations = [
		{
			"name": "idle_down",
			"animation_type": "down idle",
			"speed": 4.0
		},
		{
			"name": "idle_left", 
			"animation_type": "left idle",
			"speed": 4.0
		},
		{
			"name": "idle_right",
			"animation_type": "right idle", 
			"speed": 4.0
		},
		{
			"name": "idle_up",
			"animation_type": "up idle",
			"speed": 4.0
		},
		{
			"name": "walk_down",
			"animation_type": "down-facing walking",
			"speed": 8.0
		},
		{
			"name": "walk_left",
			"animation_type": "left walking",
			"speed": 8.0
		},
		{
			"name": "walk_right",
			"animation_type": "right walking",
			"speed": 8.0
		},
		{
			"name": "walk_up",
			"animation_type": "up walking",
			"speed": 8.0
		}
	]
	
	# Set up each animation
	for anim_data in animations:
		setup_individual_animation(sprite_frames, anim_data)
	
	# Apply the sprite frames to the sprite
	sprite.sprite_frames = sprite_frames
	
	print("✅ All Brute animations set up successfully!")
	print("You can now save the Enemy.tscn scene to preserve the animations.")

func setup_individual_animation(sprite_frames: SpriteFrames, anim_data: Dictionary):
	"""Set up a single animation cycling through all 4 Brute variants"""
	
	var anim_name = anim_data.name
	var animation_type = anim_data.animation_type
	var speed = anim_data.speed
	
	# Create the animation
	sprite_frames.add_animation(anim_name)
	sprite_frames.set_animation_speed(anim_name, speed)
	sprite_frames.set_animation_loop(anim_name, true)
	
	# Load all 4 Brute variants as animation frames
	var frame_count = 0
	for variant in range(1, 5):  # Brute variants 1-4
		var file_name = "Brute " + str(variant) + " " + animation_type + ".JPG"
		var texture_path = "res://assets/Brute/" + file_name
		
		# Load the texture
		var texture = load(texture_path)
		if texture:
			# Process the texture (resize and remove background)
			var processed_texture = process_individual_frame(texture)
			
			# Add the processed frame to the animation
			sprite_frames.add_frame(anim_name, processed_texture)
			frame_count += 1
			print("  Added frame: " + file_name)
		else:
			print("  Failed to load: " + file_name)
	
	print("✅ Set up animation: " + anim_name + " with " + str(frame_count) + " frames")

func process_individual_frame(texture: Texture2D) -> Texture2D:
	"""Process an individual JPG frame: resize and remove background"""
	var image = texture.get_image()
	var original_size = Vector2i(image.get_width(), image.get_height())
	
	# Convert to RGBA format to ensure we can modify alpha
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	
	# Remove white background (make it transparent)
	remove_white_background(image)
	
	# Resize to target size (32x32 pixels for game tiles)
	var target_size = Vector2i(32, 32)
	image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	
	# Create new texture from processed image
	var processed_texture = ImageTexture.new()
	processed_texture.set_image(image)
	
	print("Processed frame: ", original_size, " -> ", target_size)
	
	return processed_texture

func remove_white_background(image: Image):
	"""Remove white/light backgrounds and make them transparent"""
	var width = image.get_width()
	var height = image.get_height()
	var transparent_pixels = 0
	
	for y in range(height):
		for x in range(width):
			var pixel = image.get_pixel(x, y)
			
			# Check if pixel is white or very light (background)
			# Consider pixels with high brightness and low saturation as background
			var brightness = (pixel.r + pixel.g + pixel.b) / 3.0
			var saturation = max(pixel.r, pixel.g, pixel.b) - min(pixel.r, pixel.g, pixel.b)
			
			# If it's bright and low saturation, make it transparent
			if brightness > 0.9 and saturation < 0.1:
				image.set_pixel(x, y, Color.TRANSPARENT)
				transparent_pixels += 1
			# Also handle pure white pixels
			elif pixel.r > 0.95 and pixel.g > 0.95 and pixel.b > 0.95:
				image.set_pixel(x, y, Color.TRANSPARENT)
				transparent_pixels += 1
	
	var total_pixels = width * height
	var transparency_percent = (float(transparent_pixels) / float(total_pixels)) * 100.0
	print("Background removal: ", transparent_pixels, " pixels made transparent (", "%.1f" % transparency_percent, "%)")
