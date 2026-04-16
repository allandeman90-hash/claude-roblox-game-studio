---
title: BasePart
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/BasePart
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/BasePart.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: core
tags: [roblox-class, core, parts, physics, base-class]
---

# BasePart

The abstract base class for in-world objects that physically interact.

## Description

`Class.BasePart` is an abstract base class for in-world objects that render
and are physically simulated while in the `Class.Workspace`. There are several
implementations of `Class.BasePart`, the most common being `Class.Part` and
`Class.MeshPart`. Others include `Class.WedgePart`, `Class.SpawnLocation`, and
the singleton `Class.Terrain` object. Generally, when documentation refers to
a "part," most `Class.BasePart` implementations will work and not just
`Class.Part`.

For information on how `Class.BasePart|BaseParts` are grouped into simulated
rigid bodies, see [Assemblies](../../../physics/assemblies.md).

There are many different objects that interact with `Class.BasePart` (other
than `Class.Terrain`), including:

- Several `Class.BasePart|BaseParts` may be grouped within a `Class.Model` and
  moved at the same time using `Class.PVInstance:PivotTo()`. See
  [Models](../../../parts/models.md).
- A `Class.Decal` applies a stretched image texture to the faces of a
  `Class.BasePart`, while a `Class.Texture` applies a tiled image texture to
  the faces. See [Textures and Decals](../../../parts/textures-decals.md).
- A `Class.SurfaceGui` renders `Class.GuiObject|GuiObjects` on the face of a
  part. See
  [In-Experience UI Containers](../../../ui/in-experience-containers.md).
- `Class.Attachment|Attachments` can be added to a `Class.BasePart` to specify
  `Datatype.CFrame|CFrames` relative to the part. These are often used by
  physical `Class.Constraint` objects as outlined in
  [Mechanical Constraints](../../../physics/mechanical-constraints.md) and
  [Mover Constraints](../../../physics/mover-constraints.md).
- `Class.ParticleEmitter` objects emit particles uniformly in the volume of
  the `Class.BasePart` to which they are parented. See
  [Particle Emitters](../../../effects/particle-emitters.md).
- Light objects like `Class.PointLight` emit light from the center of a
  `Class.BasePart` as illustrated in
  [Light Sources](../../../effects/light-sources.md).
- If parented to a `Class.Tool` and given the name **Handle**, a
  `Class.BasePart` can be held by characters. See
  [In-Experience Tools](../../../players/tools.md).

## Inheritance

Inherits from: `PVInstance`

Class tags: `NotCreatable`, `NotBrowsable`

Memory category: `Instances`

## Properties

### `BasePart.Anchored`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines whether a part is immovable by physics.

The `Anchored` property determines whether the part will be immovable by
physics. When enabled, a part will never change position due to gravity,
other part collisions, overlapping other parts, or any other
physics-related causes. As a result, two anchored parts will never fire
the `Class.BasePart.Touched|Touched` event on each other.

An anchored part may still be moved by changing its
`Class.BasePart.CFrame|CFrame` or `Class.BasePart.Position|Position`, and
it still may have a nonzero
`Class.BasePart.AssemblyLinearVelocity|AssemblyLinearVelocity` and
`Class.BasePart.AssemblyAngularVelocity|AssemblyAngularVelocity`.

Finally, if an unanchored part is joined with an anchored part through an
object like a `Class.Weld`, it too will act anchored. If such a joint
breaks, the part may be affected by physics again. See
[Assemblies](../../../physics/assemblies.md) for more details.

Network ownership cannot be set on anchored parts. If a part's anchored
status changes on the server, the network ownership of that part will be
affected.

### `BasePart.AssemblyAngularVelocity`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

The angular velocity of the part's assembly.

The angular velocity vector of this part's assembly. It's the rate of
change of orientation in radians per second.

Angular velocity is the same at every point of the assembly.

Setting the velocity directly may lead to unrealistic motion. Using
`Class.Torque` or `Class.AngularVelocity` constraint is preferred, or use
`Class.BasePart:ApplyAngularImpulse()|ApplyAngularImpulse()` if you want
instantaneous change in velocity.

If the part is [owned](../../../physics/network-ownership.md) by the
server, this property must be changed from a server `Class.Script` (not
from a `Class.LocalScript` or a `Class.Script` with
`Class.BaseScript.RunContext|RunContext` set to `Enum.RunContext.Client`).
If the part is owned by a client through **automatic** ownership, this
property can be changed from either a client script **or** a server
script; changing it from a client script for a server-owned part will have
no effect.

### `BasePart.AssemblyCenterOfMass`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

The center of mass of the part's assembly in world space.

A position calculated via the `Class.BasePart.Mass|Mass` and
`Class.BasePart.Position|Position` of all the parts in the assembly.

If the assembly has an anchored part, that part's center of mass will be
the assembly's center of mass, and the assembly will have infinite mass.

Knowing the center of mass can help the assembly maintain stability. A
force applied to the center of mass will not cause angular acceleration,
only linear. An assembly with a low center of mass will have a better time
staying upright under the effect of gravity.

### `BasePart.AssemblyLinearVelocity`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

The linear velocity of the part's assembly.

The linear velocity vector of this part's assembly. It's the rate of
change in position of
`Class.BasePart.AssemblyCenterOfMass|AssemblyCenterOfMass` in studs per
second.

If you want to know the velocity at a point other than the assembly's
center of mass, use
`Class.BasePart:GetVelocityAtPosition()|GetVelocityAtPosition()`.

Setting the velocity directly may lead to unrealistic motion. Using a
`Class.VectorForce` constraint is preferred, or use
`Class.BasePart:ApplyImpulse()|ApplyImpulse()` if you want instantaneous
change in velocity.

If the part is [owned](../../../physics/network-ownership.md) by the
server, this property must be changed from a server `Class.Script` (not
from a `Class.LocalScript` or a `Class.Script` with
`Class.BaseScript.RunContext|RunContext` set to `Enum.RunContext.Client`).
If the part is owned by a client through **automatic** ownership, this
property can be changed from either a client script **or** a server
script; changing it from a client script for a server-owned part will have
no effect.

### `BasePart.AssemblyMass`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

The total mass of the part's assembly.

The sum of the mass of all the `Class.BasePart|BaseParts` in this part's
assembly. Parts that are `Class.BasePart.Massless|Massless` and are not
the assembly's root part will not contribute to the `AssemblyMass`.

If the assembly has an anchored part, the assembly's mass is considered
infinite. Constraints and other physical interactions between unanchored
assemblies with a large difference in mass may cause instabilities.

### `BasePart.AssemblyRootPart`

- **Type:** `BasePart`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

A reference to the root part of the assembly.

This property indicates the `Class.BasePart` automatically chosen to
represent the assembly's root part. If the part is not parented to the
`Class.Workspace`, this property will be `nil`.

The root part can be changed by changing the
`Class.BasePart.RootPriority|RootPriority` of the parts in the assembly.

Parts that all share the same `AssemblyRootPart` are in the same assembly.

For more information on root parts, see
[Assemblies](../../../physics/assemblies.md).

### `BasePart.AudioCanCollide`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines whether the part will physically interact with audio
simulation, similar to `Class.BasePart.CastShadow|CastShadow` for
lighting.

`AudioCanCollide` determines whether the part will physically interact
with audio simulation, similar to `Class.BasePart.CastShadow|CastShadow`
for lighting.

When disabled, audio passes through the part; it is not occluded or
reflected.

### `BasePart.BackParamA`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the first parameter for the SurfaceType on the Back face of a
part.

The `BackParamA` property is relevant when a part's
`Class.BasePart.BackSurface` is set to Motor or SteppingMotor and
`Class.BasePart.BackSurfaceInput` is set to Sin. It determines the
**amplitude** of the motor's rotational velocity.

### `BasePart.BackParamB`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the second parameter for the SurfaceType on the Back face of a
part.

The `BackParamB` property is relevant when a part's
`Class.BasePart.BackSurface` is set to Motor or SteppingMotor and
`Class.BasePart.BackSurfaceInput` is set to Constant or Sin. For Constant,
it determines the constant rotational velocity of the motor. For Sin, it
determines the **frequency** of the motor's rotational velocity.

### `BasePart.BackSurface`

- **Type:** `SurfaceType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the type of surface for the back face of a part.

The `BackSurface` property determines the type of surface used for the
positive **Z** direction of a part. When two parts' faces are placed next
to each other, they may create a joint between them.

### `BasePart.BackSurfaceInput`

- **Type:** `InputType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the kind of input for the Back face of a part.

The `BackSurfaceInput` property determines the kind of input provided to a
part's `Class.BasePart.BackSurface`. This is only relevant for Motor or
SteppingMotor SurfaceTypes. This property determines how
`Class.BasePart.BackParamA` and `Class.BasePart.BackParamB` are used. For
brevity, these properties will be referred to as ParamA and ParamB,
respectively.

- By default, this is set to NoInput. This stops the motor altogether.
- For Constant, the motor rotates at a constant velocity equal to
  `ParamB`.
- For Sin, the motor rotates at a velocity equal to
  `ParamA * math.sin(workspace.DistributedGameTime * ParamB)`. See
  `Class.Workspace.DistributedGameTime`.

### `BasePart.BottomParamA`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the first parameter for the SurfaceType on the Bottom face of a
part.

The `BottomParamA` property is relevant when a part's
`Class.BasePart.BottomSurface` is set to Motor or SteppingMotor and
`Class.BasePart.BottomSurfaceInput` is set to Sin. It determines the
**amplitude** of the motor's rotational velocity.

### `BasePart.BottomParamB`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the second parameter for the SurfaceType on the Bottom face of
a part.

The `BottomParamB` property is relevant when a part's
`Class.BasePart.BottomSurface` is set to Motor or SteppingMotor and
`Class.BasePart.BottomSurfaceInput` is set to Constant or Sin. For
Constant, it determines the constant rotational velocity of the motor. For
Sin, it determines the **frequency** of the motor's rotational velocity.

### `BasePart.BottomSurface`

- **Type:** `SurfaceType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the type of surface for the bottom face of a part.

The `BottomSurface` property determines the type of surface used for the
negative **Y** direction of a part. When two parts' faces are placed next
to each other, they may create a joint between them.

### `BasePart.BottomSurfaceInput`

- **Type:** `InputType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the kind of input for the Bottom face of a part.

The `BottomSurfaceInput` property determines the kind of input provided to
a part's `Class.BasePart.BottomSurface`. This is only relevant for Motor
or SteppingMotor SurfaceTypes. This property determines how
`Class.BasePart.BottomParamA` and `Class.BasePart.BottomParamB` are used.
For brevity, these properties will be referred to as ParamA and ParamB,
respectively.

- By default, this is set to NoInput. This stops the motor altogether.
- For Constant, the motor rotates at a constant velocity equal to
  `ParamB`.
- For Sin, the motor rotates at a velocity equal to
  `ParamA * math.sin(workspace.DistributedGameTime * ParamB)`. See
  `Class.Workspace.DistributedGameTime`.

### `BasePart.BrickColor`

- **Type:** `BrickColor`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

Determines the color of a part.

This property determines the color of a part. If the part has a
`Class.BasePart.Material|Material`, this also determines the color used
when rendering the material texture. For more control over the color, the
`Class.BasePart.Color|Color` property can be used and this property will
use the closest `BrickColor`.

Other visual properties of a part are determined by
`Class.BasePart.Transparency|Transparency` and
`Class.BasePart.Reflectance|Reflectance`.

### `BasePart.brickColor`

- **Type:** `BrickColor`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `Deprecated`
- **Deprecated:** This deprecated property is an old Camel Case variant of the Pascal Case
`Class.BasePart.BrickColor`, which should be used instead.

### `BasePart.CanCollide`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines whether a part may collide with other parts.

`CanCollide` determines whether a part will physically interact with other
parts. When disabled, other parts can pass through the part uninterrupted.
Parts used for **decoration** usually have `CanCollide` disabled, as they
need not be considered by the physics engine.

If a part is not `Class.BasePart.Anchored|Anchored` and has `CanCollide`
disabled, it may fall out of the world to be eventually destroyed by
`Class.Workspace.FallenPartsDestroyHeight`.

When `CanCollide` is disabled, parts may still fire the
`Class.BasePart.Touched|Touched` event (as well the other parts touching
them). You can disable this with `Class.BasePart.CanTouch|CanTouch`.

For more information on collisions, see
[Collisions](../../../workspace/collisions.md).

### `BasePart.CanQuery`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines whether the part is considered during spatial query operations.

This property determines whether the part is considered during spatial
query operations, such as
`Class.WorldRoot:GetPartBoundsInBox()|GetPartBoundsInBox` or
`Class.WorldRoot:Raycast()|Raycast`. Note that
`Class.BasePart.CanCollide|CanCollide` must be disabled for `CanQuery` to
take effect, and spatial query functions will never include parts with
`CanQuery` of `false`.

Beyond this property, it is also possible to exclude parts which are
descendants of a given list of parts using an `Datatype.OverlapParams` or
`Datatype.RaycastParams` object when calling the spatial query functions.

### `BasePart.CanTouch`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines if `Class.BasePart.Touched|Touched` and
`Class.BasePart.TouchEnded|TouchEnded` events fire on the part.

This property determines if `Class.BasePart.Touched|Touched` and
`Class.BasePart.TouchEnded|TouchEnded` events fire on the part. If `true`,
other touching parts must also have `CanTouch` set to `true` for touch
events to fire. If `false`, touch events cannot be set up for the part and
attempting to do so will throw an error. Similarly, if the property is set
to `false` after a touch event is connected, the event will be
disconnected and the `Class.TouchTransmitter` removed.

Note that this collision logic can be set to respect
[collision groups](../../../workspace/collisions.md#collision-filtering)
through the `Class.Workspace.TouchesUseCollisionGroups` property. If
`true`, parts in non-colliding groups will ignore both collisions **and**
touch events, thereby making this property irrelevant.

#### Performance

There is a small performance gain on parts that have both `CanTouch` and
`Class.BasePart.CanCollide|CanCollide` set to `false`, as these parts will
never need to compute any kind of part to part collisions. However, they
can still be hit by `Class.WorldRoot:Raycast()|Raycasts` and
`Datatype.OverlapParams` queries.

### `BasePart.CastShadow`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines whether or not a part casts a shadow.

Determines whether or not a part casts a shadow. Disabling this property
for a given part can cause visual artifacts on the shadows cast upon that
part.

This property is not designed for performance enhancement, but in complex
scenes, strategically disabling it on certain parts can improve
performance. Due to the possibility of visual artifacts, we recommend
leaving it enabled on all parts in most situations.

### `BasePart.CenterOfMass`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

Describes the world position in which a part's center of mass is located.

The `CenterOfMass` property describes the **local** position of a part's
center of mass. If this is a single part assembly, this is the
`Class.BasePart.AssemblyCenterOfMass|AssemblyCenterOfMass` converted from
world space to local. On simple `Class.Part|Parts`, the center of mass is
always `(0, 0, 0)`, but it can vary for `Class.WedgePart` or
`Class.MeshPart`.

### `BasePart.CFrame`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the position and orientation of the `Class.BasePart` in the
world.

The `CFrame` property determines both the position and orientation of the
`Class.BasePart` in the world. It acts as an arbitrary reference location
on the geometry, but `Class.BasePart.ExtentsCFrame|ExtentsCFrame`
represents the actual `Datatype.CFrame` of its physical center.

When setting `CFrame` on a part, other joined parts are also moved
relative to the part, but it is recommended that you use
`Class.PVInstance:PivotTo()` to move an entire model, such as when
teleporting a player's character.

Unlike setting `Class.BasePart.Position`, setting `CFrame` will always
move the part to the exact given `Datatype.CFrame`; in other words: **no
overlap checking is done** and the physics solver will attempt to resolve
any overlap unless both parts are `Class.BasePart.Anchored|Anchored`.

For keeping track of positions relative to a part's `Datatype.CFrame`, an
`Class.Attachment` may be useful.

### `BasePart.CollisionGroup`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

Describes the name of a part's collision group.

The `CollisionGroup` property describes the name of the part's collision
group (maximum of 100 characters). Parts start off in the default group
whose name is `"Default"`. This value cannot be empty.

Although this property itself is non-replicated, the engine internally
replicates the value through another private property to solve backward
compatibility issues.

### `BasePart.CollisionGroupId`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `Deprecated`

Describes the automatically set ID number of a part's collision group.

The `Class.BasePart.CollisionGroupId` property describes the ID number of
the part's collision group. Parts start off in the `"Default"` group whose
ID is 0. If a part is unregistered, the value becomes -1. This value
cannot be less than -1 and it cannot exceed
`Class.PhysicsService:GetMaxCollisionGroups()`. Invalid IDs are clamped.

Although this property can be directly changed, it's recommended that you
specify the collision group by setting `Class.BasePart.CollisionGroup` to
the collision group's **name**.

### `BasePart.Color`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

Determines the color of a part.

The `Color` property determines the color of a part. If the part has a
`Class.BasePart.Material|Material`, this also determines the color used
when rendering the material texture.

If this property is set, `Class.BasePart.BrickColor|BrickColor` will use
the closest match to this `Color` value.

Other visual properties of a part are determined by
`Class.BasePart.Transparency|Transparency` and
`Class.BasePart.Reflectance|Reflectance`.

### `BasePart.CurrentPhysicalProperties`

- **Type:** `PhysicalProperties`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

Indicates the current physical properties of the part.

`CurrentPhysicalProperties` indicates the current physical properties of
the part. You can set custom values for the physical properties per part,
[custom material](../../../parts/materials.md), and material override. The
Roblox engine prioritizes more granular definitions when determining the
effective physical properties of a part. The values in the following list
are in order from highest to lowest priority:

- Custom physical properties of the part
- Custom physical properties of the part's custom material
- Custom physical properties of the material override of the part's
  material
- Default physical properties of the part's material

### `BasePart.CustomPhysicalProperties`

- **Type:** `PhysicalProperties`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines several physical properties of a part.

`CustomPhysicalProperties` lets you customize various physical aspects of
a part, such as its density, friction, and elasticity.

If enabled, this property let's you configure these physical properties.
If disabled, these physical properties are determined by the
`Class.BasePart.Material|Material` of the part.

### `BasePart.Elasticity`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`, `Deprecated`
- **Deprecated:** This is only one of multiple physics-related properties. It has been
deprecated in favor of `Class.BasePart.CustomPhysicalProperties`, which
combines these properties into one.

Used to control the Elasticity of the part, but it no longer does
anything.

The Elasticity of a part is now determined by either its `Enum.Material`
or its `CustomPhysicalProperties`.

### `BasePart.EnableFluidForces`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Used to enable or disable aerodynamic forces on parts and assemblies.

When `true`, and when `Class.Workspace.FluidForces` is enabled, causes the
physics engine to compute aerodynamic forces on this `Class.BasePart`.

### `BasePart.ExtentsCFrame`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

The `Datatype.CFrame` of the physical extents of the `Class.BasePart`.

The `Datatype.CFrame` of the physical extents of the `Class.BasePart`,
representing its physical center.

### `BasePart.ExtentsSize`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

The actual physical size of the `Class.BasePart` as regarded by the
physics engine.

The actual physical size of the `Class.BasePart` as regarded by the
physics engine, for example in
[collision detection](../../../workspace/collisions.md).

### `BasePart.Friction`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`, `Deprecated`
- **Deprecated:** This is only one of multiple physics-related properties. It has been
deprecated in favor of `Class.BasePart.CustomPhysicalProperties`, which
combines these properties into one.

Used to control the Friction of the part, but now it no longer does
anything.

Used to control the Friction of the part, but now it no longer does
anything. The Friction of a part is now determined by either its
`Class.BasePart.Material|Material` or its
`Class.BasePart.CustomPhysicalProperties|CustomPhysicalProperties`.

### `BasePart.FrontParamA`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the first parameter for the SurfaceType on the Front face of a
part.

The `FrontParamA` property is relevant when a part's
`Class.BasePart.FrontSurface` is set to Motor or SteppingMotor and
`Class.BasePart.FrontSurfaceInput` is set to Sin. It determines the
**amplitude** of the motor's rotational velocity.

### `BasePart.FrontParamB`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the second parameter for the SurfaceType on the Front face of a
part.

The `FrontParamB` property is relevant when a part's
`Class.BasePart.FrontSurface` is set to Motor or SteppingMotor and
`Class.BasePart.FrontSurfaceInput` is set to Constant or Sin. For
Constant, it determines the constant rotational velocity of the motor. For
Sin, it determines the **frequency** of the motor's rotational velocity.

### `BasePart.FrontSurface`

- **Type:** `SurfaceType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the type of surface for the front face of a part.

The `FrontSurface` property determines the type of surface used for the
negative **Z** direction of a part. When two parts' faces are placed next
to each other, they may create a joint between them.

### `BasePart.FrontSurfaceInput`

- **Type:** `InputType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the kind of input for the Front face of a part (-Z direction).

The `FrontSurfaceInput` property determines the kind of input provided to
a part's `Class.BasePart.FrontSurface`. This is only relevant for Motor or
SteppingMotor SurfaceTypes. This property determines how
`Class.BasePart.FrontParamA` and `Class.BasePart.FrontParamB` are used.
For brevity, these properties will be referred to as ParamA and ParamB,
respectively.

- By default, this is set to NoInput. This stops the motor altogether.
- For Constant, the motor rotates at a constant velocity equal to
  `ParamB`.
- For Sin, the motor rotates at a velocity equal to
  `ParamA * math.sin(workspace.DistributedGameTime * ParamB)`. See
  `Class.Workspace.DistributedGameTime`.

### `BasePart.LeftParamA`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the first parameter for the SurfaceType on the Left face of a
part.

The `LeftParamA` property is relevant when a part's
`Class.BasePart.LeftSurface` is set to Motor or SteppingMotor and
`Class.BasePart.LeftSurfaceInput` is set to Sin. It determines the
**amplitude** of the motor's rotational velocity.

### `BasePart.LeftParamB`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the second parameter for the SurfaceType on the Left face of a
part.

The LeftParamB property is relevant when a part's
`Class.BasePart.LeftSurface` is set to Motor or SteppingMotor and
`Class.BasePart.LeftSurfaceInput` is set to Constant or Sin. For Constant,
it determines the constant rotational velocity of the motor. For Sin, it
determines the **frequency** of the motor's rotational velocity.

### `BasePart.LeftSurface`

- **Type:** `SurfaceType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the type of surface for the left face of a part.

The `LeftSurface` property determines the type of surface used for the
negative **X** direction of a part. When two parts' faces are placed next
to each other, they may create a joint between them.

### `BasePart.LeftSurfaceInput`

- **Type:** `InputType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the kind of input for the Left face of a part.

The `LeftSurfaceInput` property determines the kind of input provided to a
part's `Class.BasePart.LeftSurface`. This is only relevant for Motor or
SteppingMotor SurfaceTypes. This property determines how
`Class.BasePart.LeftParamA` and `Class.BasePart.LeftParamB` are used. For
brevity, these properties will be referred to as ParamA and ParamB,
respectively.

- By default, this is set to NoInput. This stops the motor altogether.
- For Constant, the motor rotates at a constant velocity equal to
  `ParamB`.
- For Sin, the motor rotates at a velocity equal to
  `ParamA * math.sin(workspace.DistributedGameTime * ParamB)`. See
  `Class.Workspace.DistributedGameTime`.

### `BasePart.LocalTransparencyModifier`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`

Determines a multiplier for `Class.BasePart.Transparency` that is only
visible to the local client.

The `LocalTransparencyModifier` property is a multiplier to
`Class.BasePart.Transparency|Transparency` that is only visible to the
local client. It does not replicate from client to server and is useful
for when a part should not render for a specific client, such as how the
player does not see their character's body parts when they zoom into first
person mode.

This property modifies the local part's transparency through the following
formula, with resulting values clamped between `0` and `1`.

`1` - ((`1` - `Class.BasePart.Transparency|Transparency`) &times; (`1` -
`LocalTransparencyModifier`))

<table size="small">
<thead>
<tr>
  <th><code>Class.BasePart.Transparency|Transparency</code></th>
  <th><code>LocalTransparencyModifier</code></th>
  <th>Server-Side</th>
  <th>Client-Side</th>
</tr>
</thead>
<tbody>
  <tr>
    <td><code>0.5</code></td>
    <td><code>0</code></td>
    <td><code>0.5</code></td>
    <td><code>0.5</code></td>
  </tr>
  <tr>
    <td><code>0.5</code></td>
    <td><code>0.25</code></td>
    <td><code>0.5</code></td>
    <td><code>0.625</code></td>
  </tr>
  <tr>
    <td><code>0.5</code></td>
    <td><code>0.5</code></td>
    <td><code>0.5</code></td>
    <td><code>0.75</code></td>
  </tr>
  <tr>
    <td><code>0.5</code></td>
    <td><code>0.75</code></td>
    <td><code>0.5</code></td>
    <td><code>0.875</code></td>
  </tr>
  <tr>
    <td><code>0.5</code></td>
    <td><code>1</code></td>
    <td><code>0.5</code></td>
    <td><code>1</code></td>
  </tr>
</tbody>
</table>

### `BasePart.Locked`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines whether a part is selectable in Studio.

The `Locked` property determines whether a part (or a `Class.Model` it is
contained within) may be selected in Studio by clicking on it. This
property is most often enabled on parts within environment models that
aren't being edited at the moment.

### `BasePart.Mass`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

Describes the mass of the part, the product of its density and volume.

`Mass` is a read-only property that describes the product of a part's
volume and density. It is returned by the
`Class.BasePart:GetMass()|GetMass()` function.

- The volume of a part is determined by its `Class.BasePart.Size|Size` and
  its `Class.Part.Shape|Shape`, which varies depending on the kind of
  `Class.BasePart` used, such as `Class.WedgePart`.
- The density of a part is determined by its
  `Class.BasePart.Material|Material` or
  `Class.BasePart.CustomPhysicalProperties|CustomPhysicalProperties`, if
  specified.

### `BasePart.Massless`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines whether the part contributes to the total mass or inertia of
its rigid body.

If this property is enabled, the part will not contribute to the total
mass or inertia of its assembly as long as it is welded to another part
that has mass.

If the part is its own root part according to
`Class.BasePart.AssemblyRootPart|AssemblyRootPart`, this will be ignored
for that part, and it will still contribute mass and inertia to its
assembly like a normal part. Parts that are massless should never become
an assembly root part unless all other parts in the assembly are also
massless.

This might be useful for things like optional accessories on vehicles that
you don't want to affect the handling of the car or a massless render mesh
welded to a simpler collision mesh.

See also [Assemblies](../../../physics/assemblies.md), an article
documenting what root parts are and how to use them.

### `BasePart.Material`

- **Type:** `Material`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the texture and default physical properties of a part.

The `Material` property allows you to set a part's texture and default
physical properties (in the case that
`Class.BasePart.CustomPhysicalProperties|CustomPhysicalProperties` is
unset). The default `Enum.Material|Plastic` material has a very light
texture, while the `Enum.Material|SmoothPlastic` material has no texture
at all. Some material textures like `Enum.Material|DiamondPlate` and
`Enum.Material|Granite` have very visible textures. Each material's
texture reflects sunlight differently, especially `Enum.Material|Foil`.

Setting this property then enabling
`Class.BasePart.CustomPhysicalProperties|CustomPhysicalProperties` will
use the default physical properties of a material. For instance,
`Enum.Material|DiamondPlate` is a very dense material while
`Enum.Material|Wood` is very light. A part's density determines whether it
will float in terrain water.

The `Enum.Material|Glass` material changes rendering behavior on moderate
graphics settings by applying a bit of reflectiveness (similar to
`Class.BasePart.Reflectance|Reflectance`) and perspective distortion. The
effect is especially pronounced on sphere-shaped parts. Semi‑transparent
parts behind `Enum.Material|Glass` parts are not visible.

### `BasePart.MaterialVariant`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

The name of `Class.MaterialVariant`.

The system searches the `Class.MaterialVariant` instance with the
specified `MaterialVariant` name and `Class.BasePart.Material|Material`
type. If it successfully finds a matching `Class.MaterialVariant`
instance, it uses that instance to replace the default material. The
default material can be the built-in material or an override
`Class.MaterialVariant` specified in `Class.MaterialService`.

### `BasePart.Orientation`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`

Describes the rotation of the part in the world.

The `Orientation` property describes the part's rotation in degrees around
the **X**, **Y**, and **Z** axes using a `Datatype.Vector3`. The rotations
are applied in **Y**&nbsp;⟩&nbsp;**X**&nbsp;⟩&nbsp;**Z** order. This
differs from proper [Euler][1] angles and is instead [Tait-Bryan][2]
angles which describe **yaw**, **pitch**, and **roll**.

It is also worth noting how this property differs from the
`Datatype.CFrame.Angles()` constructor which applies rotations in a
different order (**Z**&nbsp;⟩&nbsp;**Y**&nbsp;⟩&nbsp;**X**). For better
control over the rotation of a part, it's recommended that
`Class.BasePart.CFrame|CFrame` is set instead.

[1]: https://en.wikipedia.org/wiki/Euler_angles
[2]: https://en.wikipedia.org/wiki/Euler_angles#Tait-Bryan_angles

When setting this property, any `Class.Weld|Welds` or
`Class.Motor6D|Motor6Ds` connected to this part will have the matching
`Class.JointInstance.C0|C0` or `Class.JointInstance.C1|C1` property
updated to allow the part to move relative to any other parts it is joined
to. `Class.WeldConstraint|WeldConstraints` will also be temporarily
disabled and re-enabled during the move.

### `BasePart.PivotOffset`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Specifies the offset of the part's pivot from its `Datatype.CFrame`.

This property specifies the offset of the part's pivot from its
`Datatype.CFrame`, that is `Class.BasePart:GetPivot()` is the same as
`Class.BasePart.CFrame` multiplied by `Class.BasePart.PivotOffset`.

This is convenient for setting the pivot to a location in **local** space,
but setting a part's pivot to a location in **world** space can be done as
follows:

```
local Workspace = game:GetService("Workspace")

local part = Workspace.BluePart
local desiredPivotCFrameInWorldSpace = CFrame.new(0, 10, 0)
part.PivotOffset = part.CFrame:ToObjectSpace(desiredPivotCFrameInWorldSpace)
```

### `BasePart.Position`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`

Describes the position of the part in the world.

The `Position` property describes the coordinates of a part using a
`Datatype.Vector3`. It reflects the position of the part's
`Class.BasePart.CFrame|CFrame`, however it can also be set.

When setting this property, any `Class.Weld|Welds` or
`Class.Motor6D|Motor6Ds` connected to this part will have the matching
`Class.JointInstance.C0|C0` or `Class.JointInstance.C1|C1` property
updated to allow the part to move relative to any other parts it is joined
to. `Class.WeldConstraint|WeldConstraints` will also be temporarily
disabled and re-enabled during the move.

### `BasePart.ReceiveAge`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`

Time since last recorded physics update.

Indicates the time in seconds since the part's physics were last updated
on the local client or the server. This value will be `0` when the part
has no physics (`Class.BasePart.Anchored|Anchored` is `true`).

### `BasePart.Reflectance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines how much a part reflects the skybox.

The `Reflectance` property determines how much a part reflects the sky. A
value of `0` indicates the part is not reflective at all, and a value of
`1` indicates the part should fully reflect.

Reflectance is not affected by `Class.BasePart.Transparency|Transparency`
unless the part is fully transparent, in which case reflectance will not
render at all. Reflectance may or may not be ignored depending on the
`Class.BasePart.Material|Material` of the part.

### `BasePart.ResizeableFaces`

- **Type:** `Faces`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

Describes the faces on which a part may be resized.

The `ResizeableFaces` property uses a `Datatype.Faces` object to describe
the different faces on which a part may be resized. For most
implementations of `Class.BasePart`, such as `Class.Part` and
`Class.WedgePart`, this property includes all faces. However,
`Class.TrussPart` will set its `ResizeableFaces` set to only two faces
since those kinds of parts must have two `Class.BasePart.Size|Size`
dimensions of length `2`.

This property is most commonly used with tools for building and
manipulating parts and has little use outside of that context. The
`Class.Handles` class, which has the `Class.Handles.Faces` property, can
be used in conjunction with this property to display only the handles on
faces that can be resized on a part.

### `BasePart.ResizeIncrement`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

Describes the smallest change in size allowable by the
`Class.BasePart:Resize()|Resize()` method.

The `ResizeIncrement` property is a read-only property that describes the
smallest change in size allowable by the
`Class.BasePart:Resize()|Resize()` method. It differs between
implementations of the `Class.BasePart` abstract class; for instance,
`Class.Part` has this set to `1` while `Class.TrussPart` has this set to
`2` since individual truss sections are 2&times;2&times;2 in size.

### `BasePart.RightParamA`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the first parameter for the SurfaceType on the Right face of a
part.

The `RightParamA` property is relevant when a part's
`Class.BasePart.RightSurface` is set to Motor or SteppingMotor and
`Class.BasePart.RightSurfaceInput` is set to Sin. It determines the
**amplitude** of the motor's rotational velocity.

### `BasePart.RightParamB`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the second parameter for the SurfaceType on the Right face of a
part.

The `RightParamB` property is relevant when a part's
`Class.BasePart.RightSurface` is set to Motor or SteppingMotor and
`Class.BasePart.RightSurfaceInput` is set to Constant or Sin. For
Constant, it determines the constant rotational velocity of the motor. For
Sin, it determines the **frequency** of the motor's rotational velocity.

### `BasePart.RightSurface`

- **Type:** `SurfaceType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the type of surface for the right face of a part.

The `RightSurface` property determines the type of surface used for the
positive **X** direction of a part. When two parts' faces are placed next
to each other, they may create a joint between them.

### `BasePart.RightSurfaceInput`

- **Type:** `InputType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the kind of input for the Right face of a part (-X direction).

The RightSurfaceInput property determines the kind of input provided to a

- For Sin, the motor rotates at a velocity equal to
  `ParamA * math.sin(workspace.DistributedGameTime * ParamB)`. See
  `Class.Workspace.DistributedGameTime`.

### `BasePart.RootPriority`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

The main rule in determining the root part of an assembly.

This property is an integer between `-127` and `127` that takes precedence
over all other rules for root part sort. When considering multiple parts
that are not `Class.BasePart.Anchored|Anchored` and which share the same
`Class.BasePart.Massless|Massless` value, a part with a higher
`RootPriority` will take priority over those with lower `RootPriority`.

You can use this property to control which part of an assembly is the root
part and keep the root part stable if size changes.

See also [Assemblies](../../../physics/assemblies.md), an article
documenting what root parts are and how to use them.

### `BasePart.Rotation`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

The rotation of the part in degrees for the three axes.

The rotation of the part in degrees for the three axes.

When setting this property, any `Class.Weld|Welds` or
`Class.Motor6D|Motor6Ds` connected to this part will have the matching
`Class.JointInstance.C0|C0` or `Class.JointInstance.C1|C1` property
updated to allow the part to move relative to any other parts it is joined
to. `Class.WeldConstraint|WeldConstraints` will also be temporarily
disabled and re-enabled during the move.

### `BasePart.RotVelocity`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`
- **Deprecated:** This property is deprecated. Use `AssemblyAngularVelocity` instead.

Determines a part's change in orientation over time.

The `RotVelocity` of a `Class.BasePart|part` describes how its
`Class.BasePart.Orientation` is presently changing. In other words, this
property describes how the fast part is rotating. The part only rotates if
it is not anchored.

The unit of this property is **radians per second**.

Using this in conjunction with `Class.AlignOrientation` allows for aligned
parts to have matching RotVelocity and Orientation values.

### `BasePart.Size`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

Determines the dimensions of a part (length, width, height).

A part's `Size` property determines its **visual** dimensions, while
`Class.BasePart.ExtentsSize|ExtentsSize` represents the actual size used
by the physics engine, such as in
[collision detection](../../../workspace/collisions.md). The individual
dimensions (length, width, height) can be as low as `0.001` and as high as
`2048`. Size dimensions below `0.05` will be **visually** represented as
if the part's dimensions are `0.05`.

A part's `Size` is used in a variety of additional ways:

- To influence its mass as given by `Class.BasePart:GetMass()|GetMass()`.
- By `Class.ParticleEmitter` to determine the area from which particles
  are spawned.
- By `Class.BlockMesh` to partially determine the rendered rectangular
  prism.
- By `Class.SpecialMesh` for certain
  `Class.SpecialMesh.MeshType|MeshTypes` to determine the size of the
  rendered mesh.
- By `Class.SurfaceLight` to determine the space to illuminate.

### `BasePart.SpecificGravity`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `Deprecated`
- **Deprecated:** This item is deprecated. See `Class.BasePart.CustomPhysicalProperties` to
see how to configure the physical properties of BaseParts. Do not use it
for new work.

The ratio of the part's density to the density of water determined by the
`Class.BasePart.Material`.

The ratio of the part's density to the density of water determined by the
`Class.BasePart.Material`. Effects the part's behavior when in a water
terrain cell. Essentially, SpecificGravity refers to how many times more
dense a part is than water.

<table>
	<thead>
		<tr>
			<th>Material</th>
			<th>SpecificGravity</th>
		</tr>
		<tr>
			<td>Plastic</td>
			<td>0.7</td>
		</tr>
		<tr>
			<td>Wood</td>
			<td>0.35</td>
		</tr>
		<tr>
			<td>Slate</td>
			<td>2.7</td>
		</tr>
		<tr>
			<td>Concrete</td>
			<td>2.4</td>
		</tr>
		<tr>
			<td>CorrodedMetal</td>
			<td>7.85</td>
		</tr>
		<tr>
			<td>DiamondMetal</td>
			<td>7.85</td>
		</tr>
		<tr>
			<td>Foil</td>
			<td>7.6</td>
		</tr>
		<tr>
			<td>Grass</td>
			<td>0.9</td>
		</tr>
		<tr>
			<td>Ice</td>
			<td>0.91</td>
		</tr>
		<tr>
			<td>Marble</td>
			<td>2.56</td>
		</tr>
		<tr>
			<td>Granite</td>
			<td>2.7</td>
		</tr>
		<tr>
			<td>Brick</td>
			<td>1.92</td>
		</tr>
		<tr>
			<td>Pebble</td>
			<td>2.4</td>
		</tr>
		<tr>
			<td>Sand</td>
			<td>1.6</td>
		</tr>
		<tr>
			<td>Fabric</td>
			<td>0.7</td>
		</tr>
		<tr>
			<td>SmoothPlastic</td>
			<td>0.7</td>
		</tr>
		<tr>
			<td>Metal</td>
			<td>7.85</td>
		</tr>
		<tr>
			<td>WoodPlanks</td>
			<td>0.35</td>
		</tr>
		<tr>
			<td>Cobblestone</td>
			<td>2.7</td>
		</tr>
	</thead>
</table>

### `BasePart.TopParamA`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the first parameter for the SurfaceType on the Top face of a
part.

The TopParamA property is relevant when a part's
`Class.BasePart.TopSurface` is set to Motor or SteppingMotor and
`Class.BasePart.TopSurfaceInput` is set to Sin. It determines the
**amplitude** of the motor's rotational velocity.

### `BasePart.TopParamB`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the second parameter for the SurfaceType on the Top face of a
part.

The TopParamB property is relevant when a part's
`Class.BasePart.TopSurface` is set to Motor or SteppingMotor and
`Class.BasePart.TopSurfaceInput` is set to Constant or Sin. For Constant,
it determines the constant rotational velocity of the motor. For Sin, it
determines the **frequency** of the motor's rotational velocity.

### `BasePart.TopSurface`

- **Type:** `SurfaceType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines the type of surface for the top face of a part.

The `TopSurface` property determines the type of surface used for the
positive **Y** direction of a part. When two parts' faces are placed next
to each other, they may create a joint between them.

### `BasePart.TopSurfaceInput`

- **Type:** `InputType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`

Determines the kind of input for the Top face of a part (+Y direction).

The `TopSurfaceInput` property determines the kind of input provided to a
part's `Class.BasePart.TopSurface`. This is only relevant for Motor or
SteppingMotor SurfaceTypes. This property determines how
`Class.BasePart.TopParamA` and `Class.BasePart.TopParamB` are used. For
brevity, these properties will be referred to as ParamA and ParamB,
respectively.

- By default, this is set to NoInput. This stops the motor altogether,
- For Constant, the motor rotates at a constant velocity equal to
  `ParamB`.
- For Sin, the motor rotates at a velocity equal to
  `ParamA * math.sin(workspace.DistributedGameTime * ParamB)`. See
  `Class.Workspace.DistributedGameTime`.

### `BasePart.Transparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`

Determines how much a part can be seen through (the inverse of part
opacity).

The `Transparency` property controls the visibility of a part on a scale
of `0` to `1` where `0` is completely visible (opaque) and `1` is
completely invisible (not rendered at all).

While fully transparent parts are not rendered at all, partially
transparent objects have some significant rendering costs. Having many
translucent parts may impact performance.

When transparent parts overlap, render order may act unpredictably, so you
should avoid semi-transparent parts from overlapping.

See also
`Class.BasePart.LocalTransparencyModifier|LocalTransparencyModifier` as a
multiplier to `Transparency` that's only visible to the local client.

### `BasePart.Velocity`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `Deprecated`
- **Deprecated:** This property is deprecated. Use `AssemblyLinearVelocity` instead.

Determines a part's change in position over time.

The Velocity of a part describes how its `Class.BasePart.Position` is
presently changing. The unit of this property is **studs per second**. For
reference, the default Roblox character moves at 16 studs per second via
`Class.Humanoid.WalkSpeed`. The acceleration due to gravity is found in
`Class.Workspace.Gravity` (by default, -196.2 studs per second per
second).

Setting the Velocity of a part that is `Class.BasePart.Anchored` will
cause it to act like a conveyor belt. Any object that touches the part
will begin to move in accordance with the Velocity.

Some `Class.BodyMover` objects will apply forces and thus change the
Velocity of a part over time. The simplest of these is a `Class.BodyForce`
which can be used to counteract the acceleration due to gravity on a
single part (set the +Y axis of the `Class.BodyForce.Force` to the product
of the mass (`Class.BasePart:GetMass()`) and the gravity constant).

## Methods

### `BasePart:AngularAccelerationToTorque`

```
AngularAccelerationToTorque(angAcceleration: Vector3, angVelocity: Vector3 = 0, 0, 0) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe`

**Parameters:**

- `angAcceleration` : `Vector3` --- 
- `angVelocity` : `Vector3` (default `0, 0, 0`) --- 

**Returns:**

- `Vector3` --- 

### `BasePart:ApplyAngularImpulse`

```
ApplyAngularImpulse(impulse: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Apply an angular impulse to the assembly.

Applies an instant angular force impulse to this part's assembly, causing
the assembly to spin.

The resulting angular velocity from the impulse relies on the assembly's
`Class.BasePart.AssemblyMass|mass`. So a higher impulse is required to
move more massive assemblies. Impulses are useful for cases where you want
a force applied instantly, such as an explosion or collision.

If the part is [owned](../../../physics/network-ownership.md) by the
server, this function must be called from a server `Class.Script` (not
from a `Class.LocalScript` or a `Class.Script` with
`Class.BaseScript.RunContext|RunContext` set to `Enum.RunContext.Client`).
If the part is owned by a client through **automatic** ownership, this
function can be called from either a client script **or** a server script;
calling it from a client script for a server-owned part will have no
effect.

**Parameters:**

- `impulse` : `Vector3` --- An angular impulse vector to be applied to the assembly.

**Returns:**

- `()` --- 

### `BasePart:ApplyImpulse`

```
ApplyImpulse(impulse: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Apply an impulse to the assembly at the assembly's
`Class.BasePart.AssemblyCenterOfMass|center of mass`.

This function applies an instant force impulse to this part's assembly.

The force is applied at the assembly's
`Class.BasePart.AssemblyCenterOfMass|center of mass`, so the resulting
movement will only be linear.

The resulting velocity from the impulse relies on the assembly's
`Class.BasePart.AssemblyMass|mass`. So a higher impulse is required to
move more massive assemblies. Impulses are useful for cases where you want
a force applied instantly, such as an explosion or collision.

If the part is [owned](../../../physics/network-ownership.md) by the
server, this function must be called from a server `Class.Script` (not
from a `Class.LocalScript` or a `Class.Script` with
`Class.BaseScript.RunContext|RunContext` set to `Enum.RunContext.Client`).
If the part is owned by a client through **automatic** ownership, this
function can be called from either a client script **or** a server script;
calling it from a client script for a server-owned part will have no
effect.

**Parameters:**

- `impulse` : `Vector3` --- A linear impulse vector to be applied to the assembly.

**Returns:**

- `()` --- 

### `BasePart:ApplyImpulseAtPosition`

```
ApplyImpulseAtPosition(impulse: Vector3, position: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Apply an impulse to the assembly at specified position.

This function applies an instant force impulse to this part's assembly, at
the specified position in world space.

If the position is not at the assembly's
`Class.BasePart.AssemblyCenterOfMass|center of mass`, the impulse will
cause a positional and rotational movement.

The resulting velocity from the impulse relies on the assembly's
`Class.BasePart.AssemblyMass|mass`. So a higher impulse is required to
move more massive assemblies. Impulses are useful for cases where
developers want a force applied instantly, such as an explosion or
collision.

If the part is [owned](../../../physics/network-ownership.md) by the
server, this function must be called from a server `Class.Script` (not
from a `Class.LocalScript` or a `Class.Script` with
`Class.BaseScript.RunContext|RunContext` set to `Enum.RunContext.Client`).
If the part is owned by a client through **automatic** ownership, this
function can be called from either a client script **or** a server script;
calling it from a client script for a server-owned part will have no
effect.

**Parameters:**

- `impulse` : `Vector3` --- An impulse vector to be applied to the assembly.
- `position` : `Vector3` --- The position, in world space, to apply the impulse.

**Returns:**

- `()` --- 

### `BasePart:BreakJoints`

```
BreakJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated`

Breaks any surface connection with any adjacent part, including
`Class.Weld` and other `Class.JointInstance`.

**Returns:**

- `()` --- 

### `BasePart:breakJoints`

```
breakJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This deprecated function is a variant of `Class.BasePart:BreakJoints()`
which should be used instead.

**Returns:**

- `()` --- 

### `BasePart:CanCollideWith`

```
CanCollideWith(part: BasePart) -> boolean
```

- security=`None` ; thread-safety=`Safe`

Returns whether the parts can collide with each other.

Returns whether the parts can collide with each other or not. This
function takes into account the collision groups of the two parts. This
function will error if the specified part is not a BasePart.

**Parameters:**

- `part` : `BasePart` --- The specified part being checked for collidability.

**Returns:**

- `boolean` --- Whether the parts can collide with each other.

### `BasePart:CanSetNetworkOwnership`

```
CanSetNetworkOwnership() -> Tuple
```

- security=`None` ; thread-safety=`Unsafe`

Checks whether you can set a part's network ownership.

The CanSetNetworkOwnership function checks whether you can set a part's
network ownership.

The function's return value verifies whether or not you can call
`Class.BasePart:SetNetworkOwner()` or
`Class.BasePart:SetNetworkOwnershipAuto()` without encountering an error.
It returns true if you can modify/read the network ownership, or returns
false and the reason you can't, as a string.

**Returns:**

- `Tuple` --- Whether you can modify or read the network ownership and the reason.

### `BasePart:GetClosestPointOnSurface`

```
GetClosestPointOnSurface(position: Vector3) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe`

**Parameters:**

- `position` : `Vector3` --- 

**Returns:**

- `Vector3` --- 

### `BasePart:GetConnectedParts`

```
GetConnectedParts(recursive: boolean = False) -> List<BasePart>
```

- security=`None` ; thread-safety=`Safe`

Returns a table of parts connected to the object by any kind of rigid
joint.

Returns a table of parts connected to the object by any kind of rigid
joint.

If `recursive` is true this function will return all of the parts in the
assembly rigidly connected to the BasePart.

#### Rigid Joints

When a joint connects two parts together `(Part0 → Part1)`, a joint is
**rigid** if the physics of `Part1` are completely locked down by `Part0`.
This only applies to the following joint types:

- `Class.Weld`
- `Class.Snap`
- `Class.ManualWeld`
- `Class.Motor`
- `Class.Motor6D`
- `Class.WeldConstraint`

**Parameters:**

- `recursive` : `boolean` (default `False`) --- A table of parts connected to the object by any kind of `Class.JointInstance|joint`.

**Returns:**

- `List<BasePart>` --- 

### `BasePart:GetJoints`

```
GetJoints() -> Instances
```

- security=`None` ; thread-safety=`Safe`

Return all Joints or Constraints that is connected to this Part.

**Returns:**

- `Instances` --- An array of all Joints or Constraints connected to the Part.

### `BasePart:GetMass`

```
GetMass() -> float
```

- security=`None` ; thread-safety=`Safe`

Returns the value of the `Class.BasePart.Mass|Mass` property.

**GetMass** returns the value of the read-only `Class.BasePart.Mass|Mass`
property.

This function predates the Mass property. It remains supported for
backward-compatibility; you should use the Mass property directly.

**Returns:**

- `float` --- The part's mass.

### `BasePart:getMass`

```
getMass() -> float
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This Camel Case property has been deprecated in favor of its Pascal Case
variant, `Class.BasePart:GetMass()`.

**Returns:**

- `float` --- 

### `BasePart:GetNetworkOwner`

```
GetNetworkOwner() -> Instance
```

- security=`None` ; thread-safety=`Safe`

Returns the current player who is the network owner of this part, or `nil`
in case of the server.

**Returns:**

- `Instance` --- The current player who is the network owner of this part, or `nil` in case of the server.

### `BasePart:GetNetworkOwnershipAuto`

```
GetNetworkOwnershipAuto() -> boolean
```

- security=`None` ; thread-safety=`Safe`

Returns true if the game engine automatically decides the network owner
for this part.

**Returns:**

- `boolean` --- Whether the game engine automatically decides the network owner for this part.

### `BasePart:GetNoCollisionConstraints`

```
GetNoCollisionConstraints() -> Instances
```

- security=`None` ; thread-safety=`Unsafe`

**Returns:**

- `Instances` --- 

### `BasePart:GetRenderCFrame`

```
GetRenderCFrame() -> CFrame
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This item is been deprecated since interpolation is now applied to the
`Datatype.CFrame` directly. Do not use it for new work.

OBSOLETE. Returns a CFrame describing where the part is being rendered at.

This function used to be relevant when Roblox's lag-compensating
interpolation of parts online was internal. The interpolation is now
applied to the `Datatype.CFrame` directly.

**Returns:**

- `CFrame` --- 

### `BasePart:GetRootPart`

```
GetRootPart() -> Instance
```

- security=`None` ; thread-safety=`Safe` ; tags=`Deprecated`

Returns the base part of an assembly of parts.

Returns the base part of an assembly. When moving an assembly of parts
using a `Datatype.CFrame`. it is important to move this base part (this
will move all other parts connected to it accordingly). More information
is available in the [Assemblies](../../../physics/assemblies.md) article.

This function predates the
`Class.BasePart.AssemblyRootPart|AssemblyRootPart` property. It remains
supported for backwards compatibility, but you should use
`Class.BasePart.AssemblyRootPart|AssemblyRootPart` directly.

**Returns:**

- `Instance` --- The base part of an assembly (a collection of parts connected together).

### `BasePart:GetTouchingParts`

```
GetTouchingParts() -> Instances
```

- security=`None` ; thread-safety=`Unsafe`

Returns a table of all `Class.BasePart.CanCollide` true parts that
intersect with this part.

Returns a table of all parts that are physically interacting with this
part. If the part itself has CanCollide set to false, then this function
returns an empty table unless the part has a
`Class.TouchTransmitter|TouchInterest` object parented to it (meaning
something is connected to its Touched event). Parts that are adjacent but
not intersecting are not considered touching. This function predates the
`Class.WorldRoot:GetPartsInPart()` function, which provides more
flexibility and avoids the special `Class.TouchTransmitter|TouchInterest`
rules described above. Use `Class.WorldRoot:GetPartsInPart()` instead.

**Returns:**

- `Instances` --- A table of all parts that intersect and can collide with this part.

### `BasePart:GetVelocityAtPosition`

```
GetVelocityAtPosition(position: Vector3) -> Vector3
```

- security=`None` ; thread-safety=`Safe`

Returns the linear velocity of the part's assembly at the given position
relative to this part.

Returns the linear velocity of the part's assembly at the given position
relative to this part. It can be used to identify the linear velocity of
parts in an assembly other than the root part. If the assembly has no
angular velocity, than the linear velocity will always be the same for
every position.

**Parameters:**

- `position` : `Vector3` --- 

**Returns:**

- `Vector3` --- 

### `BasePart:IntersectAsync`

```
IntersectAsync(parts: Instances, collisionfidelity: CollisionFidelity = Default, renderFidelity: RenderFidelity = Automatic) -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`CSG`

Note: It is highly recommended to use the newer
`Class.GeometryService:IntersectAsync` instead of this function. As well
as having better performance and more features, the new function differs
as follows:

- The output is an array of instances rather than a single instance.
- The input parts do not need to be parented to the scene, allowing for
  background operations.
- When the `SplitApart` option is set to `true` (default), each distinct
  body will be returned in its own `Class.PartOperation`.
- All the returned parts are in the coordinate space of the main part, so
  their `Class.PVInstance.Origin` positions are the same as the main
  part's. This keeps the vertices of the mesh in the same position
  relative to the object as before the operation, but it does also mean
  the `(0, 0, 0)` of a returned part is not necessarily at the center of
  its body.

  Creates a new `Class.IntersectOperation` from the overlapping geometry
  of the part and the other parts in the given array.

Creates a new `Class.IntersectOperation` from the intersecting geometry of
the part and the other parts in the given array. Only `Class.Part|Parts`
are supported, not `Class.Terrain` or `Class.MeshPart|MeshParts`. Similar
to `Class.Instance:Clone()|Clone()`, the returned object has no set
`Class.Instance.Parent|Parent`.

The following properties from the calling part are applied to the
resulting `Class.IntersectOperation`:

- `Class.BasePart.Color|Color`, `Class.BasePart.Material|Material`,
  `Class.BasePart.MaterialVariant|MaterialVariant`,
  `Class.BasePart.Reflectance|Reflectance`,
  `Class.BasePart.Transparency|Transparency`
- `Class.BasePart.CanCollide|CanCollide`
- `Class.BasePart.Anchored|Anchored`, `Class.BasePart.Density|Density`,
  `Class.BasePart.Elasticity|Elasticity`,
  `Class.BasePart.ElasticityWeight|ElasticityWeight`,
  `Class.BasePart.Friction|Friction`,
  `Class.BasePart.FrictionWeight|FrictionWeight`

In the following image comparison,
`Class.BasePart:IntersectAsync()|IntersectAsync()` is called on the purple
block using a table containing the blue block. The resulting
`Class.IntersectOperation` resolves into a shape of the intersecting
geometry of both parts.

<figure>
<img src="../../../assets/modeling/solid-modeling/Separate-Parts-To-Intersect.jpg"
width="720" alt="Two block parts overlapping" />
<figcaption>Separate parts</figcaption>
</figure>
<figure>
<img src="../../../assets/modeling/solid-modeling/Intersect-Result.jpg"
width="720" alt="Parts intersected into a new solid model" />
<figcaption>Resulting <code>Class.IntersectOperation</code></figcaption>
</figure>

#### Notes

- The original parts remain intact following a successful intersect
  operation. In most cases, you should `Class.Instance.Destroy|Destroy()`
  all of the original parts and parent the returned
  `Class.IntersectOperation` to the same place as the calling
  `Class.BasePart`.
- By default, the face colors of the resulting intersection are borrowed
  from the `Class.BasePart.Color|Color` property of the original parts. To
  change the entire intersection to a specific color, set its
  `Class.PartOperation.UsePartColor|UsePartColor` property to `true`.
- If an intersect operation would result in a part with more than 20,000
  triangles, it will be simplified to 20,000 triangles.

**Parameters:**

- `parts` : `Instances` --- The objects taking part in the intersection.
- `collisionfidelity` : `CollisionFidelity` (default `Default`) --- The `Enum.CollisionFidelity` value for the resulting `Class.IntersectOperation`.
- `renderFidelity` : `RenderFidelity` (default `Automatic`) --- The `Enum.RenderFidelity` value of the resulting `Class.PartOperation`.

**Returns:**

- `Instance` --- Resulting `Class.IntersectOperation` with default name **Intersect**.

### `BasePart:IsGrounded`

```
IsGrounded() -> boolean
```

- security=`None` ; thread-safety=`Safe`

Returns true if the object is connected to a part that will hold it in
place (eg an `Class.BasePart.Anchored|Anchored` part), otherwise returns
false.

Returns true if the object is connected to a part that will hold it in
place (eg an `Class.BasePart.Anchored|Anchored` part), otherwise returns
false. In an assembly that has an `Class.BasePart.Anchored|Anchored` part,
every other part is grounded.

**Returns:**

- `boolean` --- Whether the object is connected to a part that will hold it in place.

### `BasePart:MakeJoints`

```
MakeJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** SurfaceType based joining is deprecated, do not use MakeJoints for new
projects. `Class.WeldConstraint|WeldConstraints` and
`Class.HingeConstraint|HingeConstraints` should be used instead.

Creates a joint on any side of the object that has a surface ID that can
make a joint.

Creates a joint on any side of the `Class.BasePart|Part` that has a
`Enum.SurfaceType` that can make a joint it will create a joint with any
adjacent parts.

Joints will be created between the sides and any planar touching surfaces,
depending on the sides' surfaces.

- Smooth surfaces will not create joints
- Glue surfaces will create a `Class.Glue` joint
- Weld will create a `Class.Weld` joint with any surface except for
  Unjoinable
- Studs, Inlet, or Universal will each create a `Class.Snap` joint with
  either of other the other two surfaces (e.g. Studs with Inlet and
  Universal)
- Hinge and Motor surfaces create `Class.Rotate` and `Class.RotateV` joint
  instances

Unlike `Class.Model:MakeJoints()`, this function requires an array of
parts as a parameter. This array is given as follows:

```
part:MakeJoints({part1, part2, part3})
```

Joints are broken if enough force is applied to them due to an
`Class.Explosion`, unless a `Class.ForceField` object is parented to the
`Class.BasePart` or ancestor `Class.Model`. For this reason, they are
often used to make simple destructible buildings and other models.

**Returns:**

- `()` --- 

### `BasePart:makeJoints`

```
makeJoints() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This deprecated function is a variant of `Class.BasePart:MakeJoints()`
which should be used instead.

**Returns:**

- `()` --- 

### `BasePart:Resize`

```
Resize(normalId: NormalId, deltaAmount: int) -> boolean
```

- security=`None` ; thread-safety=`Unsafe`

Changes the size of an object just like using the Studio resize tool.

**Parameters:**

- `normalId` : `NormalId` --- The side to resize.
- `deltaAmount` : `int` --- How much to grow/shrink on the specified side.

**Returns:**

- `boolean` --- Whether the part is resized.

### `BasePart:resize`

```
resize(normalId: NormalId, deltaAmount: int) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; **Deprecated:** This deprecated function is a variant of `Class.BasePart:Resize()` which
should be used instead.

**Parameters:**

- `normalId` : `NormalId` --- 
- `deltaAmount` : `int` --- 

**Returns:**

- `boolean` --- 

### `BasePart:SetNetworkOwner`

```
SetNetworkOwner(playerInstance: Player = nil) -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Sets the given player as network owner for this and all connected parts.

Sets the given player as network owner for this and all connected parts.
When playerInstance is `nil`, the server will be the owner instead of a
player.

**Parameters:**

- `playerInstance` : `Player` (default `nil`) --- The player being given network ownership of the part.

**Returns:**

- `()` --- 

### `BasePart:SetNetworkOwnershipAuto`

```
SetNetworkOwnershipAuto() -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Lets the game engine dynamically decide who will handle the part's physics
(one of the clients or the server).

**Returns:**

- `()` --- 

### `BasePart:SubtractAsync`

```
SubtractAsync(parts: Instances, collisionfidelity: CollisionFidelity = Default, renderFidelity: RenderFidelity = Automatic) -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`CSG`

Note: It is highly recommended to use the newer
`Class.GeometryService:UnionAsync` instead of this function. As well as
having better performance and more features, the new function differs as
follows:

- The output is an array of instances rather than a single instance.
- The input parts do not need to be parented to the scene, allowing for
  background operations.
- When the `SplitApart` option is set to `true` (default), each distinct
  body will be returned in its own `Class.PartOperation`.
- All the returned parts are in the coordinate space of the main part, so
  their `Class.PVInstance.Origin` positions are the same as the main
  part's. This keeps the vertices of the mesh in the same position
  relative to the object as before the operation, but it does also mean
  the `(0, 0, 0)` of a returned part is not necessarily at the center of
  its body.

  Creates a new `Class.UnionOperation` from the part, minus the geometry
  occupied by the parts in the given array.

Creates a new `Class.UnionOperation` from the part, minus the geometry
occupied by the parts in the given array. Only `Class.Part|Parts` are
supported, not `Class.Terrain` or `Class.MeshPart|MeshParts`. Similar to
`Class.Instance:Clone()|Clone()`, the returned object has no set
`Class.Instance.Parent|Parent`.

Note that the resulting union cannot be empty due to subtractions. If the
operation would result in completely empty geometry, it will fail.

In the following image comparison,
`Class.BasePart:SubtractAsync()|SubtractAsync()` is called on the blue
cylinder using a table containing the purple block. The resulting
`Class.UnionOperation` resolves into a shape that omits the block's
geometry from that of the cylinder.

<figure>
<img src="../../../assets/modeling/solid-modeling/Separate-Parts-To-Subtract.jpg"
width="720" alt="Longer block overlapping a cylinder" />
<figcaption>Separate parts</figcaption>
</figure>
<figure>
<img src="../../../assets/modeling/solid-modeling/Negate-Result.jpg" width="720"
alt="Block part subtracted from cylinder" />
<figcaption>Resulting <code>Class.UnionOperation</code></figcaption>
</figure>

**Parameters:**

- `parts` : `Instances` --- The objects taking part in the subtraction.
- `collisionfidelity` : `CollisionFidelity` (default `Default`) --- The `Enum.CollisionFidelity` value for the resulting `Class.UnionOperation`.
- `renderFidelity` : `RenderFidelity` (default `Automatic`) --- The `Enum.RenderFidelity` value of the resulting `Class.PartOperation`.

**Returns:**

- `Instance` --- Resulting `Class.UnionOperation` with default name **Union**.

### `BasePart:TorqueToAngularAcceleration`

```
TorqueToAngularAcceleration(torque: Vector3, angVelocity: Vector3 = 0, 0, 0) -> Vector3
```

- security=`None` ; thread-safety=`Unsafe`

**Parameters:**

- `torque` : `Vector3` --- 
- `angVelocity` : `Vector3` (default `0, 0, 0`) --- 

**Returns:**

- `Vector3` --- 

### `BasePart:UnionAsync`

```
UnionAsync(parts: Instances, collisionfidelity: CollisionFidelity = Default, renderFidelity: RenderFidelity = Automatic) -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`CSG`

Note: It is highly recommended to use the newer
`Class.GeometryService:UnionAsync` instead of this function. As well as
having better performance and more features, the new function differs as
follows:

- The output is an array of instances rather than a single instance.
- The input parts do not need to be parented to the scene, allowing for
  background operations.
- When the `SplitApart` option is set to `true` (default), each distinct
  body will be returned in its own `Class.PartOperation`.
- All the returned parts are in the coordinate space of the main part, so
  their `Class.PVInstance.Origin` positions are the same as the main
  part's. This keeps the vertices of the mesh in the same position
  relative to the object as before the operation, but it does also mean
  the `(0, 0, 0)` of a returned part is not necessarily at the center of
  its body.

        Creates a new `Class.UnionOperation` from the part, plus the geometry

  occupied by the parts in the given array.

Creates a new `Class.UnionOperation` from the part, plus the geometry
occupied by the parts in the given array. Only `Class.Part|Parts` are
supported, not `Class.Terrain` or `Class.MeshPart|MeshParts`. Similar to
`Class.Instance:Clone()|Clone()`, the returned object has no set
`Class.Instance.Parent|Parent`.

The following properties from the calling part are applied to the
resulting `Class.UnionOperation`:

- `Class.BasePart.Color|Color`, `Class.BasePart.Material|Material`,
  `Class.BasePart.MaterialVariant|MaterialVariant`,
  `Class.BasePart.Reflectance|Reflectance`,
  `Class.BasePart.Transparency|Transparency`
- `Class.BasePart.CanCollide|CanCollide`
- `Class.BasePart.Anchored|Anchored`, `Class.BasePart.Density|Density`,
  `Class.BasePart.Elasticity|Elasticity`,
  `Class.BasePart.ElasticityWeight|ElasticityWeight`,
  `Class.BasePart.Friction|Friction`,
  `Class.BasePart.FrictionWeight|FrictionWeight`

In the following image comparison,
`Class.BasePart:UnionAsync()|UnionAsync()` is called on the blue block
using a table containing the purple cylinder. The resulting
`Class.UnionOperation` resolves into a shape of the combined geometry of
both parts.

<figure>
<img src="../../../assets/modeling/solid-modeling/Separate-Parts-To-Union.jpg"
width="720" alt="Block and cylinder parts overlapping" />
<figcaption>Separate parts</figcaption>
</figure>
<figure>
<img src="../../../assets/modeling/solid-modeling/Union-Result.jpg" width="720"
alt="Parts joined together into a single solid union" />
<figcaption>Resulting <code>Class.UnionOperation</code></figcaption>
</figure>

#### Notes

- The original parts remain intact following a successful union operation.
  In most cases, you should `Class.Instance.Destroy|Destroy()` all of the
  original parts and parent the returned `Class.UnionOperation` to the
  same place as the calling `Class.BasePart`.
- By default, the resulting union respects the
  `Class.BasePart.Color|Color` property of each of its parts. To change
  the entire union to a specific color, set its
  `Class.PartOperation.UsePartColor|UsePartColor` property to `true`.
- If a union operation would result in a part with more than 20,000
  triangles, it will be simplified to 20,000 triangles.

**Parameters:**

- `parts` : `Instances` --- The objects taking part in the union with the calling part.
- `collisionfidelity` : `CollisionFidelity` (default `Default`) --- The `Enum.CollisionFidelity` value for the resulting `Class.UnionOperation`.
- `renderFidelity` : `RenderFidelity` (default `Automatic`) --- The `Enum.RenderFidelity` value of the resulting `Class.PartOperation`.

**Returns:**

- `Instance` --- Resulting `Class.UnionOperation` with default name **Union**.

## Events

### `BasePart.LocalSimulationTouched`

```
LocalSimulationTouched(part: BasePart)
```

- security=`None` ; tags=`Deprecated` ; **Deprecated:** This event is deprecated in favor of `Class.BasePart.Touched`.

Fired when another part comes in contact with another object. This event
only sends data to the client notifying it that two parts have collided,
whereas `Class.BasePart.Touched` sends data to the server.

**Parameters:**

- `part` : `BasePart` --- 

### `BasePart.OutfitChanged`

```
OutfitChanged()
```

- security=`None` ; tags=`Deprecated` ; **Deprecated:** This event is deprecated. Do not use it for new work.

Fired if the part's appearance is affected by the `Class.Shirt` class.

### `BasePart.StoppedTouching`

```
StoppedTouching(otherPart: BasePart)
```

- security=`None` ; tags=`Deprecated` ; **Deprecated:** This event is deprecated in favor of `Class.BasePart.TouchEnded`, which
should be used instead.

**Parameters:**

- `otherPart` : `BasePart` --- 

### `BasePart.Touched`

```
Touched(otherPart: BasePart)
```

- security=`None`

Fires when a part touches another part as a result of physical movement.

The **Touched** event fires when a part comes in contact with another
part. For instance, if **PartA** bumps into **PartB**, then
`Class.BasePart.Touched|PartA.Touched` fires with **PartB**, and
`Class.BasePart.Touched|PartB.Touched` fires with **PartA**.

This event only fires as a result of physical movement, so it will not
fire if the `Class.BasePart.CFrame|CFrame` property was changed such that
the part overlaps another part. This also means that at least one of the
parts involved must **not** be `Class.BasePart.Anchored|Anchored` at the
time of the collision.

This event works in conjunction with
`Class.Workspace.TouchesUseCollisionGroups` to specify whether
[collision groups](../../../workspace/collisions.md#collision-filtering)
are acknowledged for detection.

**Parameters:**

- `otherPart` : `BasePart` --- The other part that came in contact with the given part.

### `BasePart.TouchEnded`

```
TouchEnded(otherPart: BasePart)
```

- security=`None`

Fires when a part stops touching another part as a result of physical
movement.

Fires when a part stops touching another part under similar conditions to
those of `Class.BasePart.Touched`.

This event works in conjunction with
`Class.Workspace.TouchesUseCollisionGroups` to specify whether
[collision groups](../../../workspace/collisions.md#collision-filtering)
are acknowledged for detection.

**Parameters:**

- `otherPart` : `BasePart` --- 

## Notes / Deprecations

- Deprecated property `BasePart.brickColor`: This deprecated property is an old Camel Case variant of the Pascal Case
`Class.BasePart.BrickColor`, which should be used instead.
- Deprecated property `BasePart.Elasticity`: This is only one of multiple physics-related properties. It has been
deprecated in favor of `Class.BasePart.CustomPhysicalProperties`, which
combines these properties into one.
- Deprecated property `BasePart.Friction`: This is only one of multiple physics-related properties. It has been
deprecated in favor of `Class.BasePart.CustomPhysicalProperties`, which
combines these properties into one.
- Deprecated property `BasePart.RotVelocity`: This property is deprecated. Use `AssemblyAngularVelocity` instead.
- Deprecated property `BasePart.SpecificGravity`: This item is deprecated. See `Class.BasePart.CustomPhysicalProperties` to
see how to configure the physical properties of BaseParts. Do not use it
for new work.
- Deprecated property `BasePart.Velocity`: This property is deprecated. Use `AssemblyLinearVelocity` instead.
- Deprecated method `BasePart:breakJoints`: This deprecated function is a variant of `Class.BasePart:BreakJoints()`
which should be used instead.
- Deprecated method `BasePart:getMass`: This Camel Case property has been deprecated in favor of its Pascal Case
variant, `Class.BasePart:GetMass()`.
- Deprecated method `BasePart:GetRenderCFrame`: This item is been deprecated since interpolation is now applied to the
`Datatype.CFrame` directly. Do not use it for new work.
- Deprecated method `BasePart:MakeJoints`: SurfaceType based joining is deprecated, do not use MakeJoints for new
projects. `Class.WeldConstraint|WeldConstraints` and
`Class.HingeConstraint|HingeConstraints` should be used instead.
- Deprecated method `BasePart:makeJoints`: This deprecated function is a variant of `Class.BasePart:MakeJoints()`
which should be used instead.
- Deprecated method `BasePart:resize`: This deprecated function is a variant of `Class.BasePart:Resize()` which
should be used instead.
- Deprecated event `BasePart.LocalSimulationTouched`: This event is deprecated in favor of `Class.BasePart.Touched`.
- Deprecated event `BasePart.OutfitChanged`: This event is deprecated. Do not use it for new work.
- Deprecated event `BasePart.StoppedTouching`: This event is deprecated in favor of `Class.BasePart.TouchEnded`, which
should be used instead.
- Property `BasePart.Anchored` security: `read=None, write=None`
- Property `BasePart.AssemblyAngularVelocity` security: `read=None, write=None`
- Property `BasePart.AssemblyCenterOfMass` security: `read=None, write=None`
- Property `BasePart.AssemblyLinearVelocity` security: `read=None, write=None`
- Property `BasePart.AssemblyMass` security: `read=None, write=None`
- Property `BasePart.AssemblyRootPart` security: `read=None, write=None`
- Property `BasePart.AudioCanCollide` security: `read=None, write=None`
- Property `BasePart.BackParamA` security: `read=None, write=None`
- Property `BasePart.BackParamB` security: `read=None, write=None`
- Property `BasePart.BackSurface` security: `read=None, write=None`
- Property `BasePart.BackSurfaceInput` security: `read=None, write=None`
- Property `BasePart.BottomParamA` security: `read=None, write=None`
- Property `BasePart.BottomParamB` security: `read=None, write=None`
- Property `BasePart.BottomSurface` security: `read=None, write=None`
- Property `BasePart.BottomSurfaceInput` security: `read=None, write=None`
- Property `BasePart.BrickColor` security: `read=None, write=None`
- Property `BasePart.brickColor` security: `read=None, write=None`
- Property `BasePart.CanCollide` security: `read=None, write=None`
- Property `BasePart.CanQuery` security: `read=None, write=None`
- Property `BasePart.CanTouch` security: `read=None, write=None`
- Property `BasePart.CastShadow` security: `read=None, write=None`
- Property `BasePart.CenterOfMass` security: `read=None, write=None`
- Property `BasePart.CFrame` security: `read=None, write=None`
- Property `BasePart.CollisionGroup` security: `read=None, write=None`
- Property `BasePart.CollisionGroupId` security: `read=None, write=None`
- Property `BasePart.Color` security: `read=None, write=None`
- Property `BasePart.CurrentPhysicalProperties` security: `read=None, write=None`
- Property `BasePart.CustomPhysicalProperties` security: `read=None, write=None`
- Property `BasePart.Elasticity` security: `read=None, write=None`
- Property `BasePart.EnableFluidForces` security: `read=None, write=None`
- Property `BasePart.ExtentsCFrame` security: `read=None, write=None`
- Property `BasePart.ExtentsSize` security: `read=None, write=None`
- Property `BasePart.Friction` security: `read=None, write=None`
- Property `BasePart.FrontParamA` security: `read=None, write=None`
- Property `BasePart.FrontParamB` security: `read=None, write=None`
- Property `BasePart.FrontSurface` security: `read=None, write=None`
- Property `BasePart.FrontSurfaceInput` security: `read=None, write=None`
- Property `BasePart.LeftParamA` security: `read=None, write=None`
- Property `BasePart.LeftParamB` security: `read=None, write=None`
- Property `BasePart.LeftSurface` security: `read=None, write=None`
- Property `BasePart.LeftSurfaceInput` security: `read=None, write=None`
- Property `BasePart.LocalTransparencyModifier` security: `read=None, write=None`
- Property `BasePart.Locked` security: `read=None, write=None`
- Property `BasePart.Mass` security: `read=None, write=None`
- Property `BasePart.Massless` security: `read=None, write=None`
- Property `BasePart.Material` security: `read=None, write=None`
- Property `BasePart.MaterialVariant` security: `read=None, write=None`
- Property `BasePart.Orientation` security: `read=None, write=None`
- Property `BasePart.PivotOffset` security: `read=None, write=None`
- Property `BasePart.Position` security: `read=None, write=None`
- Property `BasePart.ReceiveAge` security: `read=None, write=None`
- Property `BasePart.Reflectance` security: `read=None, write=None`
- Property `BasePart.ResizeableFaces` security: `read=None, write=None`
- Property `BasePart.ResizeIncrement` security: `read=None, write=None`
- Property `BasePart.RightParamA` security: `read=None, write=None`
- Property `BasePart.RightParamB` security: `read=None, write=None`
- Property `BasePart.RightSurface` security: `read=None, write=None`
- Property `BasePart.RightSurfaceInput` security: `read=None, write=None`
- Property `BasePart.RootPriority` security: `read=None, write=None`
- Property `BasePart.Rotation` security: `read=None, write=None`
- Property `BasePart.RotVelocity` security: `read=None, write=None`
- Property `BasePart.Size` security: `read=None, write=None`
- Property `BasePart.SpecificGravity` security: `read=None, write=None`
- Property `BasePart.TopParamA` security: `read=None, write=None`
- Property `BasePart.TopParamB` security: `read=None, write=None`
- Property `BasePart.TopSurface` security: `read=None, write=None`
- Property `BasePart.TopSurfaceInput` security: `read=None, write=None`
- Property `BasePart.Transparency` security: `read=None, write=None`
- Property `BasePart.Velocity` security: `read=None, write=None`
- Method `BasePart:IntersectAsync` yields (tag `Yields`).
- Method `BasePart:SubtractAsync` yields (tag `Yields`).
- Method `BasePart:UnionAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- BasePart:CanSetNetworkOwnership: BasePart-CanSetNetworkOwnership1
- BasePart:GetMass: BasePart-GetMass1
- BasePart:SubtractAsync: PartOperation-SubtractAsync
- BasePart:UnionAsync: PartOperation-UnionAsync
- BasePart.Anchored: Part-Anchored-Toggle
- BasePart.BackParamA: Motor-Control
- BasePart.BackParamB: Motor-Control
- BasePart.BackSurfaceInput: Motor-Control
- BasePart.BottomParamA: Motor-Control
- BasePart.BottomParamB: Motor-Control
- BasePart.BottomSurfaceInput: Motor-Control
- BasePart.CanCollide: Fade-Door
- BasePart.CFrame: Setting-Part-CFrame
- BasePart.CollisionGroup: PhysicsService-RegisterCollisionGroup
- BasePart.Color: Character-Health-Body-Color
- BasePart.CustomPhysicalProperties: Set-CustomPhysicalProperties
- BasePart.FrontParamA: Motor-Control
- BasePart.FrontParamB: Motor-Control
- BasePart.FrontSurfaceInput: Motor-Control
- BasePart.LeftParamA: Motor-Control
- BasePart.LeftParamB: Motor-Control
- BasePart.LeftSurfaceInput: Motor-Control
- BasePart.Locked: Recursive-Unlock
- BasePart.Orientation: Part-Spinner
- BasePart.PivotOffset: reset-pivot
- BasePart.PivotOffset: clock-hands
- BasePart.ResizeableFaces: Resize-Handles
- BasePart.RightParamA: Motor-Control
- BasePart.RightParamB: Motor-Control
- BasePart.RightSurfaceInput: Motor-Control
- BasePart.RotVelocity: rotating-a-part-with-rotvelocity
- BasePart.Size: Pyramid-Builder
- BasePart.TopParamA: Motor-Control
- BasePart.TopParamB: Motor-Control
- BasePart.TopSurfaceInput: Motor-Control
- BasePart.Transparency: Fade-Door
- BasePart.Velocity: Projectile-Firing
- BasePart.LocalSimulationTouched: BasePart-LocalSimulationTouched1
- BasePart.Touched: Touching-Parts-Count
- BasePart.Touched: Model-Touched
- BasePart.TouchEnded: Touching-Parts-Count

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/BasePart
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/BasePart.yaml
- Captured: 2026-04-16
