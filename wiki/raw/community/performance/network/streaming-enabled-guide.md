---
title: StreamingEnabled and Instance Streaming
type: raw-source
source_url: https://create.roblox.com/docs/workspace/streaming
source_type: official-docs
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: network
tags: [streaming-enabled, streaming-mode, streaming-radius, replication]
---

# StreamingEnabled and Instance Streaming

## What is Instance Streaming

Instance streaming dynamically loads and unloads Models on a player's device as their character explores the 3D world. Streaming is **enabled by default for new places** created in Studio (since July 2023).

## Enabling

Set via Workspace property only (not scriptable):
- `Workspace.StreamingEnabled = true`

## Key Properties

### StreamingMinRadius
The minimum radius (in studs) around the character in which instances stream in at **highest priority**.
- Even low-end devices must load this radius
- **Default: 64 studs**
- Range: reasonable values 32-256

Increasing this requires more memory and server bandwidth.

### StreamingTargetRadius
Maximum radius that capable devices will load.
- **Default: 1024 studs**
- Higher = more memory used, better visual completeness
- Lower = less memory, more frequent loading events

### StreamOutBehavior
Controls when content streams OUT:
- `Default` - Engine decides
- `Opportunistic` - Streams out when memory pressure
- `LowMemory` - Aggressive streaming out when memory pressure

### StreamingIntegrityMode
Controls whether player movement is blocked when entering unstreamed areas:
- `Default` (since 2023)
- `PauseOutsideLoadedArea` - Character pauses until area loads
- `ImprovedRollback`
- Prevents players from falling through non-streamed content

### ModelStreamingBehavior
- `Legacy` - older behavior
- `Improved` - Models in Workspace only sent to clients when needed; speeds up join times

## Model.StreamingMode (Per-Model)

Since 2023, individual models can specify their streaming behavior:

| Mode | Behavior |
|------|----------|
| `Atomic` | Model streams in/out **as a unit** - all descendants load together |
| `Nonatomic` | Models stream before descendants (legacy default) |
| `Default` | Currently equals Nonatomic; may change in future |
| `Persistent` | **Always streamed** - never removed after PersistentLoaded fires |
| `PersistentPerPlayer` | Always streamed for specified players via `Model:AddPersistentPlayer()` |

### Functions
- `Model:AddPersistentPlayer(Player)`
- `Model:RemovePersistentPlayer(Player)`

### Event
- `Workspace.PersistentLoaded(Player)` fires when all persistent models load

## Benefits

1. **Faster join times** - less content replicated at spawn
2. **Reduced memory footprint** - distant content unloaded
3. **Increased frame rate** - less to simulate/render
4. **Better mobile support** - scales to device capability
5. **Larger worlds possible** - not limited by ~3.5 GB total content budget

## Performance Guidelines

### Default Recommendation
Keep default 64/1024 radii unless you have specific reason to change. Increase `StreamingMinRadius` if gameplay requires seeing farther at high priority.

### For Mobile-Heavy Games
Lower `StreamingTargetRadius` to 512 or 768 for reduced memory.

### For Precision Gameplay (FPS, racing)
Use `PauseOutsideLoadedArea` integrity mode to prevent falling through un-streamed terrain.

## Atomic Model Benefits

Avatars and NPCs stream out completely when far away rather than persisting partially. Eliminates multiple `WaitForChild` calls - developers need only one call when using atomic models.

## Caveats

- All properties/functions are **server-side only**; LocalScripts cannot modify
- `Persistent` mode should be used "in rare circumstances" since it circumvents streaming benefits
- Scripts must handle missing instances via `WaitForChild`

## Script Patterns

### Safe Access
```lua
-- Before streaming
local part = workspace.SomeModel.SomePart

-- With streaming
local model = workspace:WaitForChild("SomeModel")
local part = model:WaitForChild("SomePart", 10)  -- 10s timeout
```

### PersistentLoaded
```lua
local Workspace = game:GetService("Workspace")
Workspace.PersistentLoaded:Connect(function(player)
    -- safe to initialize persistent content for this player
end)
```

## Measurements / Numbers

| Setting | Default |
|---------|---------|
| StreamingMinRadius | 64 studs |
| StreamingTargetRadius | 1024 studs |
| Mobile-recommended TargetRadius | 512-768 studs |

## Source

Original URLs:
- https://create.roblox.com/docs/workspace/streaming
- https://devforum.roblox.com/t/new-improvements-to-streaming-enabled/2185535

Captured: 2026-04-16
