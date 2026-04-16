# Character Controller Library — Full Release

**Source:** https://devforum.roblox.com/t/full-release-the-future-of-character-movement-character-controller-library/4565267
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Official Roblox release moving character movement from hardcoded Humanoid engine into transparent Luau-based system. Comprises AvatarAbilities Library + ControllerManager.

## Performance

Varies from same as Humanoid to 2x faster depending on circumstances. Measured across server and client.

## Standard Abilities

Six abilities matching legacy functionality: Walk, Run, Jump, Swim, Climb, Sit.

### New Physics Enhancements

- **Momentum Conservation**: Characters maintain linear/angular momentum when airborne. No sliding off moving platforms.
- **Friction-Based Movement**: Ground interaction respects material properties (ice slides, rubber grips).
- **Control Standardization**: Shift-Lock disabled by default; Strafe ability replacement planned.

## Configuration

- `TurnSpeedFactor` / `RollSpeedFactor` for turn speed
- `AirController.MoveMaxForce` for air control
- Balance properties for knockdown difficulty

## Migration

- Existing: Avatar Settings → Movement → select Character Controller Library
- New: Classic Obby template defaults to it; others require opt-in
- Rollback: disable momentum, set FrictionWeight=100/Friction=2, re-enable Shift-Lock

## Known Limitations

- Steep slope climbing less reliable than legacy
- Wall-sticking when holding inputs during jumps
- Ladder-to-platform clipping
- Truss climbing jitter from alternating normals
- `Humanoid:MoveTo()` not yet supported
- Single-Collider incompatible with swimming

## Upcoming

- Rules & Sensors API
- Crouch, Strafe, Sprint abilities
- Object Interaction (Reach, Hold)
- Custom Ability API (input, environmental, interaction)
- NPC support
- Server Authority compatibility
