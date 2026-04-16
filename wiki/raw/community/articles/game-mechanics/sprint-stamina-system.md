# Stamina/Sprinting System

**Source:** https://devforum.roblox.com/t/how-to-make-a-proper-staminasprinting-system/3001735
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Community resource addressing a common bug: stamina draining while the player holds shift but stands still.

## Sprint Activation

Left Shift → `running = true` → walk speed set to 150% of base → camera zoom adjusts.

## Stamina Drain (Corrected)

Drains only when `player.Character.Humanoid.MoveDirection` is not zero (player is actually moving). Original bug: stamina drained on shift-hold regardless of movement.

Rate: 1 per frame while sprinting + moving.

## Recovery

- Release Shift or stop moving → stamina regenerates at 0.5 per frame
- Regenerates until maximum capacity reached

## UI Integration

```lua
staminaBar:TweenSize(UDim2.new(1, 0, stamina / staminaMaximum, 0))
```

Animates bar proportional to current stamina.

## Limitation

Entire system runs client-side. No server validation included. Vulnerable to exploits in competitive gameplay.

---

# Free Sprint System (Updated)

**Source:** https://devforum.roblox.com/t/updated-free-sprint-system/1215024
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Features

- Camera FOV transitions via TweenService
- WalkSpeed transitions via TweenService
- Stamina bar GUI
- Stamina depletion during sprint, regen during idle with cooldown
- UserInputService for key detection
- Modular design, scripts in StarterPlayerScripts

## Asset ID

Available at: https://create.roblox.com/store/asset/12165031331/Free-Sprint-System
