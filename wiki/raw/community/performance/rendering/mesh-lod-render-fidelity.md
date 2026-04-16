---
title: Mesh LOD and RenderFidelity
type: raw-source
source_url: https://devforum.roblox.com/t/levels-of-detail-for-mesh-parts/280769
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: rendering
tags: [mesh, lod, render-fidelity, triangles, draw-calls]
---

# Mesh LOD and RenderFidelity

## Overview

Roblox introduced Level of Detail (LoD) functionality for MeshParts, allowing automatic resolution adjustments based on camera distance.

## Quality Levels

Three distinct detail tiers:

| Level | Quality | Triangle Count |
|-------|---------|----------------|
| High | Original mesh | 100% (baseline) |
| Medium | Auto-generated lower res | ~50% reduction |
| Low | Further reduced | ~75% reduction total |

## Distance Thresholds

Resolution transitions occur at specific stud distances from the camera:

| Transition | Distance |
|------------|----------|
| High -> Medium | **250 studs** |
| Medium -> Low | **500 studs** |

## Activation

Set the `RenderFidelity` property to `"Automatic"` or `"Performance"`:
- **Automatic**: LOD-based switching (balanced approach)
- **Performance**: Use lower-detail mesh; better triangle reduction
- **Precise**: Always use original; maximum quality, no savings

**Note**: Cannot be modified via scripts at runtime - Studio or plugins only.

## Draw Call Impact

Important caveat: "Each LOD model adds draw calls." When RenderFidelity is set to Performance mode, the system streams simplified mesh versions at different distances, which can **increase draw call overhead**.

Mitigations:
- The engine "tries to minimize the overhead caused by switching LODs"
- "Reduces unnecessary swaps between LOD models when it can"

## Recommendations

For projects where draw calls are the primary performance bottleneck:
- **Automatic** is recommended over **Performance** mode
- Automatic "balances the need for geometry simplification with performance optimizations" more effectively

For projects where triangle count matters more than draw calls:
- **Performance** mode provides better triangle reduction

## Known Limitations

- Cannot be controlled through scripts
- Automatic texture handling imperfect - "works best for MeshParts without textures"
- Textured meshes may experience quality degradation during simplification
- Newly-moderated meshes require re-approval when LoD is applied

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| High->Medium threshold | 250 studs |
| Medium->Low threshold | 500 studs |
| Medium triangle reduction | ~50% |
| Low triangle reduction | ~75% total |

## Source

Original URL: https://devforum.roblox.com/t/levels-of-detail-for-mesh-parts/280769
Captured: 2026-04-16
