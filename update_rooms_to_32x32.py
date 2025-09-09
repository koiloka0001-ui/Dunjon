#!/usr/bin/env python3
"""
Script to update all room files from 16x16 to 32x32 tile format
"""

import json
import os
import glob

def update_room_file(file_path):
    """Update a single room file to use 32x32 tiles"""
    print(f"Updating {file_path}...")
    
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    # Update tile dimensions
    data['tilewidth'] = 32
    data['tileheight'] = 32
    
    # Update tileset source
    if 'tilesets' in data:
        for tileset in data['tilesets']:
            if 'source' in tileset:
                tileset['source'] = "../tiles/dunjon_tileset.tsx"
    
    # Update object dimensions and positions
    if 'layers' in data:
        for layer in data['layers']:
            if layer.get('type') == 'objectgroup' and 'objects' in layer:
                for obj in layer['objects']:
                    # Double the position for 32x32 tiles
                    if 'x' in obj:
                        obj['x'] = obj['x'] * 2
                    if 'y' in obj:
                        obj['y'] = obj['y'] * 2
                    
                    # Set standard object size to 32x32 (don't double existing sizes)
                    if 'width' in obj and obj['width'] > 0:
                        obj['width'] = 32
                    if 'height' in obj and obj['height'] > 0:
                        obj['height'] = 32
    
    # Write back to file
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"✅ Updated {file_path}")

def main():
    """Update all room files"""
    rooms_dir = "game-godot/data/rooms"
    
    if not os.path.exists(rooms_dir):
        print(f"❌ Rooms directory not found: {rooms_dir}")
        return
    
    # Find all JSON files
    room_files = glob.glob(os.path.join(rooms_dir, "*.json"))
    
    if not room_files:
        print(f"❌ No JSON files found in {rooms_dir}")
        return
    
    print(f"Found {len(room_files)} room files to update:")
    for file_path in room_files:
        print(f"  - {os.path.basename(file_path)}")
    
    print("\nUpdating files...")
    for file_path in room_files:
        try:
            update_room_file(file_path)
        except Exception as e:
            print(f"❌ Error updating {file_path}: {e}")
    
    print("\n✅ All room files updated to 32x32 tile format!")

if __name__ == "__main__":
    main()
