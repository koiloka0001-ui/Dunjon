# Auto-generated from tools/events.json. Do not edit.

class_name Events

const PLAYER_DASH = "player_dash"
const ATTACK_HIT = "attack_hit"
const PLAYER_DAMAGED = "player_damaged"
const ENEMY_SPAWNED = "enemy_spawned"
const ENEMY_KILLED = "enemy_killed"
const ROOM_CLEARED = "room_cleared"

const PAYLOAD = {
	"player_dash": { "dir":"vec2", "ifr_ms":"int", "stamina_after":"int" },
	"attack_hit": { "attacker":"id", "target":"id", "dmg":"int" },
	"player_damaged": { "hp_after":"int", "source":"id" },
	"enemy_spawned": { "type":"str", "pos":"vec2" },
	"enemy_killed": { "type":"str", "pos":"vec2" },
	"room_cleared": { "id":"str", "time_ms":"int" }
}
