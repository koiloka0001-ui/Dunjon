# Tiled Setup Guide for Dunjon

This guide explains how to set up Tiled Map Editor to work properly with the Dunjon Godot project.

## Project Configuration

### Tile Size
- **Godot expects**: 32x32 pixel tiles
- **Tiled should use**: 32x32 pixel tiles
- **Previous issue**: Room data was using 16x16 tiles, causing mismatches

### Viewport Settings
- **Resolution**: 1920x1080
- **Tile size**: 32x32 pixels
- **Room size**: 20x15 tiles (640x480 pixels)

## Tileset Configuration

### File Structure
```
tiles/
├── dunjon_tileset.tsx          # Tiled tileset definition
├── dunjon_tileset.png          # 96x32 pixel image (3 tiles)
├── ground_tile.png             # Individual ground tile
├── wall_tile.png               # Individual wall tile
└── create_dunjon_tileset.py    # Script to generate tileset
```

### Tile Mapping
- **Tile 0**: Empty/transparent (for collision layer empty spaces)
- **Tile 1**: Ground texture (dirt_floor.png)
- **Tile 2**: Wall texture (dungeon_wall.png) with collision

## Room Structure

### Required Layers
1. **Ground** - Walkable floor tiles (tile ID 1)
2. **Collision** - Wall tiles (tile ID 2) and empty spaces (tile ID 0)
3. **Entities** - Object layer for spawn points
4. **Metadata** - Object layer for room ID and doors

### Object Properties
- **player_spawn**: `type="player_spawn"`
- **room_id**: `room_id="A1"` (or appropriate room ID)
- **doors**: `type="door"`, `dir="north|south|east|west"`

## Tiled Project Setup

1. **Open Tiled** and create a new map:
   - Orientation: Orthogonal
   - Tile size: 32x32 pixels
   - Map size: 20x15 tiles

2. **Add the tileset**:
   - File → Add External Tileset
   - Select `tiles/dunjon_tileset.tsx`

3. **Create layers** in this order:
   - Ground (tile layer)
   - Collision (tile layer)
   - Entities (object layer)
   - Metadata (object layer)

4. **Set up objects**:
   - Use 32x32 pixel objects (matching tile size)
   - Add proper properties as defined above

## Export Settings

When exporting from Tiled:
- **Format**: JSON
- **Encoding**: CSV
- **Compression**: None
- **Include tileset**: External tileset file

## Integration with Godot

The exported JSON files should be placed in:
```
game-godot/data/rooms/
```

Godot will automatically:
- Load the room data
- Apply the correct tile textures
- Set up collision for wall tiles
- Position objects correctly

## Troubleshooting

### Common Issues
1. **"Corrupt layer data"**: Usually caused by tile size mismatches
2. **Missing textures**: Ensure tileset path is correct
3. **Wrong scaling**: Make sure tile size is 32x32 in both Tiled and Godot

### Verification
- Check that tile IDs match between Tiled and Godot
- Verify object properties are correctly set
- Ensure tileset image dimensions are correct (96x32 for 3 tiles)

