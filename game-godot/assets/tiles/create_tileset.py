#!/usr/bin/env python3
"""
Simple script to create a basic tileset for Dunjon
Creates a 32x32 pixel tileset with different colored tiles
"""

from PIL import Image, ImageDraw

# Create a 64x64 pixel image (2x2 tiles of 32x32 each)
tileset = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
draw = ImageDraw.Draw(tileset)

# Tile 1: Ground (brown)
draw.rectangle([0, 0, 31, 31], fill=(139, 69, 19, 255))  # Brown
draw.rectangle([2, 2, 29, 29], fill=(160, 82, 45, 255))  # Lighter brown border

# Tile 2: Wall (dark gray)
draw.rectangle([32, 0, 63, 31], fill=(64, 64, 64, 255))  # Dark gray
draw.rectangle([34, 2, 61, 29], fill=(96, 96, 96, 255))  # Lighter gray border

# Save the tileset
tileset.save('tileset.png')
print("Tileset created: tileset.png")

