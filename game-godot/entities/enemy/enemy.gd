extends CharacterBody2D

## Brute Enemy with chase AI
## Simple enemy that follows the player and attacks when close

# Enemy stats
@export var max_health: int = 3
@export var move_speed_px_s: float = 80.0
@export var attack_range_px: float = 40.0
@export var attack_damage: int = 1
@export var detection_range_px: float = 200.0

var health: int
var player: Node2D
var is_chasing: bool = false
var last_direction: Vector2 = Vector2.DOWN
var debug_logging: bool = true  # Control debug output

# Wandering behavior
var is_wandering: bool = false
var wander_timer: float = 0.0
var wander_duration: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var next_wander_time: float = 0.0
var wander_cooldown_min: float = 3.0  # Minimum time between wanders (seconds)
var wander_cooldown_max: float = 8.0  # Maximum time between wanders (seconds)
var wander_duration_min: float = 1.0  # Minimum wander duration (seconds)
var wander_duration_max: float = 3.0  # Maximum wander duration (seconds)

# Advanced chase behavior
var chase_phase: String = "approach"  # "approach", "track", "lunge", "recover"
var track_timer: float = 0.0
var track_duration: float = 0.0
var lunge_timer: float = 0.0
var lunge_cooldown: float = 0.0
var rotation_angle: float = 0.0
var rotation_speed: float = 90.0  # Degrees per second
var lunge_distance: float = 60.0  # Distance to maintain while tracking
var lunge_speed_multiplier: float = 2.0  # How much faster lunging is
var track_duration_min: float = 2.0  # Minimum tracking time
var track_duration_max: float = 4.0  # Maximum tracking time
var lunge_cooldown_min: float = 1.0  # Minimum time between lunges
var lunge_cooldown_max: float = 3.0  # Maximum time between lunges

# Image processing settings
var enable_background_removal: bool = true  # Set to false if images are already clean
var use_high_quality_resize: bool = true    # Use cubic interpolation for better quality
var skip_resize_if_correct_size: bool = true  # Skip resize if already 32x32
var enable_artifact_cleaning: bool = true   # Clean up isolated pixels and artifacts

# Animation
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	# Initialize stats
	health = max_health
	
	# Add to enemy group for easy finding
	add_to_group("enemies")
	
	# Setup sprite frames for Brute character
	setup_brute_animations()
	
	# Initialize wandering system
	next_wander_time = randf_range(wander_cooldown_min, wander_cooldown_max)
	
	# Start with idle animation
	play_animation("idle_down")
	
	print_debug("[Enemy] Brute spawned at: ", global_position)

func set_debug_logging(enabled: bool):
	"""Enable or disable debug logging for this enemy"""
	debug_logging = enabled
	if debug_logging:
		print_debug("[Enemy] Debug logging enabled for Brute enemy")

func enable_debug_for_all_enemies(enabled: bool):
	"""Enable or disable debug logging for all enemies in the scene"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("set_debug_logging"):
			enemy.set_debug_logging(enabled)
	print_debug("[Enemy] Debug logging ", "enabled" if enabled else "disabled", " for all enemies")

func setup_brute_animations():
	"""Setup the Brute character sprite animations using individual JPG files"""
	if not sprite:
		return
	
	# Create new SpriteFrames resource
	var sprite_frames = SpriteFrames.new()
	
	# Brute variant to use (1-4, using Brute 1 as default)
	var brute_variant = 1
	
	# Setup idle animations using new Grunt files with custom sequence
	# All idle animations use the same cycling sequence (1-5 with custom durations)
	setup_grunt_idle_animation(sprite_frames, "idle_down")
	setup_grunt_idle_animation(sprite_frames, "idle_left")
	setup_grunt_idle_animation(sprite_frames, "idle_right")
	setup_grunt_idle_animation(sprite_frames, "idle_up")
	
	# Setup walking animations using individual files
	setup_individual_animation(sprite_frames, "walk_down", brute_variant, "down", 8.0)
	setup_individual_animation(sprite_frames, "walk_left", brute_variant, "left", 8.0)
	setup_individual_animation(sprite_frames, "walk_right", brute_variant, "right", 8.0)
	setup_individual_animation(sprite_frames, "walk_up", brute_variant, "up", 8.0)
	
	# Apply the sprite frames to the sprite
	sprite.sprite_frames = sprite_frames
	
	# Center the sprite and set appropriate scale - make brute 1.5x taller
	sprite.centered = true
	sprite.scale = Vector2(1.0, 1.5)  # 1.5x taller than player
	# Adjust offset to keep sprite centered when scaled
	sprite.offset = Vector2(-16, -24)  # -16 for width, -24 for height (16 * 1.5)
	
	if debug_logging:
		print_debug("[Enemy] Brute animations setup complete - cycling through all 4 Brute variants")

func setup_grunt_idle_animation(sprite_frames: SpriteFrames, anim_name: String):
	"""Setup idle animation using new Grunt files with custom 1-5-1 sequence and timing"""
	# Add the animation
	sprite_frames.add_animation(anim_name)
	sprite_frames.set_animation_loop(anim_name, true)
	
	# Grunt idle files in order 1-5 (including 3.5)
	var grunt_files = [
		"res://assets/Brute/Grunt 1  idle far left.png",
		"res://assets/Brute/Grunt 2 idle left.JPG",
		"res://assets/Brute/Grunt 3 idle middle.png",
		"res://assets/Brute/Grunt 3.5 middle blinking.png", 
		"res://assets/Brute/Grunt 4 idle right.JPG",
		"res://assets/Brute/Grunt 5 idle far right.jpg"
	]
	
	# Custom timing: start at frame 3, linger more on frames 4-2, less time on 1 and 5
	# Frame durations in seconds: 1=1.0s, 2=2.5s, 3=3.0s, 3.5=1.0s, 4=2.5s, 5=1.0s (total ~20s for full cycle)
	var frame_durations = [1.0, 2.5, 3.0, 1.0, 2.5, 1.0]
	
	# Create the 3-5-3 sequence (start at 3, go to 5, back to 3)
	var sequence_frames = []
	var sequence_durations = []
	
	# Forward: 3-3.5-4-5 (start at frame 3)
	for i in range(2, 6):  # Start at index 2 (frame 3), go to index 5 (frame 5)
		sequence_frames.append(grunt_files[i])
		sequence_durations.append(frame_durations[i])
	
	# Backward: 4-3.5-3 (back to frame 3)
	for i in range(4, 1, -1):  # 4, 3.5, 3 (indices 4, 3, 2)
		sequence_frames.append(grunt_files[i])
		sequence_durations.append(frame_durations[i])
	
	# Add each frame to the animation
	for i in range(sequence_frames.size()):
		var frame_path = sequence_frames[i]
		var texture = load(frame_path)
		if texture:
			# Process the texture (resize and remove background)
			var processed_texture = process_individual_frame(texture)
			sprite_frames.add_frame(anim_name, processed_texture)
			
			if debug_logging:
				print_debug("[Enemy] Added Grunt frame ", i+1, " for ", anim_name, " from ", frame_path.get_file(), " (duration: ", sequence_durations[i], "s)")
		else:
			if debug_logging:
				print_debug("[Enemy] Failed to load Grunt frame: ", frame_path)
	
	# Set overall animation speed (Godot 4 doesn't support per-frame durations)
	# Use average speed for the sequence
	var total_duration = 0.0
	for duration in sequence_durations:
		total_duration += duration
	var average_fps = sequence_frames.size() / total_duration
	sprite_frames.set_animation_speed(anim_name, average_fps)

func setup_individual_animation(sprite_frames: SpriteFrames, anim_name: String, _brute_variant: int, animation_type: String, speed: float):
	"""Setup animation using individual files, cycling through all 4 Brute variants"""
	# Add the animation
	sprite_frames.add_animation(anim_name)
	sprite_frames.set_animation_speed(anim_name, speed)
	sprite_frames.set_animation_loop(anim_name, true)
	
	# Load available Brute variants as animation frames
	var frame_files = []
	
	# Define which variants exist for each direction (based on actual files)
	var available_variants = []
	match animation_type:
		"down":
			available_variants = [1, 2, 3]  # Brute 4 missing down
		"left":
			available_variants = [1, 2, 3]  # Brute 4 missing left
		"right":
			available_variants = [1, 2, 3, 4]  # All variants available
		"up":
			available_variants = [1, 2, 3, 4]  # All variants available
	
	for variant in available_variants:
		var file_path = ""
		
		# Handle different naming patterns for different directions
		match animation_type:
			"down":
				# Try PNG first, then JPG with "down-facing" naming
				var png_path = "res://assets/Brute/Brute " + str(variant) + " down walking.png"
				var jpg_path = "res://assets/Brute/Brute " + str(variant) + " down-facing walking.JPG"
				
				print_debug("[Enemy] Checking down files for variant ", variant, ":")
				print_debug("  PNG: ", png_path, " exists: ", ResourceLoader.exists(png_path))
				print_debug("  JPG: ", jpg_path, " exists: ", ResourceLoader.exists(jpg_path))
				
				if ResourceLoader.exists(png_path):
					file_path = png_path
				elif ResourceLoader.exists(jpg_path):
					file_path = jpg_path
			
			"left":
				# Try PNG first, then JPG
				var png_path = "res://assets/Brute/Brute " + str(variant) + " left walking.png"
				var jpg_path = "res://assets/Brute/Brute " + str(variant) + " left walking.JPG"
				
				print_debug("[Enemy] Checking left files for variant ", variant, ":")
				print_debug("  PNG: ", png_path, " exists: ", ResourceLoader.exists(png_path))
				print_debug("  JPG: ", jpg_path, " exists: ", ResourceLoader.exists(jpg_path))
				
				if ResourceLoader.exists(png_path):
					file_path = png_path
				elif ResourceLoader.exists(jpg_path):
					file_path = jpg_path
			
			"right":
				# Try PNG first, then JPG
				var png_path = "res://assets/Brute/Brute " + str(variant) + " right walking.png"
				var jpg_path = "res://assets/Brute/Brute " + str(variant) + " right walking.JPG"
				
				print_debug("[Enemy] Checking right files for variant ", variant, ":")
				print_debug("  PNG: ", png_path, " exists: ", ResourceLoader.exists(png_path))
				print_debug("  JPG: ", jpg_path, " exists: ", ResourceLoader.exists(jpg_path))
				
				if ResourceLoader.exists(png_path):
					file_path = png_path
				elif ResourceLoader.exists(jpg_path):
					file_path = jpg_path
			
			"up":
				# Try PNG first, then JPG
				var png_path = "res://assets/Brute/Brute " + str(variant) + " up walking.png"
				var jpg_path = "res://assets/Brute/Brute " + str(variant) + " up walking.JPG"
				
				print_debug("[Enemy] Checking up files for variant ", variant, ":")
				print_debug("  PNG: ", png_path, " exists: ", ResourceLoader.exists(png_path))
				print_debug("  JPG: ", jpg_path, " exists: ", ResourceLoader.exists(jpg_path))
				
				if ResourceLoader.exists(png_path):
					file_path = png_path
				elif ResourceLoader.exists(jpg_path):
					file_path = jpg_path
		
		# Add the file if we found one
		if file_path != "":
			frame_files.append(file_path)
		else:
			print_debug("[Enemy] No file found for Brute " + str(variant) + " " + animation_type + " walking")
	
	# Add each variant as a frame in the animation
	var frame_count = 0
	for frame_path in frame_files:
		var texture = load(frame_path)
		if texture:
			# Process the texture (resize and remove background)
			var processed_texture = process_individual_frame(texture)
			sprite_frames.add_frame(anim_name, processed_texture)
			frame_count += 1
			if debug_logging:
				print_debug("[Enemy] Added frame for ", anim_name, " from ", frame_path)
		else:
			if debug_logging:
				print_debug("[Enemy] Failed to load frame: ", frame_path)
	
	# If no frames were loaded, create a fallback
	if frame_count == 0:
		print_debug("[Enemy] No frames loaded for " + anim_name + ", creating fallback")
		# Create a simple colored rectangle as fallback
		var fallback_texture = create_fallback_texture()
		sprite_frames.add_frame(anim_name, fallback_texture)
		frame_count = 1
	
	print_debug("[Enemy] Set up animation: " + anim_name + " with " + str(frame_count) + " frames")

func create_fallback_texture() -> Texture2D:
	"""Create a simple fallback texture when files can't be loaded"""
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	# Fill with a simple red color
	image.fill(Color(1.0, 0.0, 0.0, 1.0))
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func process_individual_frame(texture: Texture2D) -> Texture2D:
	"""Process an individual JPG frame: resize and optionally remove background with better quality"""
	var image = texture.get_image()
	var original_size = Vector2i(image.get_width(), image.get_height())
	
	# Convert to RGBA format to ensure we can modify alpha
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	
	# Optionally remove white background (can be disabled if images are already clean)
	if enable_background_removal:
		remove_white_background_improved(image)
		# Additional artifact cleaning if enabled
		if enable_artifact_cleaning:
			clean_isolated_pixels(image)
	
	# Resize to target size (32x32 pixels for game tiles) with quality settings
	var target_size = Vector2i(32, 32)
	
	# Skip resize if image is already the correct size and skip_resize_if_correct_size is enabled
	if not (skip_resize_if_correct_size and image.get_width() == target_size.x and image.get_height() == target_size.y):
		var interpolation_method = Image.INTERPOLATE_CUBIC if use_high_quality_resize else Image.INTERPOLATE_LANCZOS
		image.resize(target_size.x, target_size.y, interpolation_method)
	
	# Create new texture from processed image
	var processed_texture = ImageTexture.new()
	processed_texture.set_image(image)
	
	if debug_logging:
		print_debug("[Enemy] Processed individual frame: ", original_size, " -> ", target_size, " (bg_removal: ", enable_background_removal, ", hq_resize: ", use_high_quality_resize, ")")
	
	return processed_texture

func setup_animation_frames(sprite_frames: SpriteFrames, anim_name: String, texture: Texture2D, frame_count: int, speed: float):
	"""Setup animation frames from a sprite sheet"""
	if not texture:
		if debug_logging:
			print_debug("[Enemy] Failed to load texture for animation: ", anim_name)
		return
	
	# Add the animation
	sprite_frames.add_animation(anim_name)
	sprite_frames.set_animation_speed(anim_name, speed)
	sprite_frames.set_animation_loop(anim_name, true)
	
	# Split sprite sheet into individual frames
	var frames = split_sprite_sheet(texture, frame_count)
	for frame_texture in frames:
		sprite_frames.add_frame(anim_name, frame_texture)
	
	if debug_logging:
		print_debug("[Enemy] Added animation: ", anim_name, " with ", frames.size(), " frames at speed: ", speed)

func split_sprite_sheet(texture: Texture2D, frame_count: int) -> Array:
	"""Split a sprite sheet into individual frame textures - handles both 2x2 grid and 4x1 horizontal formats"""
	var frames = []
	var image = texture.get_image()
	var width = texture.get_width()
	var height = texture.get_height()
	
	# Determine if it's 2x2 grid or 4x1 horizontal format
	var is_2x2_grid = (width == height * 2)  # 2x2 grid: width is 2x height
	var is_4x1_horizontal = (width == height * 4)  # 4x1 horizontal: width is 4x height
	
	var frame_width: int
	var frame_height: int
	var frame_positions: Array[Vector2i] = []
	
	if is_2x2_grid:
		# 2x2 grid format: 4 frames arranged in 2x2 grid
		frame_width = width / 2.0
		frame_height = height / 2.0
		frame_positions = [
			Vector2i(0, 0),           # Top-left
			Vector2i(frame_width, 0), # Top-right  
			Vector2i(0, frame_height), # Bottom-left
			Vector2i(frame_width, frame_height) # Bottom-right
		]
		print_debug("[Enemy] Detected 2x2 grid format: ", width, "x", height, " -> ", frame_width, "x", frame_height, " per frame")
	elif is_4x1_horizontal:
		# 4x1 horizontal format: 4 frames in a row
		frame_width = width / 4.0
		frame_height = height
		for i in range(4):
			frame_positions.append(Vector2i(i * frame_width, 0))
		print_debug("[Enemy] Detected 4x1 horizontal format: ", width, "x", height, " -> ", frame_width, "x", frame_height, " per frame")
	else:
		# Fallback: assume horizontal format
		frame_width = width / frame_count
		frame_height = height
		for i in range(frame_count):
			frame_positions.append(Vector2i(i * frame_width, 0))
		print_debug("[Enemy] Unknown format, using horizontal fallback: ", width, "x", height, " -> ", frame_width, "x", frame_height, " per frame")
	
	# Target size for game tiles (32x32 pixels)
	var target_size = Vector2i(32, 32)
	
	for i in range(frame_count):
		var frame_texture = ImageTexture.new()
		var frame_image = Image.create(frame_width, frame_height, false, image.get_format())
		
		# Copy the frame region from the sprite sheet
		var frame_pos = frame_positions[i] if i < frame_positions.size() else Vector2i(i * frame_width, 0)
		frame_image.blit_rect(image, Rect2i(frame_pos.x, frame_pos.y, frame_width, frame_height), Vector2i.ZERO)
		
		# Process the frame: remove white background and resize
		frame_image = process_sprite_frame(frame_image, target_size)
		
		frame_texture.set_image(frame_image)
		frames.append(frame_texture)
	
	return frames

func process_sprite_frame(image: Image, target_size: Vector2i) -> Image:
	"""Process a sprite frame: remove white background and resize to target size"""
	var original_size = Vector2i(image.get_width(), image.get_height())
	
	# Convert to RGBA format to ensure we can modify alpha
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	
	# Remove white background (make it transparent)
	remove_white_background(image)
	
	# Resize to target size
	image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	
	if debug_logging:
		print_debug("[Enemy] Processed sprite frame: ", original_size, " -> ", target_size)
	
	return image

func remove_white_background_improved(image: Image):
	"""Remove white/light backgrounds with advanced algorithm to eliminate artifacts and small pixels"""
	var width = image.get_width()
	var height = image.get_height()
	var transparent_pixels = 0
	
	# First pass: aggressive background removal
	for y in range(height):
		for x in range(width):
			var pixel = image.get_pixel(x, y)
			
			# More aggressive background detection
			var brightness = (pixel.r + pixel.g + pixel.b) / 3.0
			var max_component = max(pixel.r, pixel.g, pixel.b)
			var min_component = min(pixel.r, pixel.g, pixel.b)
			var saturation = max_component - min_component
			
			# Very aggressive thresholds to catch all white/light backgrounds
			var is_white = pixel.r > 0.8 and pixel.g > 0.8 and pixel.b > 0.8
			var is_light_gray = brightness > 0.75 and saturation < 0.2
			var is_very_light = brightness > 0.8 and saturation < 0.15
			var is_off_white = pixel.r > 0.85 and pixel.g > 0.85 and pixel.b > 0.85
			
			# Make background transparent
			if is_white or is_light_gray or is_very_light or is_off_white:
				image.set_pixel(x, y, Color.TRANSPARENT)
				transparent_pixels += 1
	
	# Second pass: clean up isolated pixels and artifacts
	clean_isolated_pixels(image)
	
	if debug_logging:
		var total_pixels = width * height
		var transparency_percent = (float(transparent_pixels) / float(total_pixels)) * 100.0
		print_debug("[Enemy] Advanced background removal: ", transparent_pixels, " pixels made transparent (", "%.1f" % transparency_percent, "%)")

func clean_isolated_pixels(image: Image):
	"""Remove isolated pixels and small artifacts that might be left behind"""
	var width = image.get_width()
	var height = image.get_height()
	var cleaned_pixels = 0
	
	# Create a copy to avoid modifying while reading
	var original_image = image.duplicate()
	
	for y in range(1, height - 1):  # Skip edges
		for x in range(1, width - 1):  # Skip edges
			var current_pixel = original_image.get_pixel(x, y)
			
			# Skip if already transparent
			if current_pixel.a < 0.1:
				continue
			
			# Check surrounding pixels
			var transparent_neighbors = 0
			var total_neighbors = 0
			
			# Check 8 surrounding pixels
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0:
						continue
					
					var neighbor = original_image.get_pixel(x + dx, y + dy)
					total_neighbors += 1
					if neighbor.a < 0.1:  # Transparent
						transparent_neighbors += 1
			
			# If most neighbors are transparent, this might be an artifact
			if transparent_neighbors >= total_neighbors * 0.7:  # 70% or more neighbors are transparent
				image.set_pixel(x, y, Color.TRANSPARENT)
				cleaned_pixels += 1
	
	if debug_logging:
		print_debug("[Enemy] Cleaned ", cleaned_pixels, " isolated pixels/artifacts")

func remove_white_background(image: Image):
	"""Remove white/light backgrounds and make them transparent (legacy function)"""
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
	
	if debug_logging:
		var total_pixels = width * height
		var transparency_percent = (float(transparent_pixels) / float(total_pixels)) * 100.0
		print_debug("[Enemy] Background removal: ", transparent_pixels, " pixels made transparent (", "%.1f" % transparency_percent, "%)")

func _physics_process(delta):
	# Find player if we don't have a reference
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			if debug_logging:
				print_debug("[Enemy] No player found in group 'player'")
			return
	
	# Check if player is in detection range
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= detection_range_px:
		if not is_chasing:
			is_chasing = true
			is_wandering = false  # Stop wandering when chasing
			chase_phase = "approach"  # Reset to approach phase
			if debug_logging:
				print_debug("[Enemy] Started chasing player")
		
		# Chase the player
		chase_player(delta)
	else:
		if is_chasing:
			is_chasing = false
			if debug_logging:
				print_debug("[Enemy] Lost player, going idle")
		
		# Handle wandering and idle behavior
		handle_idle_and_wandering(delta)
	
	# Apply movement
	move_and_slide()
	
	# Debug collision detection
	if debug_logging and (is_chasing or is_wandering) and velocity.length() > 0:
		if is_on_wall():
			print_debug("[Enemy] Hit wall while moving - position: ", global_position)
		if is_on_floor() and velocity.y > 0:
			print_debug("[Enemy] On floor - position: ", global_position)

func chase_player(delta: float):
	"""Advanced multi-phase chase behavior: approach, track, lunge"""
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# Update chase phase based on distance and timers
	update_chase_phase(distance_to_player, delta)
	
	match chase_phase:
		"approach":
			# Phase 1: Approach the player until close enough
			velocity = direction_to_player * move_speed_px_s
			update_facing_direction(direction_to_player)
			if debug_logging:
				print_debug("[Enemy] Approaching player - distance: ", distance_to_player)
		
		"track":
			# Phase 2: Rotate around player at a distance
			track_player(direction_to_player, distance_to_player, delta)
			if debug_logging:
				print_debug("[Enemy] Tracking player - angle: ", rotation_angle, " distance: ", distance_to_player)
		
		"lunge":
			# Phase 3: Lunge at player
			lunge_at_player(direction_to_player)
			if debug_logging:
				print_debug("[Enemy] Lunging at player!")
		
		"recover":
			# Phase 4: Brief recovery after lunge
			velocity = Vector2.ZERO
			if debug_logging:
				print_debug("[Enemy] Recovering from lunge")

func update_chase_phase(distance_to_player: float, delta: float):
	"""Update the current chase phase based on distance and timers"""
	match chase_phase:
		"approach":
			# Switch to tracking when close enough
			if distance_to_player <= lunge_distance:
				chase_phase = "track"
				track_timer = 0.0
				track_duration = randf_range(track_duration_min, track_duration_max)
				rotation_angle = 0.0
				if debug_logging:
					print_debug("[Enemy] Switching to tracking phase")
		
		"track":
			# Track for a random duration, then lunge
			track_timer += delta
			if track_timer >= track_duration and lunge_cooldown <= 0.0:
				chase_phase = "lunge"
				lunge_timer = 0.0
				if debug_logging:
					print_debug("[Enemy] Switching to lunge phase")
		
		"lunge":
			# Lunge for a short duration, then recover
			lunge_timer += delta
			if lunge_timer >= 0.5:  # Lunge duration
				chase_phase = "recover"
				lunge_cooldown = randf_range(lunge_cooldown_min, lunge_cooldown_max)
				if debug_logging:
					print_debug("[Enemy] Switching to recover phase")
		
		"recover":
			# Recover briefly, then back to tracking
			lunge_cooldown -= delta
			if lunge_cooldown <= 0.0:
				chase_phase = "track"
				track_timer = 0.0
				track_duration = randf_range(track_duration_min, track_duration_max)
				if debug_logging:
					print_debug("[Enemy] Switching back to tracking phase")

func track_player(direction_to_player: Vector2, distance_to_player: float, delta: float):
	"""Rotate around player while maintaining distance"""
	# Update rotation angle
	rotation_angle += rotation_speed * delta
	
	# Calculate position around player
	var angle_rad = deg_to_rad(rotation_angle)
	var offset = Vector2(cos(angle_rad), sin(angle_rad)) * lunge_distance
	var target_position = player.global_position + offset
	
	# Move towards the calculated position
	var direction_to_target = (target_position - global_position).normalized()
	velocity = direction_to_target * move_speed_px_s * 0.7  # Slightly slower while tracking
	update_facing_direction(direction_to_target)

func lunge_at_player(direction_to_player: Vector2):
	"""Lunge directly at player with increased speed"""
	velocity = direction_to_player * move_speed_px_s * lunge_speed_multiplier
	update_facing_direction(direction_to_player)

func handle_idle_and_wandering(delta: float):
	"""Handle both idle and wandering behavior when not chasing"""
	# Update wander timer
	wander_timer += delta
	
	if is_wandering:
		# Currently wandering
		wander_timer += delta
		if wander_timer >= wander_duration:
			# Stop wandering
			is_wandering = false
			velocity = Vector2.ZERO
			next_wander_time = randf_range(wander_cooldown_min, wander_cooldown_max)
			if debug_logging:
				print_debug("[Enemy] Finished wandering, going idle")
		else:
			# Continue wandering
			velocity = wander_direction * move_speed_px_s * 0.5  # Slower than chasing
			update_facing_direction(wander_direction)
			if debug_logging:
				print_debug("[Enemy] Wandering in direction: ", wander_direction)
	else:
		# Not wandering, check if it's time to start
		if wander_timer >= next_wander_time:
			# Start wandering
			start_wandering()
		else:
			# Just idle
			idle_behavior()

func idle_behavior():
	"""Idle behavior when not chasing - cycles through Grunt 1-5 sequence"""
	velocity = Vector2.ZERO
	# Play idle animation based on last facing direction
	# All idle animations cycle through the same Grunt 1-5 sequence with custom durations
	var idle_anim = ""
	match last_direction:
		Vector2.UP:
			idle_anim = "idle_up"
		Vector2.DOWN:
			idle_anim = "idle_down"
		Vector2.LEFT:
			idle_anim = "idle_left"
		Vector2.RIGHT:
			idle_anim = "idle_right"
		_:
			# Default to down if no direction is set
			idle_anim = "idle_down"
	
	play_animation(idle_anim)
	if debug_logging:
		print_debug("[Enemy] Playing cycling idle animation: ", idle_anim, " (Grunt 1-5 sequence with custom durations)")

func start_wandering():
	"""Start a random wandering behavior"""
	is_wandering = true
	wander_timer = 0.0
	wander_duration = randf_range(wander_duration_min, wander_duration_max)
	
	# Choose a random direction
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	wander_direction = directions[randi() % directions.size()]
	
	if debug_logging:
		print_debug("[Enemy] Started wandering for ", wander_duration, " seconds in direction: ", wander_direction)

func attack_player():
	"""Attack the player if in range"""
	if debug_logging:
		print_debug("[Enemy] Attacking player!")
	# TODO: Implement attack animation and damage dealing
	# For now, just print debug message

func update_facing_direction(direction: Vector2):
	"""Update sprite facing direction and animation based on movement"""
	if abs(direction.x) > abs(direction.y):
		# Horizontal movement
		if direction.x > 0:
			last_direction = Vector2.RIGHT
			play_animation("walk_right")
		else:
			last_direction = Vector2.LEFT
			play_animation("walk_left")
	else:
		# Vertical movement
		if direction.y > 0:
			last_direction = Vector2.DOWN
			play_animation("walk_down")
		else:
			last_direction = Vector2.UP
			play_animation("walk_up")

func play_animation(anim_name: String):
	"""Play the specified animation"""
	if sprite and sprite.sprite_frames:
		sprite.play(anim_name)

func take_damage(damage: int):
	"""Take damage and handle death"""
	health -= damage
	if debug_logging:
		print_debug("[Enemy] Took ", damage, " damage. Health: ", health)
	
	if health <= 0:
		die()

func die():
	"""Handle enemy death"""
	if debug_logging:
		print_debug("[Enemy] Died!")
	queue_free()

func _on_animation_finished():
	"""Handle animation finished events"""
	# If we're not moving, play idle animation
	if velocity.length() == 0:
		match last_direction:
			Vector2.UP:
				play_animation("idle_up")
			Vector2.DOWN:
				play_animation("idle_down")
			Vector2.LEFT:
				play_animation("idle_left")
			Vector2.RIGHT:
				play_animation("idle_right")
