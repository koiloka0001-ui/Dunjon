#!/usr/bin/env python3
"""
JSON to TMX Converter
Converts existing JSON room files back to TMX files for editing in Tiled
"""

import os
import json
import xml.etree.ElementTree as ET
from pathlib import Path

def json_to_tmx(json_file, tmx_file):
    """Convert a JSON room file to TMX format"""
    print(f"Converting {json_file.name} to {tmx_file.name}...")
    
    try:
        # Load JSON data
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        # Create TMX root element
        root = ET.Element('map')
        root.set('version', '1.10')
        root.set('tiledversion', '1.11.2')
        root.set('orientation', 'orthogonal')
        root.set('renderorder', 'right-down')
        root.set('width', str(data['width']))
        root.set('height', str(data['height']))
        root.set('tilewidth', str(data['tilewidth']))
        root.set('tileheight', str(data['tileheight']))
        root.set('infinite', '0')
        root.set('nextlayerid', str(data['nextlayerid']))
        root.set('nextobjectid', str(data['nextobjectid']))
        
        # Add tilesets
        for tileset in data.get('tilesets', []):
            tileset_elem = ET.SubElement(root, 'tileset')
            tileset_elem.set('firstgid', str(tileset['firstgid']))
            # Fix tileset path - remove ../tiles/ prefix if present
            source_path = tileset['source']
            if source_path.startswith('../tiles/'):
                source_path = source_path.replace('../tiles/', '')
            tileset_elem.set('source', source_path)
        
        # Add layers
        layer_id = 1
        for layer in data.get('layers', []):
            if layer['type'] == 'tilelayer':
                layer_elem = ET.SubElement(root, 'layer')
                layer_elem.set('id', str(layer_id))
                layer_elem.set('name', layer['name'])
                layer_elem.set('width', str(layer['width']))
                layer_elem.set('height', str(layer['height']))
                
                # Add data element
                data_elem = ET.SubElement(layer_elem, 'data')
                data_elem.set('encoding', layer['encoding'])
                
                # Fix CSV format - ensure proper line endings and trailing commas
                csv_data = layer['data']
                if layer['encoding'] == 'csv':
                    # Split into lines and ensure each line ends with a comma
                    lines = csv_data.split('\n')
                    fixed_lines = []
                    for line in lines:
                        if line.strip() and not line.strip().endswith(','):
                            line = line.strip() + ','
                        fixed_lines.append(line)
                    csv_data = '\n'.join(fixed_lines)
                
                data_elem.text = csv_data
                
                layer_id += 1
            
            elif layer['type'] == 'objectgroup':
                objectgroup_elem = ET.SubElement(root, 'objectgroup')
                objectgroup_elem.set('id', str(layer_id))
                objectgroup_elem.set('name', layer['name'])
                objectgroup_elem.set('draworder', layer.get('draworder', 'topdown'))
                
                # Add objects
                for obj in layer.get('objects', []):
                    obj_elem = ET.SubElement(objectgroup_elem, 'object')
                    obj_elem.set('id', str(obj['id']))
                    obj_elem.set('name', obj['name'])
                    obj_elem.set('type', obj['type'])
                    obj_elem.set('x', str(obj['x']))
                    obj_elem.set('y', str(obj['y']))
                    obj_elem.set('width', str(obj['width']))
                    obj_elem.set('height', str(obj['height']))
                    obj_elem.set('visible', str(obj['visible']).lower())
                    
                    if obj.get('rotation', 0) != 0:
                        obj_elem.set('rotation', str(obj['rotation']))
                    
                    # Add properties
                    if obj.get('properties'):
                        properties_elem = ET.SubElement(obj_elem, 'properties')
                        for prop in obj['properties']:
                            prop_elem = ET.SubElement(properties_elem, 'property')
                            prop_elem.set('name', prop['name'])
                            prop_elem.set('type', prop['type'])
                            prop_elem.set('value', str(prop['value']))
                
                layer_id += 1
        
        # Write TMX file
        tree = ET.ElementTree(root)
        ET.indent(tree, space=" ", level=0)
        tree.write(tmx_file, encoding='utf-8', xml_declaration=True)
        
        print(f"✅ Successfully converted {json_file.name} to {tmx_file.name}")
        return True
        
    except Exception as e:
        print(f"❌ Error converting {json_file.name}: {e}")
        return False

def convert_all_json_to_tmx():
    """Convert all JSON room files to TMX files"""
    rooms_dir = Path("game-godot/data/rooms")
    tiles_dir = Path("tiles")
    
    if not rooms_dir.exists():
        print(f"❌ Rooms directory not found: {rooms_dir}")
        return False
    
    if not tiles_dir.exists():
        print(f"❌ Tiles directory not found: {tiles_dir}")
        return False
    
    # Find all JSON files
    json_files = [f for f in rooms_dir.glob("*.json") if f.name not in ['enemies.json', 'options.json', 'tuning.json']]
    
    if not json_files:
        print("❌ No room JSON files found")
        return False
    
    print(f"Found {len(json_files)} room JSON files to convert:")
    for json_file in json_files:
        print(f"  - {json_file.name}")
    
    print("\nConverting files...")
    success_count = 0
    
    for json_file in json_files:
        tmx_file = tiles_dir / (json_file.stem + '.tmx')
        
        if json_to_tmx(json_file, tmx_file):
            success_count += 1
    
    print(f"\n✅ Conversion complete: {success_count}/{len(json_files)} files converted successfully")
    return success_count == len(json_files)

def main():
    """Main function"""
    print("JSON to TMX Converter")
    print("=" * 30)
    print("Converting existing JSON room files to TMX files for editing")
    print()
    
    if convert_all_json_to_tmx():
        print("\n🎉 All room files are now available for editing in Tiled!")
        print("You can now open the .tmx files in the tiles/ directory with Tiled Map Editor")
    else:
        print("\n❌ Some files failed to convert. Check the error messages above.")

if __name__ == "__main__":
    main()
