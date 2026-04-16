---
title: Terrain Editor
type: studio
category: studio
subcategory: world-building
owner: level-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/studio-features/terrain-editor-official.md
related:
  - "[[plugin-development]]"
tags: [studio, terrain, editor, sculpt, paint, generate, heightmap, world-building]
---

# Terrain Editor

> Built-in Studio tool for procedural generation, sculpting, painting, and editing voxel-based terrain.

## Summary

The Terrain Editor provides Create and Edit toolsets for building environments using Roblox's voxel terrain system. Terrain is resolution-independent (4-stud voxel grid), supports multiple material types, and integrates with `workspace.Terrain` at runtime. The editor is accessible via **Home tab** or **Window > 3D**.

## Create Tab

### Generate

Procedurally generates terrain within a selected region. Useful for creating large maps before fine-tuning.

| Setting | Description |
|---------|-------------|
| Biomes | Which biomes to include (grassland, desert, arctic, etc.) |
| Blending | Transition smoothness between biomes (higher = smoother) |
| Caves | Include procedural cave systems |
| Biome Size | Scale of biomes within the region |
| Seed | Deterministic number for terrain shape; same seed + settings = same terrain |

### Import

Applies heightmap images (grayscale) and optional colormap images to selected regions. Includes a Default Material setting for consistent material across imported terrain.

### Clear

Removes all terrain in the entire place. Destructive; no undo once committed.

## Edit Tab

### Selection and Transform

| Tool | Purpose |
|------|---------|
| Select | Rectangular region selector with move draggers, scale handles, numeric X/Y/Z inputs. Supports copy/paste/cut/duplicate/delete. |
| Transform | Position, rotation, and size adjustments. **Live Edit** updates terrain during transform. **Merge Empty** lets air voxels overwrite existing voxels. |

### Material Tools

| Tool | Purpose |
|------|---------|
| Fill | Applies material to entire selection (Fill mode) or swaps materials (Replace mode) |
| Paint | Applies material over existing terrain (Paint mode) or swaps (Replace mode) |
| Sea Level | Creates consistent water levels or removes water from regions |

### Brush Tools

| Tool | Description |
|------|-------------|
| Draw | Adds or subtracts terrain. Ctrl/Cmd toggles subtract. Brush shapes: sphere, box, cylinder. |
| Sculpt | Like Draw but with strength slider (0.1-1) for gentle manipulation |
| Smooth | Smoothes abrupt edges. Also activates via Shift+click during Draw/Sculpt |
| Flatten | Levels terrain to a consistent height. Modes: Erode, Grow, Flatten All |

### Common Brush Settings

| Setting | Range | Description |
|---------|-------|-------------|
| Brush Size | 1-64 | Brush radius in studs |
| Strength | 0.1-1 | Sculpt/smooth intensity |
| Pivot Position | Bottom/Center/Top | Brush origin alignment |
| Snap to Voxels | on/off | Grid alignment |
| Plane Lock | Auto/Manual | Constrains brush to a plane |
| Ignore Water | on/off | Brush skips water voxels |
| Ignore Parts | on/off | Brush skips Part instances |
| Auto Material | on/off | Uses nearby materials when adding (Draw tool) |

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| B | Adjust base brush size |
| Ctrl+B | Adjust brush height |
| Shift+B | Adjust brush strength |
| Alt | Display material picker |
| Ctrl/Cmd | Toggle alternate brush mode (subtract) |
| Shift | Temporarily activate Smooth tool |

## Scripting Terrain at Runtime

The `workspace.Terrain` object exposes methods for procedural terrain manipulation:

```lua
local terrain = workspace.Terrain

-- Fill a region with material
terrain:FillBlock(
    CFrame.new(0, -10, 0),  -- center
    Vector3.new(100, 20, 100),  -- size
    Enum.Material.Grass
)

-- Read/write voxels
local materials, occupancies = terrain:ReadVoxels(region, resolution)
terrain:WriteVoxels(region, resolution, materials, occupancies)

-- Fill a sphere
terrain:FillBall(Vector3.new(0, 5, 0), 20, Enum.Material.Rock)
```

## Pitfalls

- Terrain voxels are 4 studs; fine detail below that resolution is not possible.
- Large terrain regions consume significant memory; use `StreamingEnabled` for big maps.
- The Clear tool is irreversible once committed; always save before clearing.
- Heightmap imports require grayscale images; incorrect formats produce flat terrain.
- Terrain rendering performance scales with visible surface area, not volume. Caves and overhangs are cheaper than expected.
- Custom materials (MaterialVariant) can be painted but require asset setup in MaterialService.

## Related

- [[plugin-development]] -- Custom terrain tools can be built as Studio plugins.

## Sources

- [Roblox Creator Docs: Terrain Editor](wiki/raw/community/articles/studio-features/terrain-editor-official.md)
- [Roblox Creator Docs: Environmental Terrain](https://create.roblox.com/docs/parts/terrain)
- [DevForum: Terrain Editor Update (Beta)](https://devforum.roblox.com/t/terrain-editor-update-beta/2841125)
