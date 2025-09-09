from PIL import Image
import os

# Load the individual tile images
ground_img = Image.open('ground_tile.png')
wall_img = Image.open('wall_tile.png')

# Resize to 16x16 if needed
ground_img = ground_img.resize((16, 16), Image.Resampling.LANCZOS)
wall_img = wall_img.resize((16, 16), Image.Resampling.LANCZOS)

# Create a 48x16 combined image (3 tiles)
combined = Image.new('RGBA', (48, 16), (0, 0, 0, 0))

# Paste the tiles side by side
# Tile 0: Empty/transparent
# Tile 1: Ground
combined.paste(ground_img, (16, 0))
# Tile 2: Wall
combined.paste(wall_img, (32, 0))

# Save the combined tileset
combined.save('tileset.png')
print("Tileset created successfully!")
