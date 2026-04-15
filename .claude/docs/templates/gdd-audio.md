# Audio System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: audio-director + sound-designer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

Audio identity, routing, and implementation standards for the game.

---

## 2. Audio Identity

- **Mood**: [calm / intense / mysterious / whimsical / etc.]
- **Genre references**: [e.g., "like Hollow Knight atmospheric" or "like Minecraft chill"]
- **Instrument palette**: [e.g., "synths + choir" or "acoustic guitar + ukulele"]

---

## 3. SoundGroup Hierarchy

```
SoundService
├── Master
│   ├── Music (volume 0.5)
│   ├── SFX (volume 0.8)
│   │   ├── Combat (volume 0.9)
│   │   └── Environment (volume 0.6)
│   ├── UI (volume 0.7)
│   ├── Voice (volume 1.0)
│   └── Ambient (volume 0.4)
```

All groups route to Master. Player controls volume via settings (applies to group volumes).

---

## 4. Music

- **Menu theme**: [description]
- **Hub/lobby**: [description]
- **Combat theme**: [description]
- **Boss theme**: [description]
- **Victory fanfare**: [description]

### Layering
For dynamic music, compose in stems:
1. Drums
2. Bassline
3. Main melody
4. Atmospheric pad
5. Tension layer

Fade stems in/out based on game state (combat intensity, boss fight, etc.).

---

## 5. SFX Categories

### Combat
- Weapon swing (per weapon type)
- Hit impact (per material)
- Critical hit sting
- Block / parry
- Death sounds

### UI
- Button click
- Menu open / close
- Notification chime
- Purchase success / fail
- Tab switch

### Environment
- Footsteps (per material)
- Water splash
- Wind ambience
- Creature ambiences

### Character
- Jump
- Land
- Hurt
- Emote-specific sounds

---

## 6. Spatial Audio

- **3D sounds**: Parented to Part or Attachment
- **RollOffMinDistance**: 10 studs (full volume within)
- **RollOffMaxDistance**: 100 studs (silent beyond)
- **RollOffMode**: InverseTapered (realistic falloff)

2D sounds (music, UI) are parented to `SoundService` or PlayerGui.

---

## 7. Performance

- **Simultaneous sound cap**: ~32 on mobile
- **Sound pooling**: Reuse Sound instances for frequent SFX (combat hits, footsteps)
- **Preloading**: Use `ContentProvider:PreloadAsync` on critical sounds
- **Cleanup**: Destroy one-shot sounds after they finish playing

---

## 8. Accessibility

- Volume sliders for each SoundGroup
- Mute all option
- Visual indicators paired with audio cues (hit flash, damage numbers)
- No critical info conveyed by sound alone

---

## 9. Roblox Audio Restrictions

- Only audio owned by the experience's creator account is usable
- Audio uploads subject to moderation (~1-24 hours)
- Custom audio must be uploaded via Creator Dashboard or Assets API
- For licensed music, use Roblox's built-in music library

---

## 10. Implementation Standards

- All sounds routed to a SoundGroup (never direct to Workspace/PlayerGui)
- All sound IDs referenced via a config table (no hardcoded IDs scattered)
- Sound IDs documented in `src/ReplicatedStorage/Shared/Config/SoundConfig.lua`

---

## Integration Points

### Depends On
- Asset upload pipeline (devops-engineer)
- Game events (gameplay system hooks for triggers)

### Depended On By
- Combat (triggers hit sounds)
- UI (button sounds)
- Gameplay events (level up sting, boss appears)

---

## Acceptance Criteria

- [ ] All SoundGroups configured
- [ ] All sounds routed (no rogue direct sounds)
- [ ] Volume sliders working
- [ ] Spatial audio functioning for 3D sources
- [ ] Sound pooling for high-frequency SFX
- [ ] Preloading on critical sounds
- [ ] Mobile CPU usage within budget
