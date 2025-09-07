# Game Options Defaults

This document defines the default values for all configurable player options.  
It serves as the single source of truth for both developers and designers.

---

## Visual

- **Screen Shake**: `0.5`  
  Range: 0.0 (off) → 1.0 (maximum)  
  Default: **0.5** (moderate)  

- **Damage Flash**: `true`  
  Boolean toggle (on/off).  
  Default: **true** (enabled).  

---

## Controls

- **Aim Assist Strength**: `0.25`  
  Range: 0.0 (off) → 1.0 (maximum)  
  Default: **0.25** (mild aim assist).  

---

## Gameplay

- **Difficulty Preset**: `"normal"`  
  Options: `"easy"`, `"normal"`, `"hard"`  
  Default: **normal**.  

---

## Notes
- All options will be stored in `/config/options.json`.  
- Cursor will wire the game UI to these defaults.  
- If a new option is added in the future, update this file first.
