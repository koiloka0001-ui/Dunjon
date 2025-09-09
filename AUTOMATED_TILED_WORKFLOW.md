# Automated Tiled Workflow

## The Problem Solved

You wanted TMX files to automatically become JSON files when saved. Now they do! 🎉

## How It Works

### Option 1: Auto-Export Service (Recommended)
1. **Start the service**: Double-click `start_auto_export.bat`
2. **Edit in Tiled**: Open any `.tmx` file in Tiled
3. **Save**: Press Ctrl+S in Tiled
4. **Automatic conversion**: The service detects the save and converts to JSON
5. **Godot loads**: The JSON file is ready for Godot

### Option 2: Manual Export (Fallback)
If the auto-export service isn't running:
1. **Edit in Tiled**: Open any `.tmx` file
2. **Export manually**: File → Export As → JSON
3. **Save to**: `game-godot/data/rooms/`

## Quick Start

### 1. Start Auto-Export Service
```bash
# Double-click this file:
start_auto_export.bat

# Or run directly:
python auto_export_tiles.py
```

### 2. Edit Your Rooms
- Open `tiles/A1.tmx` in Tiled
- Make your changes
- **Save** (Ctrl+S)
- **That's it!** The JSON file updates automatically

### 3. Test in Godot
- The JSON file is automatically updated
- Godot will load the new room data
- No manual conversion needed!

## What Happens Automatically

1. **You save** `A1.tmx` in Tiled
2. **Service detects** the file change
3. **Converts** TMX to JSON format
4. **Saves** to `game-godot/data/rooms/A1.json`
5. **Godot loads** the updated room

## File Structure

```
tiles/
├── A1.tmx          ← Edit this in Tiled
├── A2.tmx          ← Edit this in Tiled
├── dunjon_tileset.tsx
└── export_settings.json

game-godot/data/rooms/
├── A1.json         ← Auto-generated from A1.tmx
├── A2.json         ← Auto-generated from A2.tmx
└── ...

auto_export_tiles.py    ← Auto-export service
start_auto_export.bat   ← Start service (double-click)
```

## Service Features

- **Real-time monitoring** of the `tiles/` directory
- **Automatic conversion** when TMX files are saved
- **Error handling** with detailed logging
- **Duplicate prevention** (won't convert the same file multiple times)
- **Background operation** (runs while you work)

## Troubleshooting

### Service won't start
- Make sure Python is installed
- Run `pip install watchdog` to install dependencies
- Check that `tiles/` and `game-godot/data/rooms/` directories exist

### Files not converting
- Check that the service is running
- Look for error messages in the console
- Try saving the TMX file again

### Godot not loading changes
- Make sure the JSON file was updated (check timestamp)
- Restart Godot if needed
- Check the console for error messages

## Advanced Usage

### Custom Export Settings
Edit `tiles/export_settings.json` to customize export options:

```json
{
  "exportSettings": [
    {
      "name": "Godot JSON Export",
      "fileExtension": "json",
      "exportFormat": "json",
      "exportPath": "../game-godot/data/rooms/",
      "exportOptions": {
        "encoding": "csv",
        "compression": "none",
        "includeTileset": false
      }
    }
  ]
}
```

### Multiple Export Formats
You can set up multiple export formats in Tiled:
1. **File → Export As**
2. **Choose format** (JSON, TMX, etc.)
3. **Set path** to `game-godot/data/rooms/`
4. **Save as preset** for future use

## Benefits

✅ **No manual conversion** - just save in Tiled  
✅ **Real-time updates** - changes appear immediately  
✅ **Error prevention** - automatic validation  
✅ **Background operation** - doesn't interrupt your workflow  
✅ **Multiple file support** - converts all TMX files  
✅ **Easy to use** - just double-click to start  

## Summary

**Before**: Edit TMX → Manually export → Godot loads  
**After**: Edit TMX → Save → Godot loads (automatic!)

The workflow is now completely automated! Just start the service and work in Tiled as normal. 🚀


