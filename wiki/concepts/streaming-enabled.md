---
title: streaming-enabled
type: concept
category: concepts
subcategory: performance
owner: level-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/network/streaming-enabled-guide.md
related:
  - "[[Workspace]]"
  - "[[level-design]]"
  - "[[module-lazy-loading]]"
tags: [concept, performance, streaming, replication]
---

# StreamingEnabled

> Dynamic loading and unloading of Workspace instances based on player distance; enabled by default since July 2023.

## What It Is

`workspace.StreamingEnabled = true` makes the Roblox engine stream Models in and out of each client based on distance from the player's character. Nearby content loads at high priority; distant content unloads to reclaim memory. This enables much larger worlds, reduces join time, lowers memory footprint, and improves frame rate -- especially on mobile devices.

Streaming is **enabled by default** for all new places created in Studio since July 2023.

## When to Use It

- **Large open worlds.** Any map where the total content budget exceeds what a low-end mobile device can hold in memory (~3.5 GB).
- **Mobile-targeted games.** Streaming dramatically reduces memory usage.
- **Games with distinct zones.** A city map where distant neighborhoods do not need to be loaded.

When to disable:
- **Very small maps** where the entire world fits in memory comfortably.
- **Games that rely on accessing all workspace children from LocalScripts** without `WaitForChild` patterns.

## Implementation

### Key Properties

| Property | Default | Description |
|----------|---------|-------------|
| `StreamingMinRadius` | **64 studs** | Minimum radius loaded at highest priority. Even low-end devices load this. |
| `StreamingTargetRadius` | **1024 studs** | Max radius capable devices will load. |
| `StreamOutBehavior` | `Default` | When to unload: `Default`, `Opportunistic`, `LowMemory`. |
| `StreamingIntegrityMode` | `Default` | Controls movement into unloaded areas: `Default`, `PauseOutsideLoadedArea`, `ImprovedRollback`. |
| `ModelStreamingBehavior` | `Legacy` | `Improved` mode sends models only when needed; faster joins. |

All properties are **server-side only**. LocalScripts cannot modify them.

### Per-Model Streaming Mode

Individual models control their streaming behavior via `Model.StreamingMode`:

| Mode | Behavior |
|------|----------|
| `Default` | Currently equals Nonatomic; may change in future. |
| `Nonatomic` | Model streams before descendants (legacy default). |
| `Atomic` | Model streams in/out as a unit -- all descendants load together. |
| `Persistent` | Always streamed. Never unloaded after `PersistentLoaded` fires. |
| `PersistentPerPlayer` | Always streamed for specified players via `Model:AddPersistentPlayer(Player)`. |

**Atomic mode** is important for characters and NPCs: the entire model arrives at once, eliminating the need for multiple `WaitForChild` calls on children. Avatars and NPCs stream out completely when far away rather than persisting partially.

**Persistent mode** should be used sparingly -- it circumvents streaming benefits. Reserve it for HUD anchors, critical game objects, and spawn points.

### Safe Scripting Patterns

With streaming enabled, instances may not exist on the client when referenced. Every client-side access to a Workspace child must account for this:

```lua
-- BEFORE streaming (unsafe):
local part = workspace.SomeModel.SomePart

-- WITH streaming (safe):
local model = workspace:WaitForChild("SomeModel")
local part = model:WaitForChild("SomePart", 10)  -- 10-second timeout
if not part then
    warn("SomePart did not stream in within timeout")
    return
end
```

### PersistentLoaded Event

```lua
local Workspace = game:GetService("Workspace")

Workspace.PersistentLoaded:Connect(function(player)
    -- All Persistent models are now loaded for this player
    -- Safe to initialize persistent content
end)
```

### Per-Player Persistent Streaming

```lua
-- Server: make a model always visible for a specific player
local vipArea = workspace.VIPArea
vipArea.StreamingMode = Enum.ModelStreamingMode.PersistentPerPlayer
vipArea:AddPersistentPlayer(player)

-- Later: remove when no longer needed
vipArea:RemovePersistentPlayer(player)
```

## Variants

### Mobile-Optimized Settings

```
StreamingMinRadius = 64
StreamingTargetRadius = 512  -- reduced from 1024
StreamOutBehavior = LowMemory
```

### Precision Gameplay (FPS, Racing)

```
StreamingMinRadius = 128  -- larger guaranteed radius
StreamingTargetRadius = 1024
StreamingIntegrityMode = PauseOutsideLoadedArea
```

`PauseOutsideLoadedArea` pauses the character until the area loads, preventing players from falling through un-streamed terrain.

## Pitfalls

- **Assuming instances exist.** The most common streaming bug. Any client-side code that indexes `workspace.SomePart` without `WaitForChild` will break when that part has not yet streamed in. Audit all client scripts for direct workspace access.
- **Over-using Persistent mode.** Every persistent model stays in memory for all players. Marking too many models as persistent defeats the purpose of streaming. Use it only for critical game objects.
- **Server-side is unaffected.** Streaming only affects client replication. Server scripts always see all workspace children -- no `WaitForChild` needed server-side.
- **Increasing StreamingMinRadius.** Higher values increase memory usage and network bandwidth for all players. Only increase if gameplay genuinely requires it (e.g., long-range sniping).
- **Animation and sound on unloaded models.** If a client cannot see a distant NPC, animations and sounds on that NPC do not play. Design ambient systems to handle missing models gracefully.

## Related

- [[Workspace]] -- the service that owns StreamingEnabled
- [[level-design]] -- world layout must account for streaming radii
- [[module-lazy-loading]] -- analogous concept for code: defer loading until needed

## Sources

- [wiki/raw/community/performance/network/streaming-enabled-guide.md](../raw/community/performance/network/streaming-enabled-guide.md)
- [Roblox docs: Instance streaming](https://create.roblox.com/docs/workspace/streaming)
