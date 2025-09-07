# Colorblind Accessibility Mapping

This document defines how critical in-game colors should be adapted for players with different types of color vision deficiency.

---

## Key Game Colors

- Enemy highlight: Red (#FF0000)
- Ally highlight: Blue (#00AFFF)
- Interactive object: Green (#00FF00)
- Important UI warning: Yellow (#FFD700)

---

## Mapping Guidelines

### Protanopia (red-blind)
- Replace enemy red with Magenta (#FF00FF) or Bright Orange (#FF8000).
- Keep allies and UI unchanged.

### Deuteranopia (green-blind)
- Replace green objects with Cyan (#00FFFF).
- Use more distinct shapes/icons for confirmation cues.

### Tritanopia (blue-blind)
- Replace ally blue with Purple (#8000FF).
- Shift UI yellow to Pink (#FF66B2) for alerts.

---

## Implementation Notes
- Add pattern/shape cues alongside color (e.g., striped outlines for enemies).
- Accessibility toggle in Options Menu (future feature) should allow switching palettes.
- All changes should be tested in simulated colorblind filters before implementation.
