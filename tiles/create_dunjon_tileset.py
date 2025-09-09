from PIL import Image
import os

# Load the individual tile images
ground_img = Image.open('ground_tile.png')
wall_img = Image.open('wall_tile.png')

# Resize to 32x32 to match Godot's tile size
ground_img = ground_img.resize((32, 32), Image.Resampling.LANCZOS)
wall_img = wall_img.resize((32, 32), Image.Resampling.LANCZOS)

# Create a 96x32 combined image (3 tiles of 32x32 each)
combined = Image.new('RGBA', (96, 32), (0, 0, 0, 0))

# Paste the tiles side by side
# Tile 0: Empty/transparent (left empty)
# Tile 1: Ground (middle)
combined.paste(ground_img, (32, 0))
# Tile 2: Wall (right)
combined.paste(wall_img, (64, 0))

# Save the combined tileset
combined.save('dunjon_tileset.png')
print("Dunjon tileset created successfully!")
print("Tileset: 96x32 pixels, 3 tiles of 32x32 each")

