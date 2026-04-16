---
title: Draw Call Optimization
type: performance
category: performance
subcategory: rendering
owner: technical-artist
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/rendering/optimization-guide-draw-calls.md
  - wiki/raw/community/performance/rendering/mesh-lod-render-fidelity.md
  - wiki/raw/community/performance/rendering/transparency-overdraw.md
  - wiki/raw/community/performance/rendering/lighting-modes-performance.md
related:
  - "[[object-pooling]]"
  - "[[heartbeat-budget]]"
  - "[[texture-memory]]"
  - "[[physics-budget]]"
tags: [performance, rendering, draw-calls, lod, transparency]
---

# Draw Call Optimization

## Summary

Each unique mesh + material combination rendered in a frame is a draw call. Roblox games should target **< 500 draw calls per frame**. Exceeding this degrades frame rate, especially on mobile. The primary levers are mesh instancing (reuse mesh IDs), LOD via `RenderFidelity`, collision fidelity reduction, and minimizing transparency overdraw.

## Measurements / Budgets

| Budget | Value | Source |
|--------|-------|--------|
| **Scene draw calls target** | **< 500** | [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md) |
| Mesh LOD High -> Medium | **250 studs** | [mesh-lod-render-fidelity.md](../raw/community/performance/rendering/mesh-lod-render-fidelity.md) |
| Mesh LOD Medium -> Low | **500 studs** | [mesh-lod-render-fidelity.md](../raw/community/performance/rendering/mesh-lod-render-fidelity.md) |
| LOD Medium triangle reduction | **~50%** | [mesh-lod-render-fidelity.md](../raw/community/performance/rendering/mesh-lod-render-fidelity.md) |
| LOD Low triangle reduction | **~75% total** | [mesh-lod-render-fidelity.md](../raw/community/performance/rendering/mesh-lod-render-fidelity.md) |
| FastCluster alarm threshold | **4+ ms** | INDEX.md |
| Max texture upload size | **1024 x 1024** | [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md) |

### Transparency Rendering Cost

| Transparency | Render Cost | Recommendation |
|-------------|-------------|----------------|
| 0 (opaque) | Cheap (Z-buffer culls hidden pixels) | Preferred |
| 0.01-0.99 (semi) | Expensive (overdraw, no early Z-reject) | Minimize |
| 1 (fully invisible) | Free (not rendered) | Fine for collision-only parts |

10 overlapping semi-transparent decals cost approximately **10x** the fill-rate of 1 opaque part.

Source: [transparency-overdraw.md](../raw/community/performance/rendering/transparency-overdraw.md)

## How to Measure

- **Developer Console (F9)** > Rendering tab: shows scene draw count.
- **MicroProfiler** (`Ctrl+Alt+F6`): look for the Render phase. **Blue** frames in the color classification indicate render-heavy frames.
- **Performance Stats bar** (`Ctrl+Alt+F7`): shows live rendering stats.
- Check if your game is GPU-bound (red frames in MicroProfiler) vs. CPU-bound (orange).

## Common Issues

### Too Many Unique Meshes

Each distinct MeshId + texture combination requires its own draw call. A scene with 200 different tree meshes makes 200 draw calls just for trees. Using the same MeshId across many MeshParts enables instancing, reducing this to 1 draw call.

### Collision Fidelity Too High

Default and Precise collision fidelity are expensive. For decorative objects:

| Fidelity | Use Case |
|----------|----------|
| **Box** | Decorative/non-collision objects (cheapest) |
| **Hull** | Round objects requiring collision |
| **Default/Precise** | Avoid unless necessary |

Source: [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)

### Transparency Overdraw

Semi-transparent parts (0 < Transparency < 1) require back-to-front blending and cannot be early-rejected by the depth buffer. Every overlapping transparent layer costs a full render pass. Stacking transparent decals or particle emitters is the most common source of overdraw.

Source: [transparency-overdraw.md](../raw/community/performance/rendering/transparency-overdraw.md)

### RenderFidelity on Precise

Setting `RenderFidelity` to `Precise` forces the original mesh at all distances, disabling LOD entirely. This wastes triangles on distant objects.

## Optimization Patterns

### 1. Mesh Instancing (Reuse MeshIds)

Use the same `MeshId` across many MeshParts. The engine can batch-render instances of the same mesh in fewer draw calls.

### 2. Set RenderFidelity to Automatic

`Automatic` enables LOD-based mesh switching at distance thresholds:
- **High -> Medium** at **250 studs** (~50% triangle reduction)
- **Medium -> Low** at **500 studs** (~75% triangle reduction)

For games where draw calls are the bottleneck, prefer `Automatic` over `Performance` mode. `Performance` provides better triangle reduction but can increase draw call overhead due to LOD switching.

Source: [mesh-lod-render-fidelity.md](../raw/community/performance/rendering/mesh-lod-render-fidelity.md)

### 3. Reduce Transparency

- Replace semi-transparent parts with opaque alternatives where visually acceptable.
- Avoid stacking transparent particle emitters, decals, or glass panels.
- Use `Transparency = 1` (fully invisible) for collision-only parts -- they are free to render.

### 4. Quick Configuration Wins

```
Workspace.PlayerCharacterDestroyBehavior = Enabled
Workspace.ClientAnimatorThrottling = Enabled
Workspace.PhysicsSteppingMethod = Adaptive
MeshPart.RenderFidelity = Automatic
```

Source: [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)

### 5. Shadow Optimization

Disable `CastShadow` on most parts. Enable only on key structures. Shadows increase per-object render overhead.

Source: [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md)

### 6. Streaming Enabled

Enable `StreamingEnabled` to only replicate parts near the player. This directly reduces draw calls for large worlds by not rendering distant objects at all.

## Pitfalls

- **Each LOD level adds draw calls.** LOD switching is not free -- the engine manages this, but `Performance` mode can increase draw call count while reducing triangles. Test both modes.
- **RenderFidelity cannot be set via script at runtime.** It is a Studio/plugin-only property.
- **Textured meshes simplify poorly** at lower LOD levels. LOD works best for MeshParts without textures.
- **Unions are not instanced.** Unlike MeshParts, CSG unions each produce unique geometry that cannot be batched.
- **The 500 draw call target is a guideline**, not a hard engine limit. But exceeding it on mobile devices causes visible frame drops.

## Related

- [[object-pooling]]
- [[heartbeat-budget]]
- [[texture-memory]]
- [[physics-budget]]

## Sources

- [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)
- [mesh-lod-render-fidelity.md](../raw/community/performance/rendering/mesh-lod-render-fidelity.md)
- [transparency-overdraw.md](../raw/community/performance/rendering/transparency-overdraw.md)
