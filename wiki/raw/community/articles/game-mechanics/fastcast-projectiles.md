# FastCast & FastCast2 — Projectile Systems

**Sources:**
- https://devforum.roblox.com/t/making-a-combat-game-with-ranged-weapons-fastcast-may-be-the-module-for-you/133474
- https://devforum.roblox.com/t/fastcast2-an-improved-version-of-fastcast-with-parallel-scripting-more-extensions-and-statically-typed/4093890
**Captured:** 2026-04-15

## FastCast Overview

Module that uses segmented raycasting to simulate bullet physics. Splits the line from start to goal into tiny pieces based on velocity and distance. Each segment fires sequentially using RunService's Heartbeat event.

### Lag Compensation

Ray length calculation: `RayLength = NormalizedDirection * Velocity * DeltaTime * 2`
When lag occurs, the ray lengthens proportionally.

### Physics

- Gravity property (default: 0) enables curved trajectories: `Caster.Gravity = workspace.Gravity`
- ExtraForce Vector3 simulates wind/environmental forces

### Events

- `LengthChanged` - Fires each heartbeat, useful for tracer visualization
- `RayHit` - Triggers on collision, returns hit part, impact position, surface normal, material

## FastCast2 Improvements

- Parallel Luau support via ConnectParallel (multi-threaded workers, up to 4)
- Static typing (Luau strict mode)
- Built-in ObjectCache for object pooling
- Built-in velocity, gravity, realistic projectile motion
- Physics-driven projectiles that reflect off surfaces using surface normals
- Benchmark: 20000+ projectiles at 35 FPS on server

## SecureCast — Server-Authoritative Alternative

**Source:** https://devforum.roblox.com/t/archived-securecast-server-authoritative-projectiles-with-lag-compensation-multi-threading-and-more/2546164

### Architecture

- Synced server-client simulation with lag compensation
- GetServerTimeNow() accounts for one-way trip latency; interpolation buffer is separate (80-100ms)
- Hit detection runs entirely in Lua (no visual hitbox parts)

### Hit Detection Algorithm (3-stage)

1. Fast Voxel Traversal (~1 microsecond per traversal) - 3D grid to identify potentially intersecting players
2. Axis-Aligned Bounding Box (AABB) - Quickly eliminates impossible intersections
3. Oriented Bounding Box (OBB) - Precise intersection only on viable candidates

### Performance

- 630 projectiles intersecting 50 characters over 9 cores at 60 FPS
- ~410 microseconds checking 100 players

### Features

- Bullet drop, gravity, grenade bouncing, ricochets, wall penetration, collateral damage
- MIT licensed, available via Wally
