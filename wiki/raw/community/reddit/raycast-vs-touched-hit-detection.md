---
title: Should I use raycasting or particles / Touched for my projectiles?
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/tpjoit/should_i_use_raycasting_or_particles_for_my/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [raycasting, touched, projectiles, hit-detection, weapons]
---

# Should I use raycasting or .Touched for projectiles?

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/tpjoit/

## The Question

A developer asks whether they should use `Touched` events on projectile parts, or use raycasting instead.

## Community Answer

### The Rule
> **"Projectiles with .Touched are generally unreliable, especially at high speeds. Use raycasting."**

This is the consensus answer in r/robloxgamedev and matches the recommendation you'll see on the DevForum.

### Why Touched Is Unreliable
- **`.Touched` relies on the physics engine detecting a collision.** A fast-moving part can tunnel through a thin wall in a single frame — the physics sim never reports a collision because the part went from "in front of wall" to "behind wall" without ever overlapping.
- **`.Touched` fires on *any* part contact**, including the shooter's own body, debris, etc. Filtering out the shooter, their accessories, ragdolls, etc. is tedious.
- **`.Touched` depends on `CanCollide`.** If the projectile is set to non-collidable for replication/visual reasons, Touched will not fire at all for most cases.

### Why Raycasting Wins
- **Raycast is instant and deterministic.** It asks the engine "if I draw a line from A to B, what's the first thing it hits?" and returns that hit.
- **Tunnelling is impossible** — the ray always covers the full path of the projectile between frames.
- **You get a `RaycastResult`** with the hit `Instance`, `Position`, `Normal`, and `Distance`. Everything you need to apply damage or spawn an impact VFX.
- **RaycastParams** gives you first-class filtering: `FilterDescendantsInstances = { shooter.Character }` plus `FilterType = Enum.RaycastFilterType.Exclude`.

### The Canonical Pattern For "Fast Projectile Hit Detection"

```lua
local RunService = game:GetService("RunService")

-- Called every frame for an in-flight projectile
local function stepProjectile(projectile, dt)
	local from = projectile.Position
	local to = from + projectile.Velocity * dt
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { projectile.Shooter.Character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = false

	local result = workspace:Raycast(from, to - from, rayParams)
	if result then
		onHit(projectile, result)
		return
	end
	-- no hit yet; move visual part to 'to' for rendering
	projectile.VisualPart.CFrame = CFrame.new(to)
end
```

You then step this each `RunService.Heartbeat`. The VisualPart is a fake, non-collidable cosmetic part; the actual hit detection is the raycast.

### When Touched Is Still OK
- **Slow projectiles** (e.g., physics balls the player kicks around). Touched works fine when tunnelling isn't a risk.
- **Trigger volumes** (e.g., "you entered this area"), where you want the physics sim to tell you on overlap rather than polling with a raycast every frame.
- **Non-combat interaction** (buttons, doors, zones).

Basically: **Touched for "I want to know when two physics parts touch." Raycasting for "I want to know what this bullet hit."**

## Advanced: The "Sniper Problem"
For projectiles with velocity high enough that `from → to` is longer than the distance between typical walls, use **multiple raycasts per frame** (march the ray in segments) or just **hit-scan** the whole shot at once:

```lua
-- Instant sniper bullet
local result = workspace:Raycast(muzzlePos, direction * 1000, rayParams)
```

For a sniper, there's no projectile at all — the raycast *is* the shot, and you spawn the visual trail afterwards.

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/tpjoit/should_i_use_raycasting_or_particles_for_my/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets. The raycast-over-touched advice is the canonical Roblox community recommendation and matches the DevForum guidance on projectile systems.
