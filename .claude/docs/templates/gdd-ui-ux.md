# UI / UX System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: ux-designer + ui-programmer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

How the player interacts with the game through UI. This GDD defines the information architecture and the style system.

---

## 2. Menu Hierarchy

```
HUD (always visible)
├── Main Menu (1 tap to open)
│   ├── Inventory (2 taps from HUD)
│   ├── Shop (2 taps from HUD)
│   ├── Quests (2 taps from HUD)
│   ├── Map (2 taps from HUD)
│   └── Settings (2 taps from HUD)
├── Friends (side button)
├── Chat (side button)
└── Emotes (hotkey)

Modals (triggered contextually)
├── Purchase Confirmation
├── Level Up
├── Quest Complete
├── Achievement Earned
└── Daily Reward
```

Max depth: 3 taps from HUD to any feature.

---

## 3. Screen Inventory

### HUD (persistent)
Elements:
- Health bar
- XP bar
- Minimap
- Currency display
- Quest tracker (side)
- Combat indicators (hit numbers, cooldowns)
- Mobile controls (jump, action button)

### Main Menu
Top-level menu accessed via HUD button. Tabs for Inventory, Shop, Quests, Map, Settings.

### Inventory
- Grid of items
- Sort / filter options
- Equip / use / sell buttons
- Item tooltip on hover/tap

### Shop
- Item list with price, icon, description
- Buy button
- Category tabs (Weapons, Consumables, Cosmetics, Premium)

### Quests
- Active quest list
- Quest details
- Reward preview
- Abandon quest option

### Settings
- Audio volume (Music, SFX, UI, Voice)
- Graphics quality (for PC)
- Control remapping
- Accessibility options
- Language selection

---

## 4. Visual Style

- **Color Palette**: [Primary, Secondary, Accent, Neutral]
- **Font**: [Gotham / Ubuntu / custom via TextFontAsset]
- **Border Radius**: 8px
- **Shadow**: Subtle drop shadow for depth
- **Icon Style**: Flat, single-color with accent for emphasis

---

## 5. Responsive Design

### Target Devices
- Mobile portrait: 375×667 (iPhone SE)
- Mobile landscape: 844×390 (iPhone 12)
- Tablet: 1024×768 (iPad)
- Desktop: 1920×1080 (PC)
- Console: 1920×1080 (Xbox with gamepad)

### Scaling
- Base resolution: 1920×1080
- UIScale instance scales based on viewport
- Minimum scale: 0.5 (never goes smaller)
- Maximum scale: 1.5 (never goes larger than original)

---

## 6. Accessibility

- Contrast ratio ≥ 4.5:1
- Touch targets ≥ 44×44 px
- Text size ≥ 14pt
- Colorblind-safe icons (not color-only)
- Reduced motion option (disables bouncy tweens)
- Screen reader support (AccessibleName)

---

## 7. Input Handling

- **Touch**: Mobile primary input
- **Mouse + Keyboard**: PC
- **Gamepad**: Console (Xbox)
- **VR**: Future support

Use `ContextActionService` to bind actions to multiple input types simultaneously.

---

## 8. Animation & Feedback

- **Button press**: 100ms scale-down on press
- **Modal open**: 200ms slide-in from direction
- **Notification**: 300ms slide-in, 2s linger, 300ms fade-out
- **Loading**: Spinner during async operations

---

## 9. Localization

- All user-facing text goes through `Localization.get(key, params)`
- Strings stored in `src/ReplicatedStorage/Shared/Config/Localization/`
- Default: `en_US.lua`
- Additional: `es_ES.lua`, `pt_BR.lua`, etc.

---

## 10. Integration Points

### Depends On
- Remotes (to fetch server state, send actions)
- Player Data (to display current state)
- Localization (for text)

### Depended On By
- Every gameplay system (UI is the front-end)

---

## Acceptance Criteria

- [ ] Menu depth ≤ 3 from HUD
- [ ] Touch targets ≥ 44×44 px
- [ ] Contrast ≥ 4.5:1 across all text
- [ ] Tested on all target devices
- [ ] Accessible (screen reader compatible)
- [ ] Localization-ready
- [ ] No client-side state ownership
