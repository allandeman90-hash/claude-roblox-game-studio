---
title: BasePart
type: service
category: services
subcategory: core
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources: [wiki/raw/roblox-creator-docs/services/BasePart.md]
related:
  - "[[Instance]]"
  - "[[Part]]"
  - "[[MeshPart]]"
  - "[[Model]]"
  - "[[Attachment]]"
  - "[[WeldConstraint]]"
tags: [roblox-class, core, parts, physics, base-class]
---

# BasePart

> Abstract base class for in-world objects that render and physically interact. [[Part]] [[MeshPart]]

## Summary

BasePart is the abstract base class for all physical objects that exist in the 3D Workspace. It provides the shared API for position, size, physics, collision, and appearance that Part, MeshPart, WedgePart, SpawnLocation, and Terrain all inherit.

BasePart manages the physical simulation of objects. Properties like Anchored, CanCollide, Massless, and AssemblyLinearVelocity control how parts interact with the physics engine. The CFrame property defines position and orientation in world space, while Size defines the bounding dimensions.

Parts can be grouped into rigid bodies ("assemblies") through joints like WeldConstraint and Motor6D. The assembly root part is the part that "leads" the physics simulation for the group. Understanding assemblies is critical for character rigs, vehicles, and any multi-part physics object.

## API Surface

### Properties (key subset)
- `Anchored: boolean` -- If true, the part is immovable by physics. Default false
- `CanCollide: boolean` -- Whether the part participates in collision detection. Default true
- `CanQuery: boolean` -- Whether raycasts and spatial queries detect this part. Default true
- `CanTouch: boolean` -- Whether Touched/TouchEnded events fire for this part. Default true
- `CFrame: CFrame` -- Position and orientation in world space
- `Position: Vector3` -- World position (derived from CFrame)
- `Orientation: Vector3` -- Euler angles in degrees (derived from CFrame)
- `Size: Vector3` -- Dimensions in studs
- `Color: Color3` -- Part color
- `Material: Enum.Material` -- Surface material (affects physics friction and appearance)
- `Transparency: number` -- 0 = opaque, 1 = invisible
- `Massless: boolean` -- If true, the part does not contribute mass to its assembly
- `RootPriority: number` -- Influences which part becomes the assembly root
- `AssemblyLinearVelocity: Vector3` -- Linear velocity of the assembly (read/write)
- `AssemblyAngularVelocity: Vector3` -- Angular velocity of the assembly (read/write)
- `AssemblyMass: number` -- Total mass of the assembly (read-only)
- `CollisionGroup: string` -- Collision group name for collision filtering
- `CustomPhysicalProperties: PhysicalProperties?` -- Override density, friction, elasticity

### Methods (key subset)
- `:GetTouchingParts() -> {BasePart}` -- Returns parts currently touching this part (requires CanTouch)
- `:GetConnectedParts(recursive: boolean?) -> {BasePart}` -- Returns parts connected via joints
- `:GetJoints() -> {Instance}` -- Returns joint instances connecting this part
- `:GetMass() -> number` -- Returns the mass of this individual part
- `:GetNetworkOwner() -> Player?` -- Returns the network owner (server only)
- `:SetNetworkOwner(player: Player?) -> ()` -- Sets network ownership (server only; nil = server)
- `:SetNetworkOwnershipAuto() -> ()` -- Lets Roblox automatically assign network ownership
- `:GetRootPart() -> BasePart` -- Returns the root part of the assembly
- `:IsGrounded() -> boolean` -- Returns true if the assembly is anchored or touching terrain
- `:Resize(normalId: Enum.NormalId, delta: number) -> boolean` -- Resizes the part along a face
- `:CanSetNetworkOwnership() -> (boolean, string?)` -- Checks if SetNetworkOwner can be called

### Events
- `.Touched:Connect(fn(otherPart: BasePart))` -- Fires when another part touches this one
- `.TouchEnded:Connect(fn(otherPart: BasePart))` -- Fires when contact with another part ends

## Budgets and Limits

- **Part count**: Experiences typically target under 10,000 visible parts for mobile performance. Use streaming and LOD for large worlds.
- **Network ownership**: Only the server can call SetNetworkOwner. The server is the default owner of anchored parts.
- **Physics step**: All non-anchored parts are simulated each physics step (~60 Hz). Anchor parts that do not need simulation.

## Common Patterns

### Anchoring static geometry

```lua
-- Parts that never move should be Anchored
local wall = Instance.new("Part")
wall.Anchored = true
wall.Size = Vector3.new(20, 10, 1)
wall.Parent = workspace
```

### Detecting touch (server-side)

```lua
local lava = workspace.LavaPart
lava.Touched:Connect(function(hit)
    local character = hit.Parent
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:TakeDamage(100)
    end
end)
```

### Network ownership for vehicles

```lua
-- Give the driver network ownership for smooth driving
local function onDriverSit(player, vehicleModel)
    for _, part in vehicleModel:GetDescendants() do
        if part:IsA("BasePart") and not part.Anchored then
            part:SetNetworkOwner(player)
        end
    end
end
```

## Pitfalls

- **Touched fires per-part**: If a character has 15 limb parts touching lava, Touched fires for each limb. Debounce or use a per-character cooldown.
- **Network ownership drift**: If the server does not explicitly set network ownership, Roblox auto-assigns it. This can cause physics jitter for multi-player interactions. Explicitly assign ownership for critical gameplay objects.
- **CFrame vs Position**: Setting Position can fail if the part collides with something. Setting CFrame always works (it teleports). Prefer CFrame for programmatic placement.
- **Massless parts**: Massless parts do not contribute to assembly mass, which is useful for accessories but can cause unexpected physics if misapplied to structural parts.
- **CanCollide false still has Touched**: A part with CanCollide=false can still fire Touched events if CanTouch=true. These are independent flags.

## Related

- [[Instance]] -- base class that BasePart inherits from
- [[Part]] -- the most common concrete BasePart subclass
- [[MeshPart]] -- BasePart subclass for custom mesh geometry
- [[Model]] -- container that groups BaseParts
- [[Attachment]] -- defines CFrame points on a BasePart for constraints
- [[WeldConstraint]] -- joins two BaseParts as a rigid body

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/BasePart.md)
