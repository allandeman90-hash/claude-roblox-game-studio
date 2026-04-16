---
title: Workspace
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Workspace
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Workspace.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: world
tags: [roblox-class, workspace, world, service]
---

# Workspace

**Workspace** houses 3D objects which are rendered to the 3D world. Objects
not descending from it will not be rendered or physically interact with the
world.

## Description

The core job of `Class.Workspace` is to hold objects that exist in the 3D
world, effectively `Class.BasePart|BaseParts` and
`Class.Attachment|Attachments`. While such objects are descendant of
`Class.Workspace`, they will be active. For `Class.BasePart|BaseParts`, this
means they will be rendered, and physically interact with other parts and the
world. For `Class.Attachment|Attachments`, this means that objects adorned to
them, such as `Class.ParticleEmitter|ParticleEmitters`, `Class.Beam|Beams`,
and `Class.BillboardGui|BillboardGuis`, will render.

Understanding this behavior is important, as it means objects can be removed
from `Class.Workspace` when they are not needed. For example, map
`Class.Model|Models` can be removed when a different map is being played on.
Objects that are not immediately needed in the 3D world are generally stored
in `Class.ReplicatedStorage` or `Class.ServerStorage`.

In its role as the holder of active 3D objects, `Class.Workspace` includes a
number of useful functions related to parts, their positions, and joints
between them.

##### Accessing the Workspace

`Class.Workspace` can be accessed several ways, all of which are valid.

- `workspace`
- `game:GetService("Workspace")`
- `game.Workspace`

##### Notes

- Objects that require adornment, such as
  `Class.ParticleEmitter|ParticleEmitters` and
  `Class.BillboardGui|BillboardGuis`, will be at the
  <Typography noWrap>`(0, 0, 0)`</Typography> position when parented to
  `Class.Workspace` without an adornee otherwise being set.
- The `Class.Model:MakeJoints()` and `Class.Model:BreakJoints()` methods
  inherited from the `Class.Model` class are overridden by
  `Class.Workspace:MakeJoints()` and `Class.Workspace:BreakJoints()` which can
  only be used in plugins.
- It is impossible to delete `Class.Workspace`.
- `Class.Workspace` automatically cleans up `Class.BasePart|BaseParts` that
  fall beneath
  `Class.Workspace.FallenPartsDestroyHeight|FallenPartsDestroyHeight`.
- A client's current `Class.Camera` object can be accessed using the
  `Class.Workspace.CurrentCamera` property.
- The `Class.Terrain` object can be accessed using the
  `Class.Workspace.Terrain` property.

## Inheritance

Inherits from: `WorldRoot`

Class tags: `NotCreatable`, `Service`

Memory category: `BaseParts`

## Properties

### `Workspace.AirDensity`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Physics`, `Environment`

The air density at ground level, used in the aerodynamic force model.

The ground level (**Y** of 0) air density in RMU/stud&sup3; units (see
[Roblox Units](../../../physics/units.md)), used to calculate the
aerodynamic force if `Class.Workspace.FluidForces` is
`Enum.FluidForces|Experimental`. The default corresponds to realistic sea
level air density at standard temperature and pressure. Air density decays
as the **Y** altitude increases, reaching 5% of its ground level value at
100,000 studs. Below **Y** of 0, the air density is fixed at the input
value.

### `Workspace.AirTurbulenceIntensity`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Physics`, `Environment`

Controls the strength of turbulence present in the wind velocity field,
affecting the aerodynamic force model.

Controls the intensity of turbulence by determining the magnitude of
fluctuations in wind velocities. Ranges from `0` to `1`, with a value of
`0` disabling turbulence and a value of `1` providing the most intense
turbulence. The values of `AirTurbulenceIntensity` roughly correspond to
the following levels:

- `(0, 0.4]`: Low intensity turbulence
- `(0.4, 0.7]`: Moderate intensity turbulence
- `(0.7, 1]`: High intensity turbulence

The magnitude of the fluctuations at a fixed intensity scale linearly with
the magnitude of the global wind, except in the case that the global wind
is zero. When the global wind is zero, the magnitude of the fluctuations
scale exponentially with `AirTurbulenceIntensity`, allowing low and high
intensity turbulence to exist with wind velocities that still average out
to zero.

### `Workspace.AllowThirdPartySales`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Monetization`

Determines whether assets created by other users can be sold in the game.

This `Class.Workspace` property determines whether assets created by other
uses can be sold in the game.

### `Workspace.AuthorityMode`

- **Type:** `AuthorityMode`
- **Security:** `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`

Sets the server authority mode.

Sets the server authority mode. See `Enum.AuthorityMode` for options.

### `Workspace.AvatarUnificationMode`

- **Type:** `AvatarUnificationMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.ClientAnimatorThrottling`

- **Type:** `ClientAnimatorThrottlingMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Animation`

Specifies the animation throttling mode for the local client.

Specifies the `Enum.ClientAnimatorThrottlingMode` to use for the local
client.

When enabled, animations on remotely-simulated `Class.Model` instances
will begin to throttle. The throttler calculates throttling intensity
using:

- Visibility of a `Class.Model` in relation to the `Class.Camera`
- In-game FPS
- Number of active animations

### `Workspace.CurrentCamera`

- **Type:** `Camera`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

The `Class.Camera` object being used by the local player.

The `Class.Camera` object being used by the local player.

#### How to use CurrentCamera

When looking for a client's `Class.Camera` object, use this property
rather than looking for a child of `Class.Workspace` named "Camera".

When you set this property, all other `Camera` objects in the `Workspace`
are destroyed, including the previous `CurrentCamera`. If you set this
property to `nil` or to a camera that is not a descendant of the Workspace
(or the `CurrentCamera` is otherwise destroyed), a new `Camera` will be
created and assigned. Avoid these scenarios, as destroying the camera can
have unintended consequences.

For more information, see
[Scripting the Camera](../../../workspace/camera.md#scripting-the-camera).

### `Workspace.DistributedGameTime`

- **Type:** `double`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

The amount of time, in seconds, that the game has been running.

The amount of time, in seconds, that the game has been running.

Despite the title, this value is currently not 'Distributed' across the
client and the server. Instead, on the server it represents how long the
server has been running. On the client, it represents how long the client
has been connected to the server.

Developers should not rely on the above behavior, and it is possible this
property will be synchronized across clients and the server in the future.

Those looking for the time since the program started running should use
the 'time' function instead. See below for a comparison between
DistributedGameTime and its alternatives.

```
local Workspace = game:GetService("Workspace")

print(Workspace.DistributedGameTime) -- Time the game started running
print(os.time()) -- Time since epoch (1 January 1970, 00:00:00) UTC
print(tick()) -- Time since epoch (1 January 1970, 00:00:00) system time
print(time()) -- Time the game started running
print(elapsedTime()) -- Time since Roblox started running
```

### `Workspace.FallenPartsDestroyHeight`

- **Type:** `float`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Determines the height at which falling `Class.BasePart|BaseParts` and
their ancestor `Class.Model|Models` are removed from `Class.Workspace`.

This property determines the height at which the engine automatically
removes falling `Class.BasePart|BaseParts` and their ancestor
`Class.Model|Models` from `Class.Workspace` by parenting them to `nil`.
This is to prevent parts that have fallen off the map from continuing to
fall forever.

If a part removed due to this behavior is the last part in a
`Class.Model`, that model will also be removed. This applies to all model
ancestors of the part.

This property is clamped between -50,000 and 50,000 because
`Class.BasePart|BaseParts` do not simulate or render properly at a great
distance from the origin due to floating point inaccuracies.

This property can be read by scripts, but can only be set by plugins, the
command bar, or the properties window in Studio.

### `Workspace.FallHeightEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

### `Workspace.FilteringEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Basic`

Determines whether changes made from the client will replicate to the
server or not.

This property is discontinued and no longer takes effect.

### `Workspace.FluidForces`

- **Type:** `FluidForces`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Determines whether the physics engine computes aerodynamic forces on
`Class.BasePart|BaseParts` whose
`Class.BasePart.EnableFluidForces|EnableFluidForces` property is true.

With this property enabled, the physics engine computes aerodynamic forces
on `Class.BasePart|BaseParts` whose
`Class.BasePart.EnableFluidForces|EnableFluidForces` property is true. The
default, `Enum.FluidForces|Default`, disables aerodynamic forces. Note
that this property cannot be set through scripting and instead must be
toggled in Studio.

### `Workspace.GlobalWind`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Specifies the global wind vector for animated terrain grass, dynamic
clouds, and particles.

This property specifies the direction and strength that wind blows through
the experience, affecting terrain grass, dynamic clouds, and particles.
See the [Global Wind](../../../environment/global-wind.md) article for
details.

### `Workspace.Gravity`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Determines the acceleration due to gravity applied to falling
`Class.BasePart|BaseParts`.

Determines the acceleration due to gravity applied to falling
`Class.BasePart|BaseParts`. This value is measured in studs per second
squared and by default is set to 196.2 studs/second<sup>2</sup>. By
changing this value, developers can simulate the effects of lower or
higher gravity in game.

### `Workspace.IKControlConstraintSupport`

- **Type:** `IKControlConstraintSupport`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Enables support for constraints for IKControls. If disabled, IKControls
ignore physics constraints.

Enables support for constraints for IKControls. The `Default` value is the
same as `Enabled`. If disabled, IKControls ignore physics constraints. See
`Class.IKControl` for additional details.

### `Workspace.InsertPoint`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`

### `Workspace.InterpolationThrottling`

- **Type:** `InterpolationThrottlingMode`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Physics`
- **Deprecated:** This property should not be used for new work.

### `Workspace.LayeredClothingCacheOptimizations`

- **Type:** `RolloutState`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `AvatarAppearance`

### `Workspace.LuauTypeCheckMode`

- **Type:** `LuauTypeCheckMode`
- **Security:** `read=PluginSecurity, write=PluginSecurity`
- **Thread safety:** `ReadSafe`

### `Workspace.MeshPartHeadsAndAccessories`

- **Type:** `MeshPartHeadsAndAccessories`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Sets whether character Heads and Accessories should be downloaded as
MeshParts.

Sets whether character Heads and Accessories should be downloaded as
`Class.MeshPart|MeshParts`. The `Default` value is the same as `Enabled`.
If this feature is enabled, built-in avatars will use
`Class.MeshPart|MeshParts` for the character's head and accessories.

### `Workspace.ModelStreamingBehavior`

- **Type:** `ModelStreamingBehavior`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Controls how `Class.Model|Models` are replicated in experiences when
instance streaming is enabled.

This `Enum.ModelStreamingBehavior` property controls how
`Class.Model|Models` are replicated in experiences when instance streaming
is enabled.

### `Workspace.MoverConstraintRootBehavior`

- **Type:** `MoverConstraintRootBehaviorMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Controls the logic used to select the assembly root part when using any of
the mover constraints.

Controls the logic used to select the assembly root part for mechanisms
that use any of the following constraints:

- `Class.AlignOrientation`
- `Class.AlignPosition`
- `Class.AngularVelocity`
- `Class.LinearVelocity`

When this property is set to
`Enum.MoverConstraintRootBehaviorMode.Enabled`, these constraints will be
ignored when selecting the assembly root part if the constraint does not
transmit forces between two parts (some examples being
`Class.AngularVelocity.ReactionTorqueEnabled` set to `false`,
`Class.AlignPosition.ReactionForceEnabled` set to `false`, or
`Class.AlignOrientation.Mode` set to
`Enum.OrientationAlignmentMode.OneAttachment`).

When this property is set to
`Enum.MoverConstraintRootBehaviorMode.Disabled`, these constraints may be
erroneously considered when selecting the assembly root part, leading to
inconsistent network ownership and delays when adding these constraints to
a mechanism.

### `Workspace.NextGenerationReplication`

- **Type:** `RolloutState`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

When `true`, enables an alternate replication system that alters and
improves how properties are replicated under the hood.

When `true`, enables an alternate replication system that alters and
improves how properties are replicated under the hood; note that when
`true`, you should not rely on the ordering of property replication and
remote events.

### `Workspace.PathfindingUseImprovedSearch`

- **Type:** `PathfindingUseImprovedSearch`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.PhysicsImprovedSleep`

- **Type:** `RolloutState`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.PhysicsSteppingMethod`

- **Type:** `PhysicsSteppingMethod`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Sets how the solver will advance the physics simulation forward in time.

Sets how the solver will advance the physics simulation forward in time.
This option is not scriptable and must be set from the
**PhysicsSteppingMethod** property of **Workspace** within Studio. See
[Adaptive Timestepping](../../../physics/adaptive-timestepping.md) for
details.

Note that when assemblies of different simulation rates become connected
via `Class.Constraint|Constraints` or collisions, the combined mechanism
will default to the highest simulation rate for stability.

### `Workspace.PlayerCharacterDestroyBehavior`

- **Type:** `PlayerCharacterDestroyBehavior`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.PlayerScriptsUseInputActionSystem`

- **Type:** `RolloutState`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Controls internal behavior of the built-in `Class.Player` scripts.

When `true`, updates the built-in `Class.Player` scripts to a new system
where they live under `Class.StarterPlayer`, use the
[Input Action System](../../../input/input-action-system.md), and allow
the server to process player inputs.

### `Workspace.PrimalPhysicsSolver`

- **Type:** `PrimalPhysicsSolver`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.RejectCharacterDeletions`

- **Type:** `RejectCharacterDeletions`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.RenderingCacheOptimizations`

- **Type:** `RenderingCacheOptimizationMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Physics`

### `Workspace.ReplicateInstanceDestroySetting`

- **Type:** `ReplicateInstanceDestroySetting`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.Retargeting`

- **Type:** `AnimatorRetargetingMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Animation`

### `Workspace.SandboxedInstanceMode`

- **Type:** `SandboxedInstanceMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

### `Workspace.SignalBehavior`

- **Type:** `SignalBehavior`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Configures when the engine resumes event handlers.

This property determines whether event handlers will be resumed
immediately when the event fires, or deferred and then resumed at a later
resumption point. Resumption points currently include:

- Input processing (resumes once per input to be processed, see
  `Class.UserInputService`)
- `Class.RunService.PreRender`
- Legacy waiting script resumption such as `wait()`, `spawn()`, and
  `delay()`
- `Class.RunService.PreAnimation`
- `Class.RunService.PreSimulation`
- `Class.RunService.PostSimulation`
- Waiting script resumption such as `Library.task.wait()`,
  `Library.task.spawn()`, and `Library.task.delay()`
- `Class.RunService.Heartbeat`
- `Class.DataModel.BindToClose`

For more information, see
[Deferred Events](../../../scripting/events/deferred.md).

### `Workspace.StreamingEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`

Whether content streaming is enabled for the place.

This property determines whether in-experience content streaming is
enabled for the place. This property is not scriptable and therefore must
be set on the `Workspace` object in Studio.

#### See Also

- `Class.Workspace.StreamingMinRadius`
- `Class.Workspace.StreamingTargetRadius`
- `Class.Workspace.StreamingIntegrityMode`

### `Workspace.StreamingIntegrityMode`

- **Type:** `StreamingIntegrityMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Determines whether streaming integrity mode is active.

If instance [streaming](../../../workspace/streaming/index.md) is enabled,
an experience may behave in unintended ways if a player's character moves
into a region of the world that has not been streamed to their client. The
streaming integrity feature offers a way to avoid those potentially
problematic situations.

### `Workspace.StreamingMinRadius`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Minimum distance that content will be streamed to players with high
priority.

This property indicates the radius around the player's character or the
current `Class.Player.ReplicationFocus|ReplicationFocus` in which content
will be streamed in at the highest priority. Defaults to 64 studs.

Care should be taken when increasing the default minimum radius since
doing so will require more memory and more server bandwidth at the expense
of other components.

#### See Also

- `Class.Workspace.StreamingEnabled` which controls whether content
  streaming is enabled
- `Class.Workspace.StreamingTargetRadius`
- `Class.Workspace.StreamingIntegrityMode`

### `Workspace.StreamingTargetRadius`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Maximum distance that content will be streamed to players.

This property controls the maximum distance away from the player's
character or the current `Class.Player.ReplicationFocus|ReplicationFocus`
in which content will be streamed in. Defaults to 1024 studs.

Note that the engine is allowed to retain previously loaded content beyond
the target radius, memory permitting.

#### See Also

- `Class.Workspace.StreamingEnabled` which controls whether content
  streaming is enabled
- `Class.Workspace.StreamingMinRadius`
- `Class.Workspace.StreamingIntegrityMode`

### `Workspace.StreamOutBehavior`

- **Type:** `StreamOutBehavior`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Configures how the engine decides when to stream content away from
players.

This property controls where content will be unloaded from the
`Class.Player.ReplicationFocus|ReplicationFocus` based on device memory
conditions, or based on the streaming radius.

#### See Also

- `Class.Workspace.StreamingEnabled` which controls whether content
  streaming is enabled
- `Class.Workspace.StreamingMinRadius`
- `Class.Workspace.StreamingTargetRadius`
- `Class.Workspace.StreamingIntegrityMode`

### `Workspace.Terrain`

- **Type:** `Terrain`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`

A reference to the `Class.Terrain` object parented to the
`Class.Workspace`.

This property is a reference to the `Class.Terrain` object parented to the
`Class.Workspace`.

<img src="/assets/studio/explorer/Workspace-Terrain.png" width="320"
alt="Terrain object within the Workspace hierarchy" />

See [Environmental Terrain](../../../parts/terrain.md) for more
information.

### `Workspace.TouchesUseCollisionGroups`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

Determines whether `Class.BasePart|parts` in different groups set to not
collide will ignore collisions and touch events.

This property determines whether `Class.BasePart|parts` in different
groups set to not collide will ignore collisions and touch events. By
default, the value of this property is set to `false`.

When this property is enabled, parts in different groups set to not
collide will also ignore the `Class.BasePart.CanTouch|CanTouch` property,
similar to how `Class.BasePart.CanCollide` is ignored. For more
information on the behavior of CanTouch, please visit its property page.

### `Workspace.UseFixedSimulation`

- **Type:** `RolloutState`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

When `true`, enables `Class.RunService:BindToSimulation()` which calls a
function at a fixed frequency, updates physics stepping logic, and makes
the `Global.RobloxGlobals.time()` function return the fixed stepped frame
time.

When `true`, enables `Class.RunService:BindToSimulation()` which calls a
function at a fixed frequency. Also updates physics stepping logic such
that character controller updates and joint transforms are performed at a
fixed frequency rather than once per frame, as well as makes the
`Global.RobloxGlobals.time()` function return the fixed stepped frame
time.

### `Workspace.UseNewLuauTypeSolver`

- **Type:** `RolloutState`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`

## Methods

### `Workspace:BreakJoints`

```
BreakJoints(objects: Instances) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; tags=`Deprecated`

Goes through all `Class.BasePart|BaseParts` given, breaking any joints
connected to these parts.

Goes through all `Class.BasePart|BaseParts` given, breaking any joints
connected to these parts. This function will break any of the following
types of joints:

- `Class.JointInstance|JointInstances` such as `Class.Weld|Welds`
- `Class.WeldConstraint|WeldConstraints`

Unlike `Class.Model:MakeJoints()`, this function requires an array of
`Class.BasePart|BaseParts` as a parameter. This array is given as follows:

```lua
local Workspace = game:GetService("Workspace")

Workspace:BreakJoints({part1, part2, part3})
```

Note, this function cannot be used by scripts and will only function in
plugins.

**Parameters:**

- `objects` : `Instances` — An array of `Class.BasePart|BaseParts` for whom joints are to be broken.

**Returns:**

- `()` — 

### `Workspace:GetNumAwakeParts`

```
GetNumAwakeParts() -> int
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns the number of `Class.BasePart|BaseParts` that are deemed
physically active, due to being recently under the influence of physics.

Returns the number of `Class.BasePart|BaseParts` that are deemed
physically active, due to being recently under the influence of physics.

This function provides a measure of how many `Class.BasePart|BaseParts`
are being influenced by, or recently under the influence of, physical
forces.

```
local Workspace = game:GetService("Workspace")

print(Workspace:GetNumAwakeParts())
```

In order to ensure good performance, the engine sets
`Class.BasePart|BaseParts` in which physics are not being applied to a
"sleeping" state. `Class.BasePart|BaseParts` with
`Class.BasePart.Anchored` set to `true`, for example, will always be
sleeping as physics doesn't apply to them. When a force is applied to a
non‑anchored `Class.BasePart`, an "awake" state will be applied. Whilst a
`Class.BasePart` is awake, the physics engine will perform continuous
calculations to ensure physical forces interact correctly with the part.
Once the `Class.BasePart` is no longer subject to physical forces, it will
revert to a "sleeping" state.

**Returns:**

- `int` — The number of awake parts.

### `Workspace:GetPhysicsThrottling`

```
GetPhysicsThrottling() -> int
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns an integer, between 0 and 100, representing the percentage of real
time that physics simulation is currently being throttled to.

Returns an integer, between `0` and `100`, representing the percentage of
real time that physics simulation is currently being throttled to. Physics
throttling occurs when the physics engine detects it cannot keep up with
the game in real time. When physics is being throttled, it will update
less frequently causing `Class.BasePart|BaseParts` to appear to move
slower.

Objects associated with `Class.Humanoid|Humanoids` are exempt from physics
throttling.

See also `Class.Workspace:SetPhysicsThrottleEnabled()`.

**Returns:**

- `int` — The percentage of real time that physics simulation is currently being throttled to.

### `Workspace:GetRealPhysicsFPS`

```
GetRealPhysicsFPS() -> double
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns the number of frames per second that physics is currently being
simulated at.

Returns the number of frames per second that physics is currently being
simulated at.

#### Using GetRealPhysicsFPS to combat exploiters

A common use of this function is to detect if exploiters are increasing
their local physics frame rate to move faster. This is generally done by
comparing the result returned by a client's GetRealPhysicsFPS to a maximum
that will not be breached in normal circumstances (usually 65 or 70). If
this limit is breached, developers can use the `Class.Player:Kick()`
function to remove that `Class.Player` from the game. It is important to
remember that, although this practice may be effective sometimes,
client-side anti-exploiter measures are never 100% reliable.

**Returns:**

- `double` — Returns the number of frames per second that physics is currently being simulated at.

### `Workspace:GetServerTimeNow`

```
GetServerTimeNow() -> double
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns the server's Unix time in seconds.

This method returns the client's best approximation of the current time on
the server. It is useful for creating synchronized experiences, as every
client will get roughly the same results regardless of their timezone or
local clock.

This method returns a Unix timestamp, similar to `Library.os|os.time()`,
that you can use with `Library.os|os.date()` or
`Datatype.DateTime.fromUnixTimestamp()`. The timestamp is smoothed so
that:

- It is monotonic; its value will never decrease.
- It moves at the same rate as the local clock to within 0.6%.

This method is useful for making sure an event starts at the right
real-world time and for periodic adjustments to keep a series of events in
sync. For benchmarking or other use cases that require higher precision,
consider `Library.os|os.clock()`.

This method relies on the server, so calling it from a client that isn't
connected will throw an error. Also note that this method is not suitable
for things like timed rewards, as it is not secure compared to tracking
such timers on the server.

See also:

- `Class.Workspace.DistributedGameTime|DistributedGameTime`, a game-time
  clock
- `Library.os|os.time()`
- `Datatype.DateTime`

**Returns:**

- `double` — The estimated Unix timestamp on the server.

### `Workspace:JoinToOutsiders`

```
JoinToOutsiders(objects: Instances, jointType: JointCreationMode) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Physics`

Creates joints between the specified `Class.BasePart|Parts` and any
touching parts depending on the parts' surfaces and the specified joint
creation mode.

This function creates joints between the specified `Class.BasePart|Parts`
and any touching parts depending on the parts' surfaces and the specified
joint creation mode.

This function creates joints between the specified Parts and any planar
touching surfaces, depending on the parts' surfaces and the specified
joint creation mode.

- Glue, Studs, Inlets, Universal, Weld, and Smooth surfaces will all
  create Weld instances.
- Spheres will not surface-weld to anything. The rounded sides of
  cylinders will not surface-weld, but the flat end sides will.
- Hinge and Motor surfaces will still create `Class.Rotate` and
  `Class.RotateP` joint instances, regardless of part shape.

The first parameter is an array of `Class.BasePart|BaseParts`. Joints will
only be created between the parts in the array and not in the array.
Joints will not be created between the parts in the array.

The second parameter is a `Enum.JointCreationMode` that determines how
joints will be created. Passing in either enum value,
`Enum.JointCreationMode|Enum.JointCreationMode.All` or
`Enum.JointCreationMode|Enum.JointCreationMode.Surface`, has the same
behavior which equates to Join Always

This function is used by the Roblox Studio **Move** tool when the user
finishes moving a selection. In conjunction with
`Class.Plugin:GetJoinMode()` and `Class.Workspace:UnjoinFromOutsiders()`
it can be used to retain join functionality when developing custom studio
build tools. See the snippets below for an example.

```lua
local Workspace = game:GetService("Workspace")

-- Finished moving a selection; make joints
local function finishedMovingParts(parts)
	local joinMode = Plugin:GetJoinMode()
	Workspace:JoinToOutsiders(parts, joinMode)
end
```

```lua
local Workspace = game:GetService("Workspace")

-- Started moving a selection; break joints
local function startMovingParts(parts)
	Workspace:UnjoinFromOutsiders(parts)
end
```

**Parameters:**

- `objects` : `Instances` — An array of `Class.BasePart|BaseParts` for whom joints are to be made.
- `jointType` : `JointCreationMode` — The `Enum.JointCreationMode` to be used. Passing in `Enum.JointCreationMode|Enum.JointCreationMode.All` or `Enum.JointCreationMode|Enum.JointCreationMode.Surface` has the same behavior which equates to Join Always.

**Returns:**

- `()` — 

### `Workspace:MakeJoints`

```
MakeJoints(objects: Instances) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; tags=`Deprecated`

Goes through all `Class.BasePart|BaseParts` given. If any part's side has
a `Enum.SurfaceType` that can make a joint it will create a joint with any
adjacent parts.

**Deprecated**

SurfaceType based joining is deprecated, do not use MakeJoints for new
projects. `Class.WeldConstraint|WeldConstraints` and
`Class.HingeConstraint|HingeConstraints` should be used instead.

Goes through all `Class.BasePart|Parts` given. If any part's side has a
`Enum.SurfaceType` that can make a joint it will create a joint with any
adjacent parts.

Joints will be created between the specified Parts and any planar touching
surfaces, depending on the parts' surfaces.

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
local Workspace = game:GetService("Workspace")

Workspace:MakeJoints({part1, part2, part3})
```

Joints are broken if enough force is applied to them due to an
`Class.Explosion`, unless a `Class.ForceField` object is parented to the
`Class.BasePart` or ancestor `Class.Model`. For this reason, they are
often used to make simple destructible buildings and other models.

**Parameters:**

- `objects` : `Instances` — An array of `Class.BasePart|parts` for whom joints are to be made.

**Returns:**

- `()` — 

### `Workspace:PGSIsEnabled`

```
PGSIsEnabled() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Returns `true` if the game has the PGS Physics solver enabled.

Returns `true` if the game has the PGS Physics solver enabled.

As `Class.Workspace.PGSPhysicsSolverEnabled` cannot be accessed by
scripts, the PGSIsEnabled function allows developers to tell which physics
solver the game is using.

**Returns:**

- `boolean` — True if the PGS solver is enabled.

### `Workspace:UnjoinFromOutsiders`

```
UnjoinFromOutsiders(objects: Instances) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Physics`

Breaks all joints between the specified `Class.BasePart|BaseParts` and
other `Class.BasePart|BaseParts`.

Breaks all joints between the specified `Class.BasePart|BaseParts` and
other `Class.BasePart|BaseParts`.

This function requires an array of `Class.BasePart|BaseParts`. Note,
joints will not be broken between these `Class.BasePart|BaseParts` (each
other), only between these `Class.BasePart|BaseParts` and other
`Class.BasePart|BaseParts` not in the array.

This function is used by the Roblox Studio **Move** tool when the user
starts moving a selection. In conjunction with
`Class.Plugin:GetJoinMode()` and `Class.Workspace:JoinToOutsiders()` it
can be used to retain join functionality when developing custom Studio
build tools. See the snippets below for an example.

```
local Workspace = game:GetService("Workspace")

-- Finished moving a selection; make joints
local function finishedMovingParts(parts)
	local joinMode = Plugin:GetJoinMode()
	Workspace:JoinToOutsiders(parts, joinMode)
end
```

```
local Workspace = game:GetService("Workspace")

-- Started moving a selection; break joints
local function startMovingParts(parts)
	Workspace:UnjoinFromOutsiders(parts)
end
```

**Parameters:**

- `objects` : `Instances` — An array of `Class.BasePart|BaseParts` for whom joints are to be broken.

**Returns:**

- `()` — 

### `Workspace:ZoomToExtents`

```
ZoomToExtents() -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe`

Positions and zooms the `Class.Workspace.CurrentCamera` to show the extent
of `Class.BasePart|BaseParts` currently in the `Class.Workspace`.

Positions and zooms the `Class.Workspace.CurrentCamera` to show the extent
of `Class.BasePart|BaseParts` currently in the `Class.Workspace`. It
exhibits similar behavior to the "focus" command but it shows the extents
of the `Class.Workspace` rather than the currently selected object.

This function cannot be used in scripts but will function in the command
bar or plugins.

**Returns:**

- `()` — 

## Events

### `Workspace.PersistentLoaded`

```
PersistentLoaded(player: Player)
```

- security=`None`

Fires when persistent models have been sent to the specified player.

This event fires every time a player has been sent all current persistent
models and part-less atomic models. The `player` parameter indicates which
player has received all applicable instances.

Note that experience loading happens before persistent loading, and firing
of the `Class.DataModel.Loaded` event does not indicate that all
persistent models are present.

**Parameters:**

- `player` : `Player` — 

## Notes / Deprecations

- Deprecated property `Workspace.InterpolationThrottling`: This property should not be used for new work.
- Method `Workspace:BreakJoints` security: `PluginSecurity`
- Method `Workspace:MakeJoints` security: `PluginSecurity`
- Method `Workspace:ZoomToExtents` security: `PluginSecurity`
- Property `Workspace.AirDensity` security: `read=None, write=None`
- Property `Workspace.AirTurbulenceIntensity` security: `read=None, write=None`
- Property `Workspace.AllowThirdPartySales` security: `read=None, write=None`
- Property `Workspace.AuthorityMode` security: `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- Property `Workspace.AvatarUnificationMode` security: `read=None, write=None`
- Property `Workspace.ClientAnimatorThrottling` security: `read=None, write=None`
- Property `Workspace.CurrentCamera` security: `read=None, write=None`
- Property `Workspace.DistributedGameTime` security: `read=None, write=None`
- Property `Workspace.FallenPartsDestroyHeight` security: `read=None, write=PluginSecurity`
- Property `Workspace.FallHeightEnabled` security: `read=None, write=PluginSecurity`
- Property `Workspace.FilteringEnabled` security: `read=None, write=PluginSecurity`
- Property `Workspace.FluidForces` security: `read=None, write=None`
- Property `Workspace.GlobalWind` security: `read=None, write=None`
- Property `Workspace.Gravity` security: `read=None, write=None`
- Property `Workspace.IKControlConstraintSupport` security: `read=None, write=None`
- Property `Workspace.InsertPoint` security: `read=None, write=None`
- Property `Workspace.InterpolationThrottling` security: `read=None, write=PluginSecurity`
- Property `Workspace.LayeredClothingCacheOptimizations` security: `read=None, write=None`
- Property `Workspace.LuauTypeCheckMode` security: `read=PluginSecurity, write=PluginSecurity`
- Property `Workspace.MeshPartHeadsAndAccessories` security: `read=None, write=None`
- Property `Workspace.ModelStreamingBehavior` security: `read=None, write=None`
- Property `Workspace.MoverConstraintRootBehavior` security: `read=None, write=None`
- Property `Workspace.NextGenerationReplication` security: `read=None, write=None`
- Property `Workspace.PathfindingUseImprovedSearch` security: `read=None, write=None`
- Property `Workspace.PhysicsImprovedSleep` security: `read=None, write=None`
- Property `Workspace.PhysicsSteppingMethod` security: `read=None, write=None`
- Property `Workspace.PlayerCharacterDestroyBehavior` security: `read=None, write=None`
- Property `Workspace.PlayerScriptsUseInputActionSystem` security: `read=None, write=None`
- Property `Workspace.PrimalPhysicsSolver` security: `read=None, write=None`
- Property `Workspace.RejectCharacterDeletions` security: `read=None, write=None`
- Property `Workspace.RenderingCacheOptimizations` security: `read=None, write=None`
- Property `Workspace.ReplicateInstanceDestroySetting` security: `read=None, write=None`
- Property `Workspace.Retargeting` security: `read=None, write=None`
- Property `Workspace.SandboxedInstanceMode` security: `read=None, write=None`
- Property `Workspace.SignalBehavior` security: `read=None, write=None`
- Property `Workspace.StreamingEnabled` security: `read=None, write=PluginSecurity`
- Property `Workspace.StreamingIntegrityMode` security: `read=None, write=None`
- Property `Workspace.StreamingMinRadius` security: `read=None, write=None`
- Property `Workspace.StreamingTargetRadius` security: `read=None, write=None`
- Property `Workspace.StreamOutBehavior` security: `read=None, write=None`
- Property `Workspace.Terrain` security: `read=None, write=None`
- Property `Workspace.TouchesUseCollisionGroups` security: `read=None, write=None`
- Property `Workspace.UseFixedSimulation` security: `read=None, write=None`
- Property `Workspace.UseNewLuauTypeSolver` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- Workspace:GetRealPhysicsFPS: Workspace-GetRealPhysicsFPS1
- Workspace.Gravity: Low-Gravity-Button

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Workspace
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Workspace.yaml
- Captured: 2026-04-16
