#!/usr/bin/env python3
"""
Auto-Export Tiles
Automatically converts TMX files to JSON when saved in Tiled
"""

import os
import time
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class TiledFileHandler(FileSystemEventHandler):
    """Handles file system events for Tiled files"""
    
    def __init__(self):
        self.tiles_dir = Path("tiles")
        self.rooms_dir = Path("game-godot/data/rooms")
        self.last_modified = {}
    
    def on_modified(self, event):
        """Called when a file is modified"""
        if event.is_directory:
            return
        
        file_path = Path(event.src_path)
        
        # Only process TMX files
        if file_path.suffix.lower() != '.tmx':
            return
        
        # Check if this is actually a new modification
        current_time = time.time()
        if file_path in self.last_modified and current_time - self.last_modified[file_path] < 1.0:
            return  # Skip if modified within last second (avoid duplicate events)
        
        self.last_modified[file_path] = current_time
        
        # Convert TMX to JSON
        self.convert_tmx_to_json(file_path)
    
    def convert_tmx_to_json(self, tmx_file):
        """Convert a single TMX file to JSON"""
        try:
            print(f"🔄 Auto-converting {tmx_file.name}...")
            
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
            json_file = self.rooms_dir / (tmx_file.stem + '.json')
            with open(json_file, 'w') as f:
                json.dump(json_data, f, indent=2)
            
            print(f"✅ Auto-converted {tmx_file.name} → {json_file.name}")
            
        except Exception as e:
            print(f"❌ Error auto-converting {tmx_file.name}: {e}")

def main():
    """Start the auto-export service"""
    print("🚀 Starting Auto-Export Tiles Service")
    print("=" * 40)
    print("Watching tiles/ directory for changes...")
    print("Save any .tmx file in Tiled to auto-convert to JSON")
    print("Press Ctrl+C to stop")
    print("=" * 40)
    
    # Ensure directories exist
    tiles_dir = Path("tiles")
    rooms_dir = Path("game-godot/data/rooms")
    
    if not tiles_dir.exists():
        print(f"❌ Tiles directory not found: {tiles_dir}")
        return
    
    if not rooms_dir.exists():
        print(f"❌ Rooms directory not found: {rooms_dir}")
        return
    
    # Create event handler
    event_handler = TiledFileHandler()
    
    # Create observer
    observer = Observer()
    observer.schedule(event_handler, str(tiles_dir), recursive=False)
    
    # Start watching
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Stopping auto-export service...")
        observer.stop()
    
    observer.join()
    print("✅ Auto-export service stopped")

if __name__ == "__main__":
    main()


