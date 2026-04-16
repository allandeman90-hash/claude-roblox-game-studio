---
title: Official Roblox - Performance Improvement Recommendations
type: raw-source
source_url: https://create.roblox.com/docs/performance-optimization/improve
source_type: official-docs
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: patterns
tags: [official-docs, memory, physics, rendering, network, streaming]
---

# Official Roblox - Performance Improvement Recommendations

## Script Computation

### Key Principle
"Luau code runs synchronously and blocks the main thread until it encounters a function that yields the thread."

### Critical Issues
- Complex table operations (serialization, deserialization, deep cloning) on large structures
- Tying expensive operations to high-frequency RunService events without throttling

### Solutions
- Invoke code on RunService events sparingly; use alternative events for non-essential operations
- Break up large tasks using `task.wait()` across multiple frames
- Enable native code generation for computationally intensive server-side scripts
- Use multithreading for expensive tasks not requiring data model access

### MicroProfiler Scopes
Monitor `RunService.PreRender`, `RunService.PreSimulation`, `RunService.PostSimulation`, `RunService.Heartbeat`.

Use `debug.profilebegin()` and `debug.profileend()` for custom scopes.

## Script Memory Usage

### Critical Memory Metrics
- **LuaHeap**: High or growing values indicate memory leaks
- **InstanceCount**: Consistently growing numbers suggest ungarbage-collected instances
- **PlaceScriptMemory**: Per-script breakdown

### Major Memory Leak Sources
1. **Active event connections**: Remain uncollected even after firing; instances referenced in callbacks never garbage collect
2. **Player objects persist** after users leave - connections to `Player` and `CharacterAdded` events consume memory indefinitely
3. **Table accumulation**: Objects inserted into tables without removal cause continuous memory growth

### Example Leak
```lua
local playerInfo = {}
Players.PlayerAdded:Connect(function(player)
    playerInfo[player] = {} -- grows indefinitely
end)
```

### Mitigations
- Manually disconnect connections via `:Disconnect()`
- Destroy instances via `:Destroy()`
- Enable `Workspace.PlayerCharacterDestroyBehavior` for automatic cleanup
- Cleanup on PlayerRemoving:
```lua
Players.PlayerRemoving:Connect(function(player)
    task.defer(player.Destroy, player)
end)
```

## Physics Computation

### Common Drains
- Physics stepping at **240 Hz (fixed mode) = four times per frame overhead**
- Excessive physics-simulated objects with unnecessary constraints
- Overly precise collision detection on mesh parts

### Mitigations
- Use **adaptive physics stepping**
- Anchor static parts
- Minimize physics constraints/joints
- Reduce self-collision

### Collision Fidelity Strategy
| Fidelity | Use Case |
|----------|----------|
| **Box** | Small or non-interactable objects |
| **Hull** | Small-medium objects by shape |
| **Precise** | Avoid; most memory-intensive |
| **Default** | Avoid when possible |

### MicroProfiler Scopes
- `physicsStepped` (overall)
- `worldStep` (discrete physics steps)

## Physics Memory

"Default and precise collision detection modes consume significantly more memory than the two other modes."

### Reduction
- Set `CanCollide`, `CanTouch`, `CanQuery` to `false` for non-collision parts
- Default to `Box` fidelity for small anchored parts
- Build collision meshes from smaller box-fidelity objects

## Humanoids

### Costs
- All `HumanoidStateType`s enabled by default; disable unused states (e.g., `Climbing` for non-climbing NPCs)
- Frequent instantiation/respawning with layered clothing
- Server-side NPC animation replication
- Size/scale changes trigger FastCluster rebuilds

### Optimizations
1. **Client-side animation**: Create `Animator` on client for large NPC counts
2. **Alternatives**:
   - Static NPCs: `AnimationController` only
   - Moving NPCs: Custom controller + `AnimationController`
3. **Model pooling**
4. **Spatial spawning**: Only within user range
5. Use `Motor6D.Transform` instead of `JointInstance.C0`/`C1`

### MicroProfiler Scopes
- `stepHumanoid`
- `stepAnimation`
- `updateInvalidatedFastClusters` (**watch for 4+ ms = excessive avatar modifications**)

## Rendering

### Draw Call Instancing
Engine collapses identical meshes into single draw calls when:
- `SurfaceAppearances` match (if present)
- `TextureContents` match (otherwise)
- Materials match (when neither SurfaceAppearance nor TextureID)

### Common Issues
- High object density
- Missed instancing from duplicate meshes with different asset IDs
- Partial transparency layered (overdraw)
- Skinned MeshParts moving without Humanoid trigger FastCluster rebuilds

### Instancing Failure Example
```
LargeRock, rbxassetid://106420009602747 (x144) -- reused: good
LargeRock, rbxassetid://120109824668127        -- different ID: separate draw call
```

### Mitigations
- Import assets individually, duplicate post-import rather than importing whole maps
- Use `Packages` for reuse
- Room/portal culling systems for indoor environments
- `RenderFidelity` = `Automatic` or `Performance`
- Disable `BasePart.CastShadow` on small/distant parts
- Disable `Light.Shadows` where unnecessary
- Embed Humanoid in moving skinned MeshPart models to prevent spatial clustering rebuilds

### MicroProfiler Scopes
- `Prepare and Perform` (overall rendering)
- `computeLightingPerform` (light/shadow updates)
- `ShadowMapSystem`
- `RenderView` (post-processing)

## Networking & Replication

### Overhead Sources
- Excessive `RemoteEvent`/`RemoteFunction` traffic
- Replicating unchanged frame-by-frame data
- Throttle-less user input replication
- Over-sending data (entire inventory vs. single purchase details)
- Complex instance hierarchies created/destroyed at runtime
- Server-side `TweenService` replicating tweened properties every frame (causes jitter + unnecessary traffic)
- Animation Editor metadata in published rigs

### Reductions
- Send only necessary data at lower frequency
- Chunk complex instance trees (maps) across multiple frames
- Clean up animation metadata from rigs before publishing
- Move client-side: visual effects, first-person item views, tweens
- Server: only replicate outcome locations for effects (explosion/spell effects)

### MicroProfiler Scopes
- `ProcessPackets` (incoming network processing)
- `Allocate Bandwidth and Run Senders` (outgoing server events)

## Asset Memory

### Highest-Impact Strategy
**Enable instance streaming** for large 3D worlds.

### Streaming Configuration
- Reduce `Enum.ModelStreamingMode.Persistent` usage
- Lower `Workspace.StreamingMinRadius` and `Workspace.StreamingTargetRadius`

### Texture Rule
**"A 1024x1024 pixel texture consumes four times the graphics memory of a 512x512 texture."**

### Texture Strategy
- Engine auto-downsamples based on device memory, distance, screen coverage
- Max 512 x 512 for most assets
- Max 256 x 256 for minor images
- Use `SurfaceAppearance.Color` for tinting instead of multiple textures
- Use trim sheets for maximum texture reuse in 3D maps
- Upload assets once; reuse same ID

## Load Times

### Anti-pattern
Using `ContentProvider:PreloadAsync()` on entire `Workspace` or relying on `RequestQueueSize` for completion.

### Legitimate Preload Cases
- Loading screen images
- Game menu assets (button backgrounds, icons)
- Starting/spawning area assets

### Best Practice
Provide **Skip Loading** button; avoid preloading unnecessary content.

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Fixed physics rate | 240 Hz (4x per frame at 60 FPS) |
| Texture 1024 vs 512 | 4x memory |
| FastCluster watch threshold | 4+ ms |
| Recommended texture max | 512 x 512 |
| Minor image max | 256 x 256 |

## Source

Original URL: https://create.roblox.com/docs/performance-optimization/improve
Captured: 2026-04-16
