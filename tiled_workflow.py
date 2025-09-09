#!/usr/bin/env python3
"""
Tiled Workflow Helper
Manages the conversion between Tiled TMX files and Godot JSON files
"""

import os
import json
import xml.etree.ElementTree as ET
import sys

def tmx_to_json(tmx_file, json_file):
    """Convert a Tiled TMX file to Godot JSON format"""
    print(f"Converting {tmx_file} to {json_file}...")
    
    try:
        # Parse TMX file
        tree = ET.parse(tmx_file)
        root = tree.getroot()
        
        # Extract map properties
        map_width = int(root.get('width'))
        map_height = int(root.get('height'))
        tile_width = int(root.get('tilewidth'))
        tile_height = int(root.get('tileheight'))
        
        # Create JSON structure
        json_data = {
            "compressionlevel": -1,
            "height": map_height,
            "infinite": False,
            "layers": [],
            "nextlayerid": 5,
            "nextobjectid": 4,
            "orientation": "orthogonal",
            "renderorder": "right-down",
            "tiledversion": "1.11.2",
            "tileheight": tile_height,
            "tilesets": [],
            "tilewidth": tile_width,
            "type": "map",
            "version": "1.10",
            "width": map_width,
            "backgroundcolor": "#000000"
        }
        
        # Process tilesets
        for tileset in root.findall('tileset'):
            tileset_data = {
                "firstgid": int(tileset.get('firstgid')),
                "source": tileset.get('source')
            }
            json_data["tilesets"].append(tileset_data)
        
        # Process layers
        layer_id = 1
        for layer in root.findall('layer'):
            layer_data = {
                "data": "",
                "encoding": "csv",
                "height": map_height,
                "id": layer_id,
                "name": layer.get('name'),
                "opacity": 1,
                "type": "tilelayer",
                "visible": True,
                "width": map_width,
                "x": 0,
                "y": 0,
                "offsetx": 0,
                "offsety": 0,
                "parallaxx": 1.0,
                "parallaxy": 1.0,
                "tintcolor": "#000000"
            }
            
            # Process tile data
            data_element = layer.find('data')
            if data_element is not None:
                layer_data["data"] = data_element.text.strip()
            
            json_data["layers"].append(layer_data)
            layer_id += 1
        
        # Process object groups
        for objectgroup in root.findall('objectgroup'):
            objects = []
            for obj in objectgroup.findall('object'):
                obj_data = {
                    "height": int(obj.get('height', 0)),
                    "id": int(obj.get('id', 0)),
                    "name": obj.get('name', ''),
                    "properties": [],
                    "rotation": float(obj.get('rotation', 0)),
                    "type": obj.get('type', ''),
                    "visible": obj.get('visible', 'true').lower() == 'true',
                    "width": int(obj.get('width', 0)),
                    "x": float(obj.get('x', 0)),
                    "y": float(obj.get('y', 0))
                }
                
                # Process properties
                for prop in obj.findall('properties/property'):
                    prop_data = {
                        "name": prop.get('name'),
                        "type": prop.get('type', 'string'),
                        "value": prop.get('value')
                    }
                    obj_data["properties"].append(prop_data)
                
                objects.append(obj_data)
            
            objectgroup_data = {
                "draworder": objectgroup.get('draworder', 'topdown'),
                "id": layer_id,
                "name": objectgroup.get('name'),
                "objects": objects,
                "opacity": 1,
                "type": "objectgroup",
                "visible": True,
                "x": 0,
                "y": 0
            }
            
            json_data["layers"].append(objectgroup_data)
            layer_id += 1
        
        # Write JSON file
        with open(json_file, 'w') as f:
            json.dump(json_data, f, indent=2)
        
        print(f"✅ Successfully converted {tmx_file} to {json_file}")
        return True
        
    except Exception as e:
        print(f"❌ Error converting {tmx_file}: {e}")
        return False

def convert_all_tmx_files():
    """Convert all TMX files in tiles/ directory to JSON files in game-godot/data/rooms/"""
    tiles_dir = "tiles"
    rooms_dir = "game-godot/data/rooms"
    
    if not os.path.exists(tiles_dir):
        print(f"❌ Tiles directory not found: {tiles_dir}")
        return False
    
    if not os.path.exists(rooms_dir):
        print(f"❌ Rooms directory not found: {rooms_dir}")
        return False
    
    # Find all TMX files
    tmx_files = [f for f in os.listdir(tiles_dir) if f.endswith('.tmx')]
    
    if not tmx_files:
        print("❌ No TMX files found in tiles/ directory")
        return False
    
    print(f"Found {len(tmx_files)} TMX files to convert:")
    for tmx_file in tmx_files:
        print(f"  - {tmx_file}")
    
    print("\nConverting files...")
    success_count = 0
    
    for tmx_file in tmx_files:
        tmx_path = os.path.join(tiles_dir, tmx_file)
        json_file = tmx_file.replace('.tmx', '.json')
        json_path = os.path.join(rooms_dir, json_file)
        
        if tmx_to_json(tmx_path, json_path):
            success_count += 1
    
    print(f"\n✅ Conversion complete: {success_count}/{len(tmx_files)} files converted successfully")
    return success_count == len(tmx_files)

def main():
    """Main function"""
    print("Tiled Workflow Helper")
    print("=" * 30)
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "convert":
            convert_all_tmx_files()
        else:
            print("Usage: python tiled_workflow.py [convert]")
    else:
        print("Available commands:")
        print("  convert - Convert all TMX files to JSON")
        print("\nUsage: python tiled_workflow.py convert")

if __name__ == "__main__":
    main()

