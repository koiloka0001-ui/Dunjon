#!/usr/bin/env python3
"""
Validate TMX Files
Quick validation to check if TMX files can be parsed correctly
"""

import os
import xml.etree.ElementTree as ET
from pathlib import Path

def validate_tmx_file(tmx_file):
    """Validate a single TMX file"""
    print(f"Validating {tmx_file.name}...")
    
    try:
        # Try to parse the TMX file
        tree = ET.parse(tmx_file)
        root = tree.getroot()
        
        # Check basic structure
        if root.tag != 'map':
            print(f"❌ Invalid root element: {root.tag}")
            return False
        
        # Check required attributes
        required_attrs = ['version', 'width', 'height', 'tilewidth', 'tileheight']
        for attr in required_attrs:
            if attr not in root.attrib:
                print(f"❌ Missing required attribute: {attr}")
                return False
        
        # Check tileset
        tilesets = root.findall('tileset')
        if not tilesets:
            print(f"❌ No tilesets found")
            return False
        
        for tileset in tilesets:
            if 'source' not in tileset.attrib:
                print(f"❌ Tileset missing source attribute")
                return False
        
        # Check layers
        layers = root.findall('layer')
        if not layers:
            print(f"❌ No layers found")
            return False
        
        for layer in layers:
            # Check layer attributes
            if 'name' not in layer.attrib:
                print(f"❌ Layer missing name attribute")
                return False
            
            # Check data element
            data_elem = layer.find('data')
            if data_elem is None:
                print(f"❌ Layer {layer.attrib.get('name', 'unnamed')} missing data element")
                return False
            
            # Check CSV format
            if data_elem.get('encoding') == 'csv':
                csv_data = data_elem.text
                if csv_data:
                    lines = csv_data.split('\n')
                    for i, line in enumerate(lines):
                        if line.strip() and not line.strip().endswith(','):
                            print(f"⚠️  Line {i+1} doesn't end with comma: {line[:20]}...")
        
        print(f"✅ {tmx_file.name} is valid")
        return True
        
    except ET.ParseError as e:
        print(f"❌ XML parse error: {e}")
        return False
    except Exception as e:
        print(f"❌ Validation error: {e}")
        return False

def main():
    """Validate all TMX files"""
    tiles_dir = Path("tiles")
    
    if not tiles_dir.exists():
        print("❌ Tiles directory not found")
        return
    
    # Find all TMX files
    tmx_files = list(tiles_dir.glob("*.tmx"))
    
    if not tmx_files:
        print("❌ No TMX files found")
        return
    
    print(f"Validating {len(tmx_files)} TMX files...")
    print("=" * 40)
    
    valid_count = 0
    for tmx_file in tmx_files:
        if validate_tmx_file(tmx_file):
            valid_count += 1
        print()
    
    print("=" * 40)
    print(f"Validation complete: {valid_count}/{len(tmx_files)} files valid")
    
    if valid_count == len(tmx_files):
        print("🎉 All TMX files are valid and ready for Tiled!")
    else:
        print("❌ Some files have issues. Check the error messages above.")

if __name__ == "__main__":
    main()


