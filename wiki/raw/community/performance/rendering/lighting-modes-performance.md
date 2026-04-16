---
title: Roblox Lighting Modes Performance Comparison
type: raw-source
source_url: https://devforum.roblox.com/t/roblox-lighting-modes-what-do-i-use-for-my-game/1687174
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: rendering
tags: [lighting, voxel, shadowmap, future, compatibility, memory]
---

# Roblox Lighting Modes Performance Comparison

## Client Memory Usage (Averages)

| Lighting Mode | Client Memory | Use Case |
|--------------|---------------|----------|
| **Future** | ~700 MB | Realistic graphics |
| **Voxel** | ~600 MB | Balanced quality/cost |
| **Shadow Map** | ~550 MB | Medium-quality shadows |
| **Compatibility** | ~450 MB | Old-style flat lighting |
| **No Shadows** | ~450 MB | Absolute lowest cost |

## Performance Impact by Use Case

### For Realistic Graphics
**Future mode** recommended, though "this might drop player device performance slightly" on mobile and lower-end devices.

### For Obstacle Course Games
**Voxel** or **Compatibility** modes preferred since most obby developers "disable shadows in their games for more FPS."

### For Large Maps
**Compatibility mode** excels with significantly lower memory demands:
- Large game with many buildings and roads: **Compatibility = 850 MB vs Future = 1,150 MB** (26% reduction)

## Key Performance Insights

- "Shadows are costly in client memory usage" - the primary optimization target
- Performance impact varies: large maps show dramatic differences
- Small simple games: negligible differences between modes
- "Graphics level (the one in the escape menu) has a MAJOR effect on lighting"
- PC players at lower graphics settings experience lighting similar to Compatibility mode regardless of selected lighting engine

## Decision Matrix

| Priority | Recommendation |
|----------|----------------|
| Maximum realism | Future |
| Balance | Shadow Map or Voxel |
| Performance | Compatibility or No Shadows |
| Mobile-heavy | Compatibility |
| Large open worlds | Compatibility or Shadow Map |

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Future client memory | ~700 MB |
| Voxel client memory | ~600 MB |
| ShadowMap client memory | ~550 MB |
| Compatibility client memory | ~450 MB |
| Future vs Compatibility (large map) | 1,150 vs 850 MB (26% reduction) |

## Source

Original URL: https://devforum.roblox.com/t/roblox-lighting-modes-what-do-i-use-for-my-game/1687174
Captured: 2026-04-16
