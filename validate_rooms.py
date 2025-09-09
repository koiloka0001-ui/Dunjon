#!/usr/bin/env python3
"""
Room validation script for Dunjon
Validates that all room files are properly formatted for 32x32 tiles
"""

import json
import os
import glob
import sys

def validate_room_file(file_path):
    """Validate a single room file"""
    print(f"Validating {os.path.basename(file_path)}...")
    
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ JSON parse error: {e}")
        return False
    except Exception as e:
        print(f"❌ File read error: {e}")
        return False
    
    errors = []
    warnings = []
    
    # Check tile dimensions
    if 'tilewidth' not in data or 'tileheight' not in data:
        errors.append("Missing tile dimensions")
    elif data['tilewidth'] != 32 or data['tileheight'] != 32:
        errors.append(f"Wrong tile size: {data['tilewidth']}x{data['tileheight']} (should be 32x32)")
    
    # Check tileset source
    if 'tilesets' not in data or len(data['tilesets']) == 0:
        errors.append("No tilesets defined")
    else:
        for tileset in data['tilesets']:
            if 'source' not in tileset:
                errors.append("Tileset missing source")
            elif not tileset['source'].endswith('dunjon_tileset.tsx'):
                warnings.append(f"Tileset source: {tileset['source']} (should be dunjon_tileset.tsx)")
    
    # Check layers
    if 'layers' not in data:
        errors.append("No layers defined")
    else:
        has_ground = False
        has_collision = False
        has_entities = False
        has_metadata = False
        
        for layer in data['layers']:
            if layer.get('type') == 'tilelayer':
                if layer.get('name') == 'Ground':
                    has_ground = True
                elif layer.get('name') == 'Collision':
                    has_collision = True
            elif layer.get('type') == 'objectgroup':
                if layer.get('name') == 'Entities':
                    has_entities = True
                elif layer.get('name') == 'Metadata':
                    has_metadata = True
        
        if not has_ground:
            warnings.append("Missing Ground layer")
        if not has_collision:
            warnings.append("Missing Collision layer")
        if not has_entities:
            warnings.append("Missing Entities layer")
        if not has_metadata:
            warnings.append("Missing Metadata layer")
    
    # Check object dimensions (should be 32x32 for 32x32 tiles)
    if 'layers' in data:
        for layer in data['layers']:
            if layer.get('type') == 'objectgroup' and 'objects' in layer:
                for obj in layer['objects']:
                    if 'width' in obj and 'height' in obj:
                        if obj['width'] != 32 or obj['height'] != 32:
                            warnings.append(f"Object {obj.get('name', 'unnamed')} size: {obj['width']}x{obj['height']} (should be 32x32)")
    
    # Report results
    if errors:
        print(f"❌ {len(errors)} errors:")
        for error in errors:
            print(f"   - {error}")
        return False
    elif warnings:
        print(f"⚠️  {len(warnings)} warnings:")
        for warning in warnings:
            print(f"   - {warning}")
        print("✅ Validation passed with warnings")
        return True
    else:
        print("✅ Validation passed")
        return True

def main():
    """Validate all room files"""
    rooms_dir = "game-godot/data/rooms"
    
    if not os.path.exists(rooms_dir):
        print(f"❌ Rooms directory not found: {rooms_dir}")
        sys.exit(1)
    
    # Find all JSON files
    room_files = glob.glob(os.path.join(rooms_dir, "*.json"))
    
    if not room_files:
        print(f"❌ No JSON files found in {rooms_dir}")
        sys.exit(1)
    
    print(f"Validating {len(room_files)} room files...")
    print("=" * 50)
    
    valid_count = 0
    invalid_count = 0
    
    for file_path in room_files:
        if validate_room_file(file_path):
            valid_count += 1
        else:
            invalid_count += 1
        print()
    
    print("=" * 50)
    print(f"Validation complete: {valid_count} valid, {invalid_count} invalid")
    
    if invalid_count > 0:
        sys.exit(1)
    else:
        print("🎉 All rooms are valid!")

if __name__ == "__main__":
    main()

