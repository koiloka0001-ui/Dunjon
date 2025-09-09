# Tiled Workflow Guide

## The Problem You're Seeing

The JSON files in `game-godot/data/rooms/` appear as "notepad files" because they are **export files**, not **project files**. Here's the difference:

- **TMX files** (`.tmx`) = Tiled project files (what you edit in Tiled)
- **JSON files** (`.json`) = Export files (what Godot loads)

## Proper Workflow

### 1. **Work with TMX Files**
- Open `tiles/A1.tmx` in Tiled (not the JSON files)
- This is where you design your rooms
- TMX files have the Tiled icon and open in Tiled editor

### 2. **Export to JSON**
- In Tiled: File → Export As → JSON
- Save to `game-godot/data/rooms/`
- This creates the JSON files that Godot loads

### 3. **Automated Conversion**
Use the workflow script to convert all TMX files to JSON:

```bash
python tiled_workflow.py convert
```

## File Structure

```
tiles/
├── dunjon_tileset.tsx          # Tileset definition
├── dunjon_tileset.png          # Tileset image
├── A1.tmx                      # Tiled project file (EDIT THIS)
├── A2.tmx                      # Tiled project file (EDIT THIS)
└── ...

game-godot/data/rooms/
├── A1.json                     # Export file (GODOT LOADS THIS)
├── A2.json                     # Export file (GODOT LOADS THIS)
└── ...
```

## Step-by-Step Instructions

### Creating a New Room

1. **Open Tiled**
2. **Open** `tiles/A1.tmx` (or create a new one)
3. **Design your room** using the 32x32 tileset
4. **Save as** `tiles/A2.tmx` (for room A2)
5. **Export as JSON** to `game-godot/data/rooms/A2.json`
6. **Test in Godot** - the room should load correctly

### Editing an Existing Room

1. **Open Tiled**
2. **Open** the corresponding `.tmx` file in `tiles/`
3. **Make your changes**
4. **Save** the TMX file
5. **Export as JSON** to update the corresponding `.json` file
6. **Test in Godot**

### Batch Conversion

If you have multiple TMX files to convert:

```bash
python tiled_workflow.py convert
```

This will convert all `.tmx` files in `tiles/` to `.json` files in `game-godot/data/rooms/`.

## Why This Setup?

- **TMX files** are the "source of truth" - your actual room designs
- **JSON files** are optimized for Godot - faster loading, smaller size
- **Separation** allows you to work in Tiled while Godot loads the optimized format
- **Version control** - you can track both the source (TMX) and the export (JSON)

## File Associations

To make TMX files open in Tiled by default:

1. **Right-click** on a `.tmx` file
2. **Open with** → **Choose another app**
3. **Select Tiled** from the list
4. **Check "Always use this app"**

## Troubleshooting

### TMX files show as "notepad files"
- Install Tiled Map Editor
- Associate `.tmx` files with Tiled

### JSON files show as "notepad files"
- This is normal! JSON files are meant to be loaded by Godot
- Don't edit JSON files directly - edit the TMX files instead

### Changes don't appear in Godot
- Make sure you exported the TMX file to JSON
- Check that the JSON file is in `game-godot/data/rooms/`
- Verify the file name matches what Godot expects

## Quick Reference

| Action | File Type | Location | Tool |
|--------|-----------|----------|------|
| **Edit rooms** | `.tmx` | `tiles/` | Tiled |
| **Load in Godot** | `.json` | `game-godot/data/rooms/` | Godot |
| **Convert** | Both | Both | `tiled_workflow.py` |

The key is: **Edit TMX, Load JSON!**

