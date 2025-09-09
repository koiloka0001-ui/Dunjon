#!/usr/bin/env python3
"""
Cleanup Tilesets
Remove Dungeon_wall references and ensure all TMX files use only Dunjon Tiles
"""

import os
import xml.etree.ElementTree as ET
from pathlib import Path

def cleanup_tmx_file(tmx_file):
    """Clean up a single TMX file to use only Dunjon Tiles"""
    print(f"Cleaning up {tmx_file.name}...")
    
    try:
        # Parse TMX file
        tree = ET.parse(tmx_file)
        root = tree.getroot()
        
        # Find all tileset elements
        tilesets = root.findall('tileset')
        
        # Remove any tilesets that reference Dungeon_wall
        tilesets_to_remove = []
        for tileset in tilesets:
            source = tileset.get('source', '')
            if 'Dungeon_wall' in source or 'dungeon_wall' in source:
                tilesets_to_remove.append(tileset)
                print(f"  Removing tileset: {source}")
        
        # Remove the unwanted tilesets
        for tileset in tilesets_to_remove:
            root.remove(tileset)
        
        # Ensure we have the correct Dunjon Tiles tileset
        has_dunjon_tiles = False
        for tileset in root.findall('tileset'):
            source = tileset.get('source', '')
            if 'dunjon_tileset.tsx' in source:
                has_dunjon_tiles = True
                # Ensure it has firstgid="1"
                tileset.set('firstgid', '1')
                break
        
        if not has_dunjon_tiles:
            # Add the Dunjon Tiles tileset if it's missing
            tileset_elem = ET.SubElement(root, 'tileset')
            tileset_elem.set('firstgid', '1')
            tileset_elem.set('source', 'dunjon_tileset.tsx')
            print(f"  Added Dunjon Tiles tileset")
        
        # Write the cleaned TMX file
        tree.write(tmx_file, encoding='utf-8', xml_declaration=True)
        
        print(f"✅ Cleaned up {tmx_file.name}")
        return True
        
    except Exception as e:
        print(f"❌ Error cleaning up {tmx_file.name}: {e}")
        return False

def cleanup_all_tmx_files():
    """Clean up all TMX files"""
    tiles_dir = Path("tiles")
    
    if not tiles_dir.exists():
        print("❌ Tiles directory not found")
        return False
    
    # Find all TMX files
    tmx_files = list(tiles_dir.glob("*.tmx"))
    
    if not tmx_files:
        print("❌ No TMX files found")
        return False
    
    print(f"Cleaning up {len(tmx_files)} TMX files...")
    print("=" * 40)
    
    success_count = 0
    for tmx_file in tmx_files:
        if cleanup_tmx_file(tmx_file):
            success_count += 1
        print()
    
    print("=" * 40)
    print(f"Cleanup complete: {success_count}/{len(tmx_files)} files cleaned")
    
    if success_count == len(tmx_files):
        print("🎉 All TMX files now use only Dunjon Tiles!")
    else:
        print("❌ Some files failed to clean up. Check the error messages above.")

def main():
    """Main function"""
    print("Tileset Cleanup Tool")
    print("=" * 30)
    print("Removing Dungeon_wall references and ensuring Dunjon Tiles usage")
    print()
    
    cleanup_all_tmx_files()

if __name__ == "__main__":
    main()


