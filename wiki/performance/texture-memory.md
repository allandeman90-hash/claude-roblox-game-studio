---
title: Texture Memory
type: performance
category: performance
subcategory: memory
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/memory/texture-memory-optimization.md
  - wiki/raw/community/performance/profiling/improving-game-performance-guide.md
related:
  - "[[server-memory-budget]]"
  - "[[draw-call-optimization]]"
tags: [performance, memory, textures, rendering]
---

# Texture Memory

## Summary

Uploaded images are stored **uncompressed** in device GPU memory. File compression (JPEG/PNG) reduces download size but does **not** affect runtime memory. Only reducing canvas dimensions reduces memory. Roblox scales images exceeding 1024 pixels on any dimension down to **1024 x 1024**. The recommended default for most assets is **512 x 512**.

## Measurements / Budgets

### Memory Formula

```
memory = width * height * 4 bytes (RGBA) * 1.33 (MIP maps)
```

### Size Lookup Table

| Texture Size | Base Memory | With MIPs (~1.33x) | Source |
|--------------|-------------|---------------------|--------|
| **1024 x 1024** | 4 MB | **~5.3 MB** | [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md) |
| **512 x 512** | 1 MB | **~1.3 MB** | [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md) |
| 256 x 256 | 256 KB | ~340 KB | [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md) |
| 128 x 128 | 64 KB | ~85 KB | [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md) |

**Key ratio**: 1024 vs 512 = **4x memory difference** (halving dimensions quarters pixels).

| Budget | Value | Source |
|--------|-------|--------|
| Max texture upload size | **1024 x 1024** | [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md) |
| Cumulative texture memory (mobile) | **~200 MB** | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| Recommended max for most assets | **512 x 512** | INDEX.md |

Source: [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md)

## How to Measure

- **Developer Console (F9)** > Memory tab: check the "GraphicsTexture" category for total texture memory in use.
- **MicroProfiler X-Ray mode**: shows per-frame allocation intensity, including texture uploads.
- Calculate expected budget: count textures x their per-texture memory from the table above. Compare against the ~200 MB mobile cap.

## Common Issues

### Uploading 1024 x 1024 When 512 Would Suffice

Every 1024-texture costs ~5.3 MB. 40 such textures consume ~212 MB -- already exceeding the mobile texture budget. Dropping to 512 reduces this to ~52 MB.

### PNG vs JPEG Misunderstanding

File format affects **download size** only. A 512x512 PNG and a 512x512 JPEG use the same ~1.3 MB of GPU memory. Choose JPEG for textures without alpha channels (smaller download, identical runtime cost). Use PNG only when transparency is needed.

### High-Resolution Textures on Small Objects

A 1024 x 1024 texture on a small decal that is only a few studs wide wastes memory. The visual benefit is negligible at that scale; 256 x 256 or 128 x 128 is sufficient.

## Optimization Patterns

### Batch Downscale

Use image processing tools to batch-downscale textures before upload:
- **Photoshop**: File > Scripts > Image Processor (batch resize to 512 or 420)
- **Online**: compresspng.com, tinypng.com (compression), iloveimg.com (resizing)

### Format Selection

| Format | Use When |
|--------|----------|
| JPEG | Textures without transparency (smallest download) |
| PNG-8 | Transparency needed, lower quality acceptable |
| PNG-24 | Full quality transparency (most expensive) |

### Player Texture Quality Options

Provide texture quality options (1024, 512, 256) and let players choose based on their device capability. Implement by swapping asset IDs:

```lua
local QUALITY = {
    High = "rbxassetid://1234_1024",
    Medium = "rbxassetid://1234_512",
    Low = "rbxassetid://1234_256",
}
decal.Texture = QUALITY[playerSetting]
```

Source: [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md)

## Pitfalls

- **File compression is not runtime compression.** Compressing a PNG to 50 KB on disk still uses the full `w * h * 4 * 1.33` bytes in GPU memory.
- **MIP maps add ~33% overhead** but are essential for visual quality at distance. Do not attempt to disable them.
- **Roblox automatically downscales** textures > 1024 px. Uploading a 2048 x 2048 image wastes upload time -- it will be scaled to 1024 x 1024 anyway.
- **Voxel lighting** reduces visible quality differences between high and low resolution textures, making aggressive downscaling more viable in voxel-lit games.

## Related

- [[server-memory-budget]]
- [[draw-call-optimization]]

## Sources

- [texture-memory-optimization.md](../raw/community/performance/memory/texture-memory-optimization.md)
- [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md)
