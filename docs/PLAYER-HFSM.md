# Player HFSM

## Top Level States
- **Alive**
  - Idle
  - Move
  - Attack
  - Dash
  - Damaged
- **Dead**

## Transitions
- Idle → Move (on input vector != 0)
- Move → Idle (on input vector == 0)
- Any (Alive.*) → Dash (on Events.PLAYER_DASH)
- Attack → Idle (on animation finished)
- Damaged → Idle/Move (after invuln timer)
- Alive → Dead (on HP <= 0)
