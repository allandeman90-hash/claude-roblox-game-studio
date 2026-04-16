---
title: "FastCast - Ranged Weapon Projectile Module"
author: EtiTheSpirit
source: https://devforum.roblox.com/t/making-a-combat-game-with-ranged-weapons-fastcast-may-be-the-module-for-you/133474
api_docs: https://etithespir.it/FastCastAPIDocs/
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [fastcast, projectile, bullet-physics, raycast, combat]
---

# FastCast - Ranged Weapon Projectile Module

FastCast uses segmented raycasting to simulate projectile physics with lag compensation.

## How It Works

Divides projectile path into small segments per Heartbeat frame:
- RayLength = NormalizedDirection * Velocity * DeltaTime * 2
- Each segment fires individually during successive Heartbeat events
- Latency causes frame delays -> ray length auto-extends to maintain consistent travel

## Core API

### Caster Setup
```lua
local caster = FastCastModule.new()
caster.Gravity = 0 -- default, set for drop
caster.ExtraForce = Vector3.new() -- wind effects
```

### Firing
```lua
caster:Fire(MuzzlePosition, DirectionVector * MaxDistance, BulletSpeed)
```

### Key Events

1. **LengthChanged** - fires each heartbeat with: origin, segment start, direction, segment length
   - Use for updating visual tracers
2. **RayHit** - triggers on collision: hit part, impact position, surface normal, material
   - Returns nil values if max distance reached without hit
3. **CastTerminating** - fires when a cast ends

## Physics Features

- Gravity: parabolic trajectories (arrows, grenades)
- ExtraForce: wind and environmental forces
- Lag compensation: auto-adjusts segment length per actual frame time

## Limitations

- Cannot fully prevent tunneling through fast-moving objects approaching projectile
- Slower projectiles experience minimal tunneling issues

## Related

- FastCast2: improved version with parallel scripting, static typing
- BulletCaster: lightweight physics-based alternative
