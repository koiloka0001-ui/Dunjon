@"
# Tiled Contract

This document defines the required tilemap/layer structure for Dunjon.   

## Layers
- **Ground** → Walkable floor. No collisions.  
- **Walls** → Solid collision layer. Must block player & enemies.  
- **Props** → Decorative only, no gameplay effect.  
- **SpawnPoints** → Objects layer. Each object must have:
  - `type`: "player" | "enemy"
  - `id`: unique string
- **Triggers** → Rectangular objects with:
  - `event`: string (must match Events.gd const)
- **Doors** → Objects with properties:
  - `direction`: "north" | "south" | "east" | "west"
  - `locked`: boolean
"@ | Out-File -FilePath docs/TILED-CONTRACT.md -Encoding utf8
