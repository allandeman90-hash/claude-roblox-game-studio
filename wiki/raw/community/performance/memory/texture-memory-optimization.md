---
title: Texture Memory Optimization
type: raw-source
source_url: https://devforum.roblox.com/t/tutorial-optimizing-textures-and-images/185497
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: memory
tags: [textures, memory, compression, images]
---

# Texture Memory Optimization

## Key Principle

Uploaded images are stored **uncompressed** in device memory. File compression (JPEG/PNG) reduces download times but **doesn't affect on-device memory usage**. Only canvas size reduction matters for memory.

## Memory Calculation

A texture's memory footprint is approximately:
```
width * height * 4 bytes (RGBA)
```

Plus MIP map overhead: approximately 1.33x the base size.

### Examples
| Texture Size | Base Memory | With MIPs (~1.33x) |
|--------------|-------------|---------------------|
| 1024 x 1024 | 4 MB | ~5.3 MB |
| 512 x 512 | 1 MB | ~1.3 MB |
| 256 x 256 | 256 KB | ~340 KB |
| 128 x 128 | 64 KB | ~85 KB |

Halving the dimensions quarters the memory (one-quarter the pixels).

## Roblox Platform Constraints

Roblox automatically scales images exceeding 1024 pixels on any dimension down to **1024 x 1024** for texture assets (including mesh textures and decals).

## Size Reduction Methods

### Photoshop
File > Scripts > Image Processor for batch:
- Downscale to 420 x 420 or lower
- Adjust JPEG quality (1-12, lower = more compressed)

### Online Tools
- compresspng.com or tinypng.com for compression
- iloveimg.com for bulk resizing

### Format Selection
- **JPG** for textures without transparency (no alpha channel overhead)
- **PNG-8** instead of PNG-24 when transparency needed but lower quality acceptable
- Bilinear resampling further reduces PNG file sizes

## Real-World Impact

Example: reducing 24 textures averaging 800 KB each through downscaling and compression yielded minimal visual quality loss in-game, particularly with voxel lighting enabled.

## Additional Strategy

Provide players texture quality options (1024, 512, 256 pixels) to accommodate varying hardware capabilities.

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Max texture upload size | 1024 x 1024 |
| 1024 texture memory | ~5.3 MB (w/ MIPs) |
| 512 texture memory | ~1.3 MB (w/ MIPs) |
| Memory formula | w * h * 4 bytes * 1.33 |
| Cumulative texture memory budget (mobile) | ~200 MB |

## Source

Original URL: https://devforum.roblox.com/t/tutorial-optimizing-textures-and-images/185497
Captured: 2026-04-16
