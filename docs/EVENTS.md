# Events Registry

This document lists all broadcasted game events. Each event is a string constant in utoload/Events.gd.

## Player
- PLAYER_DASH — triggered when player dashes.
- PLAYER_DAMAGED — triggered when player takes damage.
- ATTACK_HIT — triggered when a player attack lands.

## Enemy
- ENEMY_SPAWNED — triggered when an enemy is spawned.
- ENEMY_KILLED — triggered when an enemy dies.

## Rooms
- ROOM_CLEARED — triggered when all enemies in a room are defeated.

## Notes
- Events are **fire-and-forget**: any system may listen.
- Events are the glue between state machines, combat logic, and room progression.
