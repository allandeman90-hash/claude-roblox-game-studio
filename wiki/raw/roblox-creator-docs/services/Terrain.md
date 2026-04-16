---
title: Terrain
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Terrain
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Terrain.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: world
tags: [roblox-class, terrain, landscape, voxel]
---

# Terrain

Terrain lets you to create dynamically morphable environments.

## Description

Terrain lets you create dynamically morphable environments with little to no
lag. It is currently based on a 4&times;4&times;4 grid of cells, where each
cell has a number between 0 and 1 representing how much the geometry should
occupy the cell, and the material of the cell. The occupancy determines how
the cell will morph together with surrounding cells, and the result is the
illusion of having no grid constraint.

For more information, see [Terrain](../../../parts/terrain.md).

## Inheritance

Inherits from: `BasePart`

Class tags: `NotCreatable`

Memory category: `Instances`

## Properties

### `Terrain.Decoration`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Environment`

Enables or disables terrain decoration.

Currently enables or disables animated grass on the **Grass** terrain
material, although future modifications of this property may control
additional decorative features.

### `Terrain.GrassLength`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Environment`

Specifies the length of animated grass.

Specifies the length of animated grass on the **Grass** terrain material,
assuming `Class.Terrain.Decoration|Decoration` is enabled. Valid values
are between 0.1 and 1.

### `Terrain.IsSmooth`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Environment`
- **Deprecated:** Sets the specified terrain voxel's material to ''Water'' and sets its
occupancy to 1.

Returns true if the current game is using the smooth terrain system.

Returns true if the current game is using the smooth terrain system. The
legacy terrain engine has been removed, so this property will always be
true.

### `Terrain.MaterialColors`

- **Type:** `BinaryString`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Environment`

MaterialColors represents the editor for the Material Color feature, and
**cannot be edited by scripts**.

To get the color of a material, use: `Class.Terrain:GetMaterialColor()` To
set the color of a material, use: `Class.Terrain:SetMaterialColor()`

MaterialColors represents the editor for the Material Color feature, and
**cannot be edited by scripts**.

To get the color of a material, use: `Class.Terrain:GetMaterialColor()`

To set the color of a material, use: `Class.Terrain:SetMaterialColor()`

### `Terrain.MaxExtents`

- **Type:** `Region3int16`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Environment`

Displays the boundaries of the largest possible editable region.

### `Terrain.WaterColor`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The tint of the Terrain water.

### `Terrain.WaterReflectance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Controls how opaque the Terrain's water reflections are.

### `Terrain.WaterTransparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The transparency of the Terrain water.

### `Terrain.WaterWaveSize`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Sets the maximum height of the Terrain water waves in studs.

Sets the maximum height of the Terrain water waves in studs. This is
currently constrained to between 0 and 1.

### `Terrain.WaterWaveSpeed`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Sets how many times the Terrain water waves will move up and down per
minute.

Sets how many times the Terrain water waves will move up and down per
minute. This is currently constrained to between 0 and 100.

## Methods

### `Terrain:AutowedgeCell`

```
AutowedgeCell(x: int, y: int, z: int) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.

_(OBSOLETE)_ No longer does anything.

**Parameters:**

- `x` : `int` --- 
- `y` : `int` --- 
- `z` : `int` --- 

**Returns:**

- `boolean` --- 

### `Terrain:AutowedgeCells`

```
AutowedgeCells(region: Region3int16) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.

_(OBSOLETE)_ No longer does anything.

**Parameters:**

- `region` : `Region3int16` --- 

**Returns:**

- `()` --- 

### `Terrain:CellCenterToWorld`

```
CellCenterToWorld(x: int, y: int, z: int) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Returns the world position of the center of the terrain cell (x, y, z).

**Parameters:**

- `x` : `int` --- 
- `y` : `int` --- 
- `z` : `int` --- 

**Returns:**

- `Vector3` --- 

### `Terrain:CellCornerToWorld`

```
CellCornerToWorld(x: int, y: int, z: int) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Returns the position of the lower-left-forward corner of the grid cell (x,
y, z).

**Parameters:**

- `x` : `int` --- 
- `y` : `int` --- 
- `z` : `int` --- 

**Returns:**

- `Vector3` --- 

### `Terrain:Clear`

```
Clear() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Clears the terrain.

**Returns:**

- `()` --- 

### `Terrain:ClearVoxelsAsync_beta`

```
ClearVoxelsAsync_beta(region: Region3, channelIds: Array) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Environment`

**Parameters:**

- `region` : `Region3` --- 
- `channelIds` : `Array` --- 

**Returns:**

- `()` --- 

### `Terrain:ConvertToSmooth`

```
ConvertToSmooth() -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** Since all places now automatically use the new terrain engine, this method
is obsolete. Do not use it for new work.

Transforms the legacy terrain engine into the new terrain engine.

Transforms the legacy terrain engine into the new terrain engine.

All places now automatically use the new terrain engine, so this method is
obsolete.

**Returns:**

- `()` --- 

### `Terrain:CopyRegion`

```
CopyRegion(region: Region3int16) -> TerrainRegion
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Stores a chunk of terrain into a `Class.TerrainRegion` object so it can be
loaded back later. Note: `Class.TerrainRegion` data does not replicate
between server and client.

**Parameters:**

- `region` : `Region3int16` --- 

**Returns:**

- `TerrainRegion` --- 

### `Terrain:CountCells`

```
CountCells() -> int
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Returns the number of non-empty cells in the Terrain.

**Returns:**

- `int` --- 

### `Terrain:FillBall`

```
FillBall(center: Vector3, radius: float, material: Material) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Fills a ball of smooth terrain in a given space.

**Parameters:**

- `center` : `Vector3` --- The position of the center of the terrain ball.
- `radius` : `float` --- The radius in studs of the terrain ball.
- `material` : `Material` --- The `Enum.Material` of the terrain ball.

**Returns:**

- `()` --- 

### `Terrain:FillBlock`

```
FillBlock(cframe: CFrame, size: Vector3, material: Material) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Fills a block of smooth terrain with a given location, rotation, size, and
material.

**Parameters:**

- `cframe` : `CFrame` --- The position and orientation of the terrain block.
- `size` : `Vector3` --- The size in studs of the square block - both the height and width.
- `material` : `Material` --- The `Enum.Material` of the terrain block.

**Returns:**

- `()` --- 

### `Terrain:FillCylinder`

```
FillCylinder(cframe: CFrame, height: float, radius: float, material: Material) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Fills a cylinder of smooth terrain in a given space.

Fills a cylinder of smooth terrain in a given space. The space is defined
using a CFrame, height, and radius.

```lua
local Workspace = game:GetService("Workspace")

Workspace.Terrain:FillCylinder(CFrame.new(0, 50, 0), 5, 30, Enum.Material.Asphalt)
```

**Parameters:**

- `cframe` : `CFrame` --- The position and orientation of the terrain cylinder.
- `height` : `float` --- The height in studs of the terrain cylinder.
- `radius` : `float` --- The radius in studs of the terrain cylinder.
- `material` : `Material` --- The `Enum.Material` of the terrain cylinder.

**Returns:**

- `()` --- 

### `Terrain:FillRegion`

```
FillRegion(region: Region3, resolution: float, material: Material) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Fills a `Datatype.Region3` space with smooth terrain.

**Parameters:**

- `region` : `Region3` --- 
- `resolution` : `float` --- 
- `material` : `Material` --- 

**Returns:**

- `()` --- 

### `Terrain:FillWedge`

```
FillWedge(cframe: CFrame, size: Vector3, material: Material) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Fills a wedge-shaped volume of Terrain with the given `Enum.Material` and
the area's CFrame and Size.

`FillWedge()` fills a wedge-shaped volume of `Class.Terrain` with the
given `Enum.Material` and the area's `Datatype.CFrame` and size. The
orientation of the wedge is the same as an equivalent `Class.WedgePart`.

**Parameters:**

- `cframe` : `CFrame` --- The position and orientation of the wedge to fill.
- `size` : `Vector3` --- The size of the wedge to fill.
- `material` : `Material` --- The material with which the wedge will be filled.

**Returns:**

- `()` --- 

### `Terrain:GetCell`

```
GetCell(x: int, y: int, z: int) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.

Returns the closest CellMaterial from the legacy terrain engine that
matches the smooth terrain voxel specified.

Returns the closest CellMaterial from the legacy terrain engine that
matches the smooth terrain voxel specified. CellBlock will always be
''Solid'' and CellOrientation will always be ''NegZ''.

**Parameters:**

- `x` : `int` --- 
- `y` : `int` --- 
- `z` : `int` --- 

**Returns:**

- `Tuple` --- 

### `Terrain:GetMaterialColor`

```
GetMaterialColor(material: Material) -> Color3
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Environment`

Returns current terrain material color for specified terrain material.

Returns the current terrain material color for the specified terrain
material.

**Parameters:**

- `material` : `Material` --- 

**Returns:**

- `Color3` --- 

### `Terrain:GetWaterCell`

```
GetWaterCell(x: int, y: int, z: int) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.

Returns if the cell is a water cell.

Returns if the cell is a water cell. The WaterForce parameter will always
be _None_ and the WaterDirection will always be _NegX_.

**Parameters:**

- `x` : `int` --- 
- `y` : `int` --- 
- `z` : `int` --- 

**Returns:**

- `Tuple` --- 

### `Terrain:IterateVoxelsAsync_beta`

```
IterateVoxelsAsync_beta(region: Region3, resolution: int, channelIds: Array) -> TerrainIterateOperation
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Environment`

**Parameters:**

- `region` : `Region3` --- 
- `resolution` : `int` --- 
- `channelIds` : `Array` --- 

**Returns:**

- `TerrainIterateOperation` --- 

### `Terrain:ModifyVoxelsAsync_beta`

```
ModifyVoxelsAsync_beta(region: Region3, resolution: int, channelIds: Array) -> TerrainModifyOperation
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Environment`

**Parameters:**

- `region` : `Region3` --- 
- `resolution` : `int` --- 
- `channelIds` : `Array` --- 

**Returns:**

- `TerrainModifyOperation` --- 

### `Terrain:PasteRegion`

```
PasteRegion(region: TerrainRegion, corner: Vector3int16, pasteEmptyCells: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Applies a chunk of terrain to the Terrain object. Note:
`Class.TerrainRegion` data does not replicate between server and client.

**Parameters:**

- `region` : `TerrainRegion` --- 
- `corner` : `Vector3int16` --- 
- `pasteEmptyCells` : `boolean` --- 

**Returns:**

- `()` --- 

### `Terrain:ReadVoxelChannels`

```
ReadVoxelChannels(region: Region3, resolution: float, channelIds: Array) -> Dictionary
```

- security=`None` ; thread-safety=`Safe` ; tags=`CustomLuaState` ; capabilities=`Environment`

Returns a region of terrain voxel data in table format based on the
channel names.

**Parameters:**

- `region` : `Region3` --- Target region to read from. Must be aligned to the voxel grid. Will throw an error if region is too large; limit is currently 4194304 voxels&sup3;.
- `resolution` : `float` --- Voxel resolution. Must be 4.
- `channelIds` : `Array` --- Array of channel IDs (strings) that need to be accessed from the voxel data. Each channel ID represents a type of data that's stored in voxel. Current supported IDs are `{"SolidMaterial", "SolidOccupancy", "LiquidOccupancy"}`.

**Returns:**

- `Dictionary` --- Returns voxel data as a dictionary based on the `channelIds` input. Keys represent each channel ID with their respective value as an array of 3D data.  - `SolidMaterial` — The `Enum.Material` material of the voxel. Note   that `Enum.Material|Water` is not supported anymore; instead, a   voxel that contains water will have a value of `LiquidOccupancy`. - `SolidOccupancy` — The occupancy of the voxel's material as   specified in the `SolidMaterial` channel. This is a value between 0   (empty) and 1 (full). - `LiquidOccupancy` — Specifies the occupancy of the   `Enum.Material|Water` material in a voxel as a value between 0 (no   water) and 1 (full of water). If the `SolidOccupancy` is 1 and the   `SolidMaterial` is not `Enum.Material|Air`, this will be 0.  The dictionary also contains a `Size` key with a value representing the 3D array size of each channel data.

### `Terrain:ReadVoxels`

```
ReadVoxels(region: Region3, resolution: float) -> Tuple
```

- security=`None` ; thread-safety=`Safe` ; tags=`CustomLuaState` ; capabilities=`Environment`

Returns a certain region of smooth terrain in table format.

**Parameters:**

- `region` : `Region3` --- Target region to read from. Must be aligned to the voxel grid. Will throw an error if region is too large. The limit is currently 4194304 voxels^3.
- `resolution` : `float` --- Voxel resolution. Must be 4.

**Returns:**

- `Tuple` --- Returns raw voxel data as two 3D arrays.  - `materials` - 3D array of `Enum.Material` from the target area. Also   contains a Size field, equal to the dimensions of the nested arrays. - `occupancies` - 3D array of occupancy values from the target area.   Also contains a Size field, equal to the dimensions of the nested   arrays.

### `Terrain:ReadVoxelsAsync_beta`

```
ReadVoxelsAsync_beta(region: Region3, resolution: int, channelIds: Array) -> TerrainReadOperation
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Environment`

**Parameters:**

- `region` : `Region3` --- 
- `resolution` : `int` --- 
- `channelIds` : `Array` --- 

**Returns:**

- `TerrainReadOperation` --- 

### `Terrain:ReplaceMaterial`

```
ReplaceMaterial(region: Region3, resolution: float, sourceMaterial: Material, targetMaterial: Material) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Replaces the terrain of a material within a region with another material.

ReplaceMaterial replaces terrain of a certain `Enum.Material` within a
`Datatype.Region3` with another material. Essentially, it is a
find-and-replace operation on `Class.Terrain` materials.

#### Constraints

When calling this method, the `resolution` parameter must be exactly 4.
Additionally, the Region3 must be aligned to the terrain materials grid,
i.e. the components of the Region3's minimum and maximum points must be
divisible by 4. Use `Datatype.Region3:ExpandToGrid()` to make a region
compatible with this function.

**Parameters:**

- `region` : `Region3` --- The region in which the replacement operation will occur.
- `resolution` : `float` --- The resolution at which the replacement operation will take place; at the moment this must be exactly 4.
- `sourceMaterial` : `Material` --- The old material that shall be replaced.
- `targetMaterial` : `Material` --- The new material.

**Returns:**

- `()` --- 

### `Terrain:SetCell`

```
SetCell(x: int, y: int, z: int, material: CellMaterial, block: CellBlock, orientation: CellOrientation) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.

Sets the occupancy and material of a specific terrain voxel.

Sets the occupancy of the specified terrain voxel to 1, and sets it's
material to the closest smooth terrain material that matches the
CellMaterial.

CellBlock and CellOrientation have no effect.

**Parameters:**

- `x` : `int` --- 
- `y` : `int` --- 
- `z` : `int` --- 
- `material` : `CellMaterial` --- 
- `block` : `CellBlock` --- 
- `orientation` : `CellOrientation` --- 

**Returns:**

- `()` --- 

### `Terrain:SetCells`

```
SetCells(region: Region3int16, material: CellMaterial, block: CellBlock, orientation: CellOrientation) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.

Sets the occupancy and material of all terrain voxels in a specific
region.

Sets the occupancy of all terrain voxels in the specified region to 1, and
sets their materials to the closest smooth terrain material that matches
the CellMaterial.

CellBlock and CellOrientation have no effect.

**Parameters:**

- `region` : `Region3int16` --- 
- `material` : `CellMaterial` --- 
- `block` : `CellBlock` --- 
- `orientation` : `CellOrientation` --- 

**Returns:**

- `()` --- 

### `Terrain:SetMaterialColor`

```
SetMaterialColor(material: Material, value: Color3) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Sets current terrain material color for specified terrain material.

Sets current terrain material color for specified terrain material.
Terrain material will shift its base color toward specified color.

**Parameters:**

- `material` : `Material` --- 
- `value` : `Color3` --- 

**Returns:**

- `()` --- 

### `Terrain:SetWaterCell`

```
SetWaterCell(x: int, y: int, z: int, force: WaterForce, direction: WaterDirection) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.

Sets the specified terrain voxel's material to ''Water'' and sets its
occupancy to 1.

Sets the specified terrain voxel's material to ''Water'' and sets its
occupancy to 1. _WaterDirection_ and _WaterForce_ no longer have any
effect.

_Note:_ This API was intended for Roblox's old terrain system, which has
since been removed from the engine.

**Parameters:**

- `x` : `int` --- 
- `y` : `int` --- 
- `z` : `int` --- 
- `force` : `WaterForce` --- 
- `direction` : `WaterDirection` --- 

**Returns:**

- `()` --- 

### `Terrain:WorldToCell`

```
WorldToCell(position: Vector3) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Returns the grid cell location that contains the point **position**.

**Parameters:**

- `position` : `Vector3` --- 

**Returns:**

- `Vector3` --- 

### `Terrain:WorldToCellPreferEmpty`

```
WorldToCellPreferEmpty(position: Vector3) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Returns the grid cell location that contains the point position,
preferring empty grid cells when position is on a grid edge.

**Parameters:**

- `position` : `Vector3` --- 

**Returns:**

- `Vector3` --- 

### `Terrain:WorldToCellPreferSolid`

```
WorldToCellPreferSolid(position: Vector3) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Returns the grid cell location that contains the point position,
preferring non-empty grid cells when position is on a grid edge.

**Parameters:**

- `position` : `Vector3` --- 

**Returns:**

- `Vector3` --- 

### `Terrain:WriteVoxelChannels`

```
WriteVoxelChannels(region: Region3, resolution: float, channels: Dictionary) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Environment`

Sets a region of terrain using a dictionary of voxel channel data.

**Parameters:**

- `region` : `Region3` --- Target region to write to. Must be aligned to the voxel grid. Will throw an error if region is too large; limit is currently 4194304 voxels&sup3;.
- `resolution` : `float` --- Voxel resolution. Must be 4.
- `channels` : `Dictionary` --- Dictionary of voxel data similar to the return value of `Class.Terrain:ReadVoxelChannels()|ReadVoxelChannels()`. Keys represent each channel ID with their respective value as an array of 3D data. The dictionary can support single or multiple channel inputs.  - `SolidMaterial` — The `Enum.Material` material of the voxel. Note   that `Enum.Material|Water` is not supported anymore; instead, a   voxel that contains only water should be entered as   `SolidMaterial = Enum.Material.Air, LiquidOccupancy = x`, where `x`   is a number between 0 (exclusive) and 1 (inclusive). - `SolidOccupancy` — The occupancy of the voxel's material as   specified in the `SolidMaterial` channel. This should be a value   between 0 (empty) and 1 (full). - `LiquidOccupancy` — Specifies the occupancy of the   `Enum.Material|Water` material in a voxel as a value between 0 (no   water) and 1 (full of water). If the `SolidOccupancy` is 1 and the   `SolidMaterial` is not `Enum.Material|Air`, this will be 0.

**Returns:**

- `()` --- 

### `Terrain:WriteVoxels`

```
WriteVoxels(region: Region3, resolution: float, materials: Array, occupancy: Array) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Environment`

Sets a certain region of smooth terrain using table format.

**Parameters:**

- `region` : `Region3` --- Target region to write to. Must be aligned to the voxel grid. Will throw an error if region is too large.
- `resolution` : `float` --- Voxel resolution. Must be 4.
- `materials` : `Array` --- 3D array of Enum.Material. Dimensions must exactly match the size of the target region in voxels.
- `occupancy` : `Array` --- 3D array of voxel occupancies (number between 0 and 1). Dimensions must exactly match the size of the target region in voxels.

**Returns:**

- `()` --- 

### `Terrain:WriteVoxelsAsync_beta`

```
WriteVoxelsAsync_beta(region: Region3, resolution: int, channelIds: Array) -> TerrainWriteOperation
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Environment`

**Parameters:**

- `region` : `Region3` --- 
- `resolution` : `int` --- 
- `channelIds` : `Array` --- 

**Returns:**

- `TerrainWriteOperation` --- 

## Events

_No public events documented._

## Notes / Deprecations

- Deprecated property `Terrain.IsSmooth`: Sets the specified terrain voxel's material to ''Water'' and sets its
occupancy to 1.
- Deprecated method `Terrain:AutowedgeCell`: This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.
- Deprecated method `Terrain:AutowedgeCells`: This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.
- Deprecated method `Terrain:ConvertToSmooth`: Since all places now automatically use the new terrain engine, this method
is obsolete. Do not use it for new work.
- Deprecated method `Terrain:GetCell`: This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.
- Deprecated method `Terrain:GetWaterCell`: This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.
- Deprecated method `Terrain:SetCell`: This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.
- Deprecated method `Terrain:SetCells`: This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.
- Deprecated method `Terrain:SetWaterCell`: This item is a deprecated function of a legacy `Class.Terrain` engine that
has been removed. Do not use it for new work.
- Method `Terrain:ConvertToSmooth` security: `PluginSecurity`
- Property `Terrain.Decoration` security: `read=None, write=None`
- Property `Terrain.GrassLength` security: `read=None, write=None`
- Property `Terrain.IsSmooth` security: `read=None, write=None`
- Property `Terrain.MaterialColors` security: `read=None, write=None`
- Property `Terrain.MaxExtents` security: `read=None, write=None`
- Property `Terrain.WaterColor` security: `read=None, write=None`
- Property `Terrain.WaterReflectance` security: `read=None, write=None`
- Property `Terrain.WaterTransparency` security: `read=None, write=None`
- Property `Terrain.WaterWaveSize` security: `read=None, write=None`
- Property `Terrain.WaterWaveSpeed` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- Terrain:CopyRegion: Terrain-CopyRegion1
- Terrain:FillBall: Terrain-FillBall1
- Terrain:PasteRegion: Terrain-PasteRegion1
- Terrain:ReadVoxelChannels: terrain-readvoxelchannels-code-example
- Terrain:ReadVoxels: terrain-readvoxels-code-example
- Terrain:ReplaceMaterial: terrain-replacematerial
- Terrain:WriteVoxelChannels: terrain-writevoxelchannels-example
- Terrain:WriteVoxels: terrain-writevoxels-example
- Terrain:WriteVoxels: terrain-writevoxels-max-region

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Terrain
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Terrain.yaml
- Captured: 2026-04-16
