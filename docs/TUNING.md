# Tuning Variables

These values are adjustable via the Debug/Tuning HUD (`~` hotkey).  
Changes persist in `config/tuning.json`.

---

## Player

- **player_speed**: 200 (movement speed in px/sec)  
- **dash_distance**: 150 (distance in px per dash)  
- **dash_cooldown**: 0.5 (seconds between dashes)  
- **stamina_regen**: 1.0 (stamina per second)

---

## Enemy

- **enemy_speed**: 100 (movement speed of basic enemy)  
- **enemy_attack_cooldown**: 1.0 (seconds between enemy attacks)  
- **enemy_damage**: 1 (damage per hit)

---

## Combat

- **attack_cooldown**: 0.3 (seconds between player attacks)  
- **ammo_max**: 6 (maximum bullets before reload)  
- **reload_time**: 1.2 (seconds to reload)

---

## Notes

- All values are stored in `/config/tuning.json`.  
- Presets are saved under `/tools/presets/`.  
- Cursor must bind Debug HUD sliders to these variables.

