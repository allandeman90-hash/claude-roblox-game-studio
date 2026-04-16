---
title: "Terrain Editor — Roblox Creator Documentation"
type: raw-source
source_url: https://create.roblox.com/docs/studio/terrain-editor
source_type: official-docs
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: studio-features
tags: [terrain, editor, sculpt, paint, generate, heightmap]
---

# Roblox Terrain Editor

Enables developers to generate and manipulate environmental terrain through Create and Edit toolsets. Accessible via Studio's Home tab or Window > 3D menu.

## Create Tab Tools

### Generate Tool
Procedurally generates terrain within a selected region. Settings:
- **Biomes**: Selected biomes included in generation
- **Blending**: Transition smoothness (higher = smoother)
- **Caves**: Include procedural cave systems
- **Biome Size**: Scale of biomes within terrain
- **Seed**: Number determining terrain shape; change = new terrain, same settings

### Import Tool
Applies heightmaps and optional colormaps to selected regions:
- Heightmap image importing
- Colormap image importing for material application
- Default Material setting

### Clear Tool
Clears all terrain within the entire place.

## Edit Tab Tools

### Select Tool
Rectangular region selector:
- Move draggers and scale handles
- Numeric X/Y/Z inputs
- Snap to Voxels option
- Shortcuts: Ctrl+C/V/X/D, Delete

### Transform Tool
Position, rotation, and size adjustments:
- Move draggers, rotate rings, scale handles
- Live Edit: constant terrain update during transform
- Merge Empty: air voxels overwrite existing voxels

### Fill Tool
Two modes:
- Fill Mode: applies material to entire selection
- Replace Mode: swaps one material for another

### Sea Level Tool
Creates consistent water levels or removes water from regions.

### Draw Tool
Adds or subtracts terrain using brushes. Ctrl/Cmd toggles subtract mode.
- Brush shapes: sphere, box, cylinder
- Brush Size: 1-64 range
- Plane Lock: auto or manual visual plane alignment
- Ignore Water/Parts options
- Auto Material: uses nearby terrain materials when adding

### Sculpt Tool
Like Draw but with strength slider (0.1-1) for gentle manipulation.

### Smooth Tool
Smoothes abrupt edges. Activates standalone or via Shift+click during Draw/Sculpt. Strength: 0.1-1.

### Paint Tool
Two modes:
- Paint Mode: applies selected material
- Replace Mode: swaps source material for target material

### Flatten Tool
Three modes:
- Erode to Flat: removes terrain above plane
- Grow to Flat: fills terrain below plane
- Flatten All: both operations simultaneously

## Common Brush Settings
- Brush Size: 1-64
- Strength: 0.1-1 (sculpting tools)
- Pivot Position: bottom, center, top
- Snapping: voxel alignment
- Plane Lock: auto/manual
- Ignore Water/Parts: exclusion options

## Keyboard Shortcuts (Brush Tools)
- B: adjust base brush size
- Ctrl+B / Cmd+B: adjust brush height
- Shift+B: adjust brush strength
- Alt / Option: display material picker
- Ctrl/Cmd: toggle alternate brush mode
- Shift: activate Smooth tool temporarily

## Region Properties
Size, Position (X/Y/Z in studs), Rotation (Transform tool only). All tools support Snap to Voxels.
