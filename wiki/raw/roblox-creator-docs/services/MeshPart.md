---
title: MeshPart
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MeshPart
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MeshPart.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: world
tags: [roblox-class, parts, mesh, 3d]
---

# MeshPart

A form of `Class.BasePart` that includes a physically simulated custom mesh.

## Description

`Class.MeshPart` is a form of `Class.BasePart` that includes a physically
simulated custom mesh. Unlike with other mesh classes, such as
`Class.SpecialMesh` and `Class.BlockMesh`, they are not parented to a
`Class.BasePart` but rather behave as a `Class.BasePart` in their own right.

The mesh and texture of a `Class.MeshPart` are determined by the
`Class.MeshPart.MeshId|MeshId` and `Class.MeshPart.TextureID|TextureID`
properties. For more information, see [Meshes](../../../parts/meshes.md).

## Inheritance

Inherits from: `TriangleMeshPart`

Memory category: `BaseParts`

## Properties

### `MeshPart.DoubleSided`

- **Type:** `boolean`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Determines whether to render both faces of polygons in the mesh.

This property determines whether to render both faces of polygons in the
mesh. It is only changeable in Studio. This is useful for meshes that are
typically modeled as "cards" such as a leaf, hair, or cloth.

### `MeshPart.HasJointOffset`

- **Type:** `boolean`
- **Security:** `read=None, write=NotAccessibleSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`
- **Capabilities:** `Basic`

### `MeshPart.HasSkinnedMesh`

- **Type:** `boolean`
- **Security:** `read=None, write=NotAccessibleSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`
- **Capabilities:** `Basic`

### `MeshPart.JointOffset`

- **Type:** `Vector3`
- **Security:** `read=None, write=NotAccessibleSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`
- **Capabilities:** `Basic`

### `MeshPart.MeshContent`

- **Type:** `Content`
- **Security:** `read=None, write=NotAccessibleSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

The mesh that is displayed on the `Class.MeshPart`. Supports
[asset URIs](../../../projects/assets/index.md#asset-uris) and
`Class.EditableMesh` objects.

The mesh that is displayed on the `Class.MeshPart`. Supports
[asset URIs](../../../projects/assets/index.md#asset-uris) and
`Class.EditableMesh` objects.

Note that this property cannot be changed directly by scripts, as the
collision geometry of the mesh cannot be recomputed in real time. See
`Class.AssetService:CreateMeshPartAsync()` as a method to create a new
`Class.MeshPart` from a given `Datatype.Content` with a specified
`Class.MeshPart.CollisionFidelity|CollisionFidelity`.
`Class.MeshPart:ApplyMesh()` can be used to overwrite the
`Class.MeshPart.MeshContent|MeshContent`,
`Class.MeshPart.TextureContent|TextureContent`, and collision geometry of
an existing `Class.MeshPart`.

### `MeshPart.MeshId`

- **Type:** `ContentId`
- **Security:** `read=None, write=NotAccessibleSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

The [asset URIs](../../../projects/assets/index.md#asset-uris) of the mesh
that is displayed on the `Class.MeshPart`. Reads and writes to
`Class.MeshPart.MeshContent|MeshContent`.

The [asset URIs](../../../projects/assets/index.md#asset-uris) of the mesh
that is displayed on the `Class.MeshPart`. Reads and writes to
`Class.MeshPart.MeshContent|MeshContent`.

Note that this property cannot be changed directly by scripts, as the
collision geometry of the mesh cannot be recomputed in real time. See
`Class.AssetService:CreateMeshPartAsync()` as a method to create a new
`Class.MeshPart` from a given `Datatype.Content` with a specified
`Class.MeshPart.CollisionFidelity|CollisionFidelity`.
`Class.MeshPart:ApplyMesh()` can be used to overwrite the
`Class.MeshPart.MeshContent|MeshContent`,
`Class.MeshPart.TextureContent|TextureContent`, and collision geometry of
an existing `Class.MeshPart`.

### `MeshPart.RenderFidelity`

- **Type:** `RenderFidelity`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

The level of detail used to render the `Class.MeshPart`.

This property determines the level of detail that the `Class.MeshPart`
will be shown in. It can be set to the possible values of the
`Enum.RenderFidelity` enum.

The default value is `Enum.RenderFidelity.Automatic|Automatic`, meaning
the mesh's detail is based on its distance from the camera as outlined in
the following table.

<table>
    <thead>
        <tr>
            <th>Distance From Camera</th>
            <th>Render Fidelity</th>
            <th>Example</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Less than 250 studs</td>
            <td>Highest</td>
            <td><img src="../../../assets/modeling/meshes/Render-Fidelity-High.jpg" width="200" /></td>
        </tr>
        <tr>
            <td>250-500 studs</td>
            <td>Medium</td>
            <td><img src="../../../assets/modeling/meshes/Render-Fidelity-Medium.jpg" width="200" /></td>
        </tr>
        <tr>
            <td>500 or more studs</td>
            <td>Lowest</td>
            <td><img src="../../../assets/modeling/meshes/Render-Fidelity-Low.jpg" width="200" /></td>
        </tr>
    </tbody>
</table>

### `MeshPart.TextureContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

The texture applied to the `Class.MeshPart`. Supports
[asset URIs](../../../projects/assets/index.md#asset-uris) and
`Class.EditableImage` objects.

The texture applied to the `Class.MeshPart`. Supports
[asset URIs](../../../projects/assets/index.md#asset-uris) and
`Class.EditableImage` objects.

When this property is set to `Datatype.Content.none`, no texture will be
applied to the mesh.

```
local Workspace = game:GetService("Workspace")

local meshPart = Workspace.MeshPart
meshPart.TextureContent = Content.none  -- No texture
```

Note that the `Class.MeshPart.MeshContent|MeshContent` property cannot be
directly changed during runtime but the texture can.

##### Changing a Mesh Texture

Using the `Class.MeshPart.TextureContent|TextureContent` property, the
texture of a mesh can be changed without having to re-upload the mesh. To
do this, a new image can be uploaded to Roblox with the desired texture.
The original texture image file can be obtained by exporting the mesh
using the **Export Selection** option in Studio. The image file will be
saved alongside the exported `.obj` file.

The new texture can then be uploaded to Roblox as a decal and its
[asset URI](../../../projects/assets/index.md#asset-uris) can be applied
to the mesh using the `Class.MeshPart.TextureContent|TextureContent` or
`Class.MeshPart.TextureID|TextureID` property.

`Class.MeshPart.TextureContent|TextureContent` can also be set to
reference an `Class.EditableImage` that has not been published yet.

```
local AssetService = game:GetService("AssetService")
local Workspace = game:GetService("Workspace")

local meshPart = Workspace.MeshPart

local editableImage = AssetService:CreateEditableImageAsync(meshPart.TextureContent)
meshPart.TextureContent = Content.fromObject(editableImage)  -- Live updates
```

When `Class.MeshPart.TextureContent|TextureContent` references an
`Class.EditableImage`, the texture will live update with any edits to the
`Class.EditableImage` object.

##### Making a Textured Mesh

A mesh can only be textured if the mesh has been UV mapped, referring to
the practice of projecting a texture map onto a mesh. This cannot be done
using Roblox Studio and must be done using an external 3D modeling
application such as [Blender](https://www.blender.org/).

### `MeshPart.TextureID`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

The texture applied to the `Class.MeshPart`. Reads and writes to
`Class.MeshPart.TextureContent|TextureContent`.

The texture applied to the `Class.MeshPart`. Reads and writes to
`Class.MeshPart.TextureContent|TextureContent`.

When this property is set to an empty string, no texture will be applied
to the mesh.

```
local Workspace = game:GetService("Workspace")

local meshPart = Workspace.MeshPart
meshPart.TextureID = ""  -- No texture
```

Note that the `Class.MeshPart.MeshId` property cannot be changed during
runtime but the texture can. See
`Class.MeshPart.TextureContent|TextureContent` for details.

## Methods

### `MeshPart:ApplyMesh`

```
ApplyMesh(meshPart: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Overwrites the `Class.MeshPart.MeshContent|MeshContent`,
`Class.MeshPart.TextureContent|TextureContent`, and collision geometry
properties of this `Class.MeshPart` from the given source `meshPart`.

Overwrites the `Class.MeshPart.MeshContent|MeshContent`,
`Class.MeshPart.TextureContent|TextureContent`, and collision geometry
properties of this `Class.MeshPart` from the given source `meshPart`.

Most of these properties are read-only and cannot be changed during
runtime on their own directly. To keep
`Class.MeshPart.MeshContent|MeshContent` and physics data in sync, they
must be updated together.

Copies the following properties:

- `Class.MeshPart.MeshContent` (implicitly updates
  `Class.MeshPart.MeshId|MeshId`)
- `Class.MeshPart.TextureContent` (implicitly updates
  `Class.MeshPart.TextureID|TextureID`)
- `Class.MeshPart.RenderFidelity`
- `Class.MeshPart.CollisionFidelity` (with any internal collision
  geometry)
- `Class.MeshPart.FluidFidelity` (with any internal aero geometry)
- `Class.MeshPart.MeshSize`

**Parameters:**

- `meshPart` : `Instance` --- 

**Returns:**

- `()` --- 

## Events

_No public events documented._

## Notes / Deprecations

- Property `MeshPart.DoubleSided` security: `read=None, write=PluginSecurity`
- Property `MeshPart.HasJointOffset` security: `read=None, write=NotAccessibleSecurity`
- Property `MeshPart.HasSkinnedMesh` security: `read=None, write=NotAccessibleSecurity`
- Property `MeshPart.JointOffset` security: `read=None, write=NotAccessibleSecurity`
- Property `MeshPart.MeshContent` security: `read=None, write=NotAccessibleSecurity`
- Property `MeshPart.MeshId` security: `read=None, write=NotAccessibleSecurity`
- Property `MeshPart.RenderFidelity` security: `read=None, write=PluginSecurity`
- Property `MeshPart.TextureContent` security: `read=None, write=None`
- Property `MeshPart.TextureID` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/MeshPart
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MeshPart.yaml
- Captured: 2026-04-16
