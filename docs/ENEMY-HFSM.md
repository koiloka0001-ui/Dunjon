# Enemy HFSM

## Top Level States
- **Alive**
  - Idle
  - Patrol
  - Chase
  - Attack
  - Damaged
- **Dead**

## Transitions
- Idle → Patrol (on spawn init)
- Patrol → Chase (on player detected)
- Chase → Attack (on within attack range)
- Attack → Chase (on attack finished if player still near)
- Attack → Patrol (on player lost)
- Any (Alive.*) → Damaged (on Events.PLAYER_HIT)
- Alive → Dead (on HP <= 0 → Events.ENEMY_KILLED)
