---
title: Model
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Model
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Model.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: world
tags: [roblox-class, model, grouping, hierarchy]
---

# Model

Models are container objects, meaning they group objects together. They are
best used to hold collections of `Class.BasePart|BaseParts` and have a number
of functions that extend their functionality.

## Description

Models are container objects, meaning they group objects together. They are
best used to hold collections of `Class.BasePart|BaseParts` and have a number
of functions that extend their functionality.

Models are intended to represent **geometric** groupings. If your grouping has
no geometric interpretation, for instance a collection of
`Class.Script|Scripts`, use a `Class.Folder` instead.

Models whose constituent parts are joined together with joints (so that they
can move around or be destroyed via physics simulation) usually have a
`Class.Model.PrimaryPart|PrimaryPart` set, as it specifies which part within
the model the pivot and bounding box will "follow" as the model moves. Static
models which stay in one place do not benefit from having a primary part set.

Models have a wide range of applications, including Roblox player characters.
They also have a number of unique behaviors that are important to keep in
mind:

- When a `Class.Humanoid` and a `Class.Part` named **Head** are parented under
  a model, a name/health GUI will appear over the model; see
  [Character Name/Health Display](../../../characters/name-health-display.md)
  for details.
- If a part's position on the **Y** axis hits the
  `Class.Workspace.FallenPartsDestroyHeight` value, and it was the last object
  inside of a `Class.Model`, the model will be destroyed as well.
- When used in a place with `Class.Workspace.StreamingEnabled` set to true,
  the value of `Class.Model.ModelStreamingMode|ModelStreamingMode` controls
  various behaviors around how the model and any descendants are replicated
  and/or removed from clients. In addition, the value of
  `Class.Model.LevelOfDetail|LevelOfDetail` impacts rendering of the model.

As with all `Class.Instance` types, the fact that a parent `Class.Model` is
replicated to a client does not guarantee that all its children are
replicated. This is particularly important if these instances are being
accessed by code running on the client, such as in a `Class.LocalScript`.
Using `Class.Model.ModelStreamingMode|ModelStreamingMode` with values such as
`Enum.ModelStreamingMode|Atomic` can ensure that the entire model and all of
its descendants are present if the parent model exists on the client, or you
can use `Class.Instance:WaitForChild()|WaitForChild()` when atomicity is not
desired.

## Inheritance

Inherits from: `PVInstance`

Memory category: `BaseParts`

## Properties

### `Model.LevelOfDetail`

- **Type:** `ModelLevelOfDetail`
- **Security:** `read=PluginSecurity, write=PluginSecurity`
- **Thread safety:** `ReadSafe`

Sets the level of detail on the model for experiences with instance
streaming enabled.

Sets the level of detail on the model for experiences with instance
[streaming](../../../workspace/streaming/index.md) enabled.

When set to `Enum.ModelLevelOfDetail|StreamingMesh`, a lower resolution
"imposter" mesh (colored, coarse mesh that wraps around all child parts of
the model) renders outside the streaming radius.

When set to `Enum.ModelLevelOfDetail|SLIM`, a Scalable Lightweight
Interactive Model, or SLIM, model (a composite of all child parts of the
model) renders at progressively lower resolutions at distances based on
the streaming radius. This greatly improves visual quality over
`Enum.ModelLevelOfDetail|StreamingMesh`.

When set to `Enum.ModelLevelOfDetail|Disabled` or
`Enum.ModelLevelOfDetail|Automatic`, lower resolution meshes will not be
displayed.

### `Model.ModelStreamingMode`

- **Type:** `ModelStreamingMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Controls the model streaming behavior on `Class.Model|Models` when
instance streaming is enabled.

Controls how `Class.Model|Models` are streamed in and out when instance
[streaming](../../../workspace/streaming/index.md) is enabled. Behavior
depends on the selected enum. Has no effect when streaming is not enabled.

This property should only be changed in Studio via the
[Properties](../../../studio/properties.md) window when streaming is
enabled, or in `Class.Script|Scripts`, but never in
`Class.LocalScript|LocalScripts` (doing so can result in undefined
behavior).

### `Model.PrimaryPart`

- **Type:** `BasePart`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

The primary part of the `Class.Model`, or `nil` if not explicitly set.

Points to the primary part of the `Class.Model`. The primary part is the
`Class.BasePart` that acts as the physical reference for the pivot of the
model. That is, when parts within the model are moved due to physical
simulation or other means, the pivot will move in sync with the primary
part.

Note that `Class.Model|Models` do not have `PrimaryPart` set by default.
If you are creating a model that needs to be acted upon by physics, you
should manually set this property in Studio or within a script. If the
primary part is **not** set, the pivot will remain at the same location in
world space, even if parts within the model are moved.

Also note that when setting this property, it must be a `Class.BasePart`
that is a descendant of the model. If you try to set
`Class.Model.PrimaryPart` to a `Class.BasePart` that is **not** a
descendant of the model, it will be set to that part but reset to `nil`
during the next simulation step &mdash; this is legacy behavior to support
scripts which assume they can temporarily set the primary part to a
`Class.BasePart` which isn't a descendant of the model.

The general rule for models is that:

- Models whose parts are joined together via physical joints such as
  `Class.WeldConstraint|WeldConstraints` or `Class.Motor6D|Motor6Ds`
  should have a primary part assigned. For example, Roblox character
  models have their `Class.Model.PrimaryPart` set to the
  **HumanoidRootPart** by default.
- Static (usually `Class.BasePart.Anchored|Anchored`) models which stay in
  one place unless a script explicitly moves them don't require a
  `Class.Model.PrimaryPart` and tend not to benefit from having one set.

### `Model.Scale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `NotScriptable`

Editor-only property used to scale the model around its pivot. Setting
this property will move the scale as though `Class.Model:ScaleTo()` was
called on it.

Setting this property in the Properties window will scale the model as
though `Class.Model:ScaleTo()` was called on it, scaling all descendant
Instances in the model, such as materials, images, and the 3D geometry of
parts, so that the model has the specified scale factor relative to its
original size.

This property is only available in Studio and will throw an error if used
in a `Class.Script` or `Class.LocalScript`. `Class.Model:ScaleTo()` and
`Class.Model:GetScale()` should be used from scripts.

### `Model.WorldPivot`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

Determines where the pivot of a `Class.Model` which does **not** have a
set `Class.Model.PrimaryPart` is located.

This property determines where the pivot of a `Class.Model` which does
**not** have a set `Class.Model.PrimaryPart` is located. If the
`Class.Model` **does** have a `Class.Model.PrimaryPart|PrimaryPart`, the
pivot of the `Class.Model` is equal to the pivot of that primary part
instead, and this `Class.Model.WorldPivot|WorldPivot` property is ignored.

For a newly created `Class.Model`, its pivot will be treated as the center
of the bounding box of its contents until the **first time** its
`Class.Model.WorldPivot` property is set. Once the world pivot is set for
the first time, it is impossible to restore this initial behavior.

Most commonly, moving the model with the Studio tools, or with model
movement functions such as `Class.PVInstance:PivotTo()` and
`Class.Model:MoveTo()`, will set the world pivot and thus end this new
model behavior.

The purpose of this behavior is to allow Luau code to get a sensible pivot
simply by creating a new model and parenting objects to it, avoiding the
need to explicitly set `Class.Model.WorldPivot` every time you create a
model in code.

```
local Workspace = game:GetService("Workspace")

local model = Instance.new("Model")
Workspace.BluePart.Parent = model
Workspace.RedPart.Parent = model
model.Parent = Workspace

print(model:GetPivot())  -- Currently equal to the center of the bounding box containing "BluePart" and "RedPart"

model:PivotTo(CFrame.new(0, 10, 0))  -- This works without needing to explicitly set "model.WorldPivot"
```

## Methods

### `Model:AddPersistentPlayer`

```
AddPersistentPlayer(playerInstance: Player = nil) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Sets this model to be persistent for the specified player.
`Class.Model.ModelStreamingMode|ModelStreamingMode` must be set to
`Enum.ModelStreamingMode|PersistentPerPlayer` for behavior to be changed
as a result of addition.

Sets this model to be persistent for the specified player. Persistent
models stay present for the player regardless of streaming settings or
conditions.

`Class.Model.ModelStreamingMode|ModelStreamingMode` must be set to
`Enum.ModelStreamingMode|PersistentPerPlayer` for behavior to be changed
as a result of addition.

**Parameters:**

- `playerInstance` : `Player` (default `nil`) --- The `Class.Player` to make this model persistent for.

**Returns:**

- `()` --- 

### `Model:BreakJoints`

```
BreakJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated`

Breaks connections between `BaseParts`, including surface connections with
any adjacent parts, `Class.WeldConstraint|WeldConstraints` and all
`Class.Weld|Welds` and other `Class.JointInstance|JointInstances`.

Breaks connections between `BaseParts`, including surface connections with
any adjacent parts, `Class.WeldConstraint|WeldConstraints`, and all
`Class.Weld|Welds` and other `Class.JointInstance|JointInstances`.

When BreakJoints is used on a Player character `Class.Model`, the
character's `Class.Humanoid` will die as it relies on the Neck joint.

Note that although joints produced by surface connections with adjacent
Parts can technically be recreated using `Class.Model:MakeJoints()`, this
will only recreate joints produced by surfaces. Developers should not rely
on this as following the joints being broken parts may no longer be in
contact with each other.

**Returns:**

- `()` --- 

### `Model:breakJoints`

```
breakJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This deprecated function is a variant of `Class.Model:BreakJoints()` which
should be used instead.

**Returns:**

- `()` --- 

### `Model:GetBoundingBox`

```
GetBoundingBox() -> Tuple
```

- security=`None` ; thread-safety=`Unsafe`

Returns a description of a volume that contains all parts of a Model.

This function returns a description of a volume that contains all
`Class.BasePart` children within a `Class.Model`. The volume's orientation
is based on the orientation of the `Class.Model.PrimaryPart|PrimaryPart`,
and matches the selection box rendered in Studio when the model is
selected. Mirroring the behavior of `Class.Terrain:FillBlock()`, it
returns a `Datatype.CFrame` representing the center of that bounding box
and a `Datatype.Vector3` representing its size. The size may be inaccurate
at runtime if physics constraints are acting upon the parts within the
`Class.Model`.

The orientation of the bounding box matches the orientation of the
`Class.PVInstance.GetPivot|Pivot` - either the pivot of the
`Class.Model.PrimaryPart|PrimaryPart` (if present) or the
`Class.Model.WorldPivot|WorldPivot` of the model.

```lua
local Workspace = game:GetService("Workspace")

local model = Workspace.Model
local part = Workspace.Part
local orientation, size = model:GetBoundingBox()

-- Resize and position part equal to bounding box of model
part.Size = size
part.CFrame = orientation
```

**Returns:**

- `Tuple` --- A `Datatype.CFrame` representing the orientation of the volume followed by a `Datatype.Vector3` representing the size of the volume.

### `Model:GetExtentsSize`

```
GetExtentsSize() -> Vector3
```

- security=`None` ; thread-safety=`Unsafe`

Returns the size of the smallest bounding box that contains all of the
`Class.BasePart|BaseParts` in the `Class.Model`, aligned with the
`Class.Model.PrimaryPart` if it is set.

Returns the size of the smallest bounding box that contains all of the
`Class.BasePart|BaseParts` in the `Class.Model`. The orientation matches
the orientation of the `Class.PVInstance.GetPivot|Pivot` - either the
pivot of the `Class.Model.PrimaryPart|PrimaryPart` (if present) or the
`Class.Model.WorldPivot|WorldPivot` of the model.

Note this function only returns the size of the smallest bounding box, and
the developer must employ their own method to obtain the position of the
bounding box.

**Returns:**

- `Vector3` --- The `Datatype.Vector3` extents size of the `Class.Model`.

### `Model:GetModelCFrame`

```
GetModelCFrame() -> CFrame
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This function has been deprecated as it did not provide reliable results.
You can instead use `Class.Model:GetPrimaryPartCFrame()` to retrieve the
`Datatype.CFrame` of the model's primary part.

This value historically returned the CFrame of a central position in the
model.

**Returns:**

- `CFrame` --- 

### `Model:GetModelSize`

```
GetModelSize() -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This item is deprecated. Do not use it for new work. Developers can
instead use `Class.Model.GetExtentsSize`.

Returns the Vector3 size of the Model.

The GetModelSize function returns the `Datatype.Vector3` size of the
`Class.Model`.

**Returns:**

- `Vector3` --- 

### `Model:GetPersistentPlayers`

```
GetPersistentPlayers() -> List<Player>
```

- security=`None` ; thread-safety=`Unsafe`

Returns all the `Class.Player` objects that this model object is
persistent for. Behavior varies based on whether this method is called
from a `Class.Script` or a `Class.LocalScript`.

When this method is called from a `Class.Script`, it returns all the
`Class.Player` objects that this model is persistent for. When called from
a `Class.LocalScript`, this method only checks if this model is persistent
for the `Class.Players.LocalPlayer|LocalPlayer`.

**Returns:**

- `List<Player>` --- A table with all the `Class.Player` objects that this model object is persistent for.

### `Model:GetPrimaryPartCFrame`

```
GetPrimaryPartCFrame() -> CFrame
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated`

Returns the `Datatype.CFrame` of the model's `Class.Model.PrimaryPart`.
This function will throw an error if no primary part exists for the
`Class.Model`.

This function has been superseded by `Class.PVInstance:GetPivot()` which
acts as a replacement and does not change your code's behavior. Use
`Class.PVInstance:GetPivot()` for new work and migrate your existing
`Class.Model:GetPrimaryPartCFrame()` calls when convenient.

Returns the `Datatype.CFrame` of the model's `Class.Model.PrimaryPart`.

This function is equivalent to the following.

    Model.PrimaryPart.CFrame

Note this function will throw an error if no primary part exists for the
`Class.Model`. If this behavior is not desired developers can do the
following, which will be equal to `nil` if there is no primary part.

    local cFrame = Model.PrimaryPart and Model.PrimaryPart.CFrame

**Returns:**

- `CFrame` --- 

### `Model:GetScale`

```
GetScale() -> float
```

- security=`None` ; thread-safety=`Unsafe`

Returns the canonical scale of the model, which defaults to 1 for newly
created models and will change as it is scaled via
`Class.Model:ScaleTo()`.

Models contain a persistent canonical scale factor, which starts out at 1
for newly created models and changes as the model is scaled by calling
`Class.Model:ScaleTo()`. This function returns the current canonical scale
factor of the model.

The current scale factor does not _directly_ impact the size of Instances
under the model. It is used for content authoring and scripting purposes
to remember how the model has been scaled relative to its original size.

Within a given session, the model will cache the precise original size
information of the descendant Instances after the first
`Class.Model:ScaleTo()` call. This means that calling
`Class.Model:ScaleTo()|ScaleTo(x)` followed by
`Class.Model:ScaleTo()|ScaleTo(1)` will get you back _exactly_ the
original configuration of the model with no floating point drift. Avoiding
floating point drift is the motivation for having a Scale**To** function
instead of a Scale**By** function.

The scale factor does impact engine behavior in one way: The scale factor
of a model will be applied to joint offsets of
`Class.Animation|Animations` played on an `Class.AnimationController`
under that model, so that animated rigs will correctly play back
animations even when scaled.

**Returns:**

- `float` --- The current canonical scale factor of the model.

### `Model:MakeJoints`

```
MakeJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This joint type has been deprecated. Don't use it for new work. Use
`Class.WeldConstraint|WeldConstraints` and
`Class.HingeConstraint|HingeConstraints` instead.

Goes through all `Class.BasePart|BaseParts` in the `Class.Model`. If any
part's side has a SurfaceType that can make a joint it will create a joint
with any adjacent parts.

SurfaceType based joining is deprecated. Don't use MakeJoints for new
projects. Use `Class.WeldConstraint|WeldConstraints` and
`Class.HingeConstraint|HingeConstraints` instead.

Goes through all `Class.BasePart|Parts` in the `Class.Model` and creates
joints between the specified Parts and any planar touching surfaces,
depending on the parts' surfaces.

- Smooth surfaces will not create joints
- Glue surfaces will create a `Class.Glue` joint
- Weld will create a `Class.Weld` joint with any surface except for
  Unjoinable
- Studs, Inlet, or Universal will each create a `Class.Snap` joint with
  either of other the other two surfaces (e.g. Studs with Inlet and
  Universal)
- Hinge and Motor surfaces create `Class.Rotate` and `Class.RotateV` joint
  instances

This function doesn't work if the Part is not a descendant of
`Class.Workspace`. Therefore, you must first ensure the Model is parented
to Workspace before using MakeJoints.

**Returns:**

- `()` --- 

### `Model:makeJoints`

```
makeJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This deprecated function is a variant of `Class.Model:MakeJoints()` which
should be used instead.

**Returns:**

- `()` --- 

### `Model:move`

```
move(location: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This item has been superseded by `Class.Model:MoveTo()` which should be
used in all new work

**Parameters:**

- `location` : `Vector3` --- 

**Returns:**

- `()` --- 

### `Model:MoveTo`

```
MoveTo(position: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Moves the `Class.Model.PrimaryPart|PrimaryPart` to the given position. If
a primary part has not been specified, the root part of the model will be
used.

Moves the `Class.Model.PrimaryPart|PrimaryPart` to the given position. If
a primary part has not been specified, the root part of the model will be
used, but the root part is not deterministic and it is recommended that
you always set a primary part when using `Class.Model:MoveTo()|MoveTo()`.

If there are any obstructions where the model is to be moved, such as
`Class.Terrain` or other `Class.BasePart|BaseParts`, the model will be
moved vertically upward until there is nothing in the way. If this
behavior is not desired, `Class.PVInstance:PivotTo()` should be used
instead.

Note that rotation is not preserved when moving a model with
`Class.Model:MoveTo()|MoveTo()`. It is recommended to use either
`Class.Model:TranslateBy()|TranslateBy()` or `Class.PVInstance:PivotTo()`
if the current rotation of the model needs to be preserved.

**Parameters:**

- `position` : `Vector3` --- The `Datatype.Vector3` the `Class.Model` is moved to.

**Returns:**

- `()` --- 

### `Model:moveTo`

```
moveTo(location: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This deprecated function is a variant of `Class.Model:MoveTo()` which
should be used instead.

**Parameters:**

- `location` : `Vector3` --- 

**Returns:**

- `()` --- 

### `Model:RemovePersistentPlayer`

```
RemovePersistentPlayer(playerInstance: Player = nil) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Makes this model no longer persistent for the specified player.
`Class.Model.ModelStreamingMode|ModelStreamingMode` must be set to
`Enum.ModelStreamingMode|PersistentPerPlayer` for behavior to be changed
as a result of removal.

Makes this model no longer persistent for the specified player. This does
not guarantee the model will immediately be removed for the player; after
calling this method, the model will be treated as
`Enum.ModelStreamingMode|Atomic` for that player and will remain present
as long as it is within the target streaming radius.

`Class.Model.ModelStreamingMode|ModelStreamingMode` must be set to
`Enum.ModelStreamingMode|PersistentPerPlayer` for behavior to be changed
as a result of removal.

**Parameters:**

- `playerInstance` : `Player` (default `nil`) --- The `Class.Player` to make this model no longer persistent for.

**Returns:**

- `()` --- 

### `Model:ResetOrientationToIdentity`

```
ResetOrientationToIdentity() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This function has been deprecated; it remains to prevent legacy scripts
from throwing errors, but it does nothing when called.

Resets the rotation of the model's parts to the previously set identity
rotation, which is done through the `Class.Model:SetIdentityOrientation()`
method.

**Returns:**

- `()` --- 

### `Model:ScaleTo`

```
ScaleTo(newScaleFactor: float) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Sets the scale factor of the model, adjusting the sizing and location of
all descendant Instances such that they have that scale factor relative to
their initial sizes and locations when scale factor was 1.

Models contain a persistent canonical scale factor, which starts out at 1
for newly created models. This function scales the model, around the pivot
location, relative to how it would look at a scale factor of 1. To
accomplish this it does two things:

- Sets the current scale factor of the model to the specified value
- Resizes and repositions all descendant Instances accordingly

The scaling of locations is done around the pivot location.

All "geometric" properties of descendant Instances will be scaled. That
obviously includes the sizes of parts, but here are some other examples of
properties which are scaled:

- The length of joints like `Class.WeldConstraint|WeldConstraints`, and
  `Class.RopeConstraint`
- Physical velocities and forces like `Class.HingeConstraint`
- Visual properties like sizes of particle emitters
- Other length properties like `Class.Sound.RollOffMinDistance`

**Parameters:**

- `newScaleFactor` : `float` --- 

**Returns:**

- `()` --- 

### `Model:SetIdentityOrientation`

```
SetIdentityOrientation() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This function has been deprecated; it remains to prevent legacy scripts
from throwing errors, but it does nothing when called.

Sets the identity rotation of the given model, allowing you to reset the
rotation of the entire model later, through the use of the
`ResetOrientationToIdentity` method.

**Returns:**

- `()` --- 

### `Model:SetPrimaryPartCFrame`

```
SetPrimaryPartCFrame(cframe: CFrame) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated`

Sets the `Class.BasePart.CFrame` of the model's `Class.Model.PrimaryPart`.
All other parts in the model will also be moved and will maintain their
orientation and offset respective to the `Class.Model.PrimaryPart`.

This function has been superseded by `Class.PVInstance:PivotTo()` which
acts as a more performant replacement and does not change your code's
behavior. Use `Class.PVInstance:PivotTo()` for new work and migrate your
existing `Class.Model:SetPrimaryPartCFrame()` calls when convenient.

Sets the `Class.BasePart.CFrame` of the model's `Class.Model.PrimaryPart`.
All other parts in the model will also be moved and will maintain their
orientation and offset respective to the `Class.Model.PrimaryPart`.

Note, this function will throw an error if no `Class.Model.PrimaryPart`
exists for the model. This can cause issues if, for example, the primary
part was never set or has been destroyed.

**Parameters:**

- `cframe` : `CFrame` --- The `Datatype.CFrame` to be set.

**Returns:**

- `()` --- 

### `Model:TranslateBy`

```
TranslateBy(delta: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Shifts a `Class.Model` by the given `Datatype.Vector3` offset, preserving
the model's orientation. If another `Class.BasePart` or `Class.Terrain`
already exists at the new position then the `Class.Model` will overlap
said object.

Shifts a `Class.Model` by the given `Datatype.Vector3` offset, preserving
the model's orientation. If another `Class.BasePart` or `Class.Terrain`
already exists at the new position then the `Class.Model` will overlap
said object.

The translation is applied in world space rather than object space,
meaning even if the model's parts are orientated differently it will still
move along the standard axis.

**Parameters:**

- `delta` : `Vector3` --- The `Datatype.Vector3` to translate the `Class.Model` by.

**Returns:**

- `()` --- 

## Events

_No public events documented._

## Notes / Deprecations

- Deprecated method `Model:breakJoints`: This deprecated function is a variant of `Class.Model:BreakJoints()` which
should be used instead.
- Deprecated method `Model:GetModelCFrame`: This function has been deprecated as it did not provide reliable results.
You can instead use `Class.Model:GetPrimaryPartCFrame()` to retrieve the
`Datatype.CFrame` of the model's primary part.
- Deprecated method `Model:GetModelSize`: This item is deprecated. Do not use it for new work. Developers can
instead use `Class.Model.GetExtentsSize`.
- Deprecated method `Model:MakeJoints`: This joint type has been deprecated. Don't use it for new work. Use
`Class.WeldConstraint|WeldConstraints` and
`Class.HingeConstraint|HingeConstraints` instead.
- Deprecated method `Model:makeJoints`: This deprecated function is a variant of `Class.Model:MakeJoints()` which
should be used instead.
- Deprecated method `Model:move`: This item has been superseded by `Class.Model:MoveTo()` which should be
used in all new work
- Deprecated method `Model:moveTo`: This deprecated function is a variant of `Class.Model:MoveTo()` which
should be used instead.
- Deprecated method `Model:ResetOrientationToIdentity`: This function has been deprecated; it remains to prevent legacy scripts
from throwing errors, but it does nothing when called.
- Deprecated method `Model:SetIdentityOrientation`: This function has been deprecated; it remains to prevent legacy scripts
from throwing errors, but it does nothing when called.
- Property `Model.LevelOfDetail` security: `read=PluginSecurity, write=PluginSecurity`
- Property `Model.ModelStreamingMode` security: `read=None, write=None`
- Property `Model.PrimaryPart` security: `read=None, write=None`
- Property `Model.Scale` security: `read=None, write=None`
- Property `Model.WorldPivot` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `Model-Instantiation` --- https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/Model
- Model:BreakJoints: Model-BreakJoints
- Model:BreakJoints: Manual-Joint-Creation
- Model:GetExtentsSize: Model-GetExtentsSize2
- Model:GetModelSize: Model-GetModelSize1
- Model:GetPrimaryPartCFrame: Model-GetPrimaryPartCFrame
- Model:GetScale: Model-Substitute-Using-GetScale
- Model:MakeJoints: Model-MakeJoints
- Model:MakeJoints: Simple-Joint-Creation
- Model:MoveTo: Model-MoveTo
- Model:TranslateBy: Model-TranslateBy
- Model.PrimaryPart: throwing-dice
- Model.WorldPivot: reset-pivot

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Model
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Model.yaml
- Captured: 2026-04-16
