---
title: Physics Constraints Guide
type: concept
category: concepts
subcategory: physics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/physics/mechanical-constraints-overview.md
  - wiki/raw/community/articles/physics/vehicle-constraints-tutorial-devforum.md
  - wiki/raw/community/articles/physics/scripted-car-physics-devforum.md
  - wiki/raw/community/articles/physics/motor6d-usage-devforum.md
related:
  - "[[camera-modes]]"
  - "[[ui-framework-comparison]]"
tags: [physics, constraints, WeldConstraint, Motor6D, HingeConstraint, SpringConstraint, RopeConstraint, vehicle]
---

# Physics Constraints Guide

> Roblox's constraint system connects parts with physical behaviors -- rigid welds, rotating hinges, elastic springs, and more. Choosing the right constraint determines whether a mechanism feels solid or jittery.

## What It Is

Constraints are objects that define physical relationships between two parts (or attachments on parts). The physics engine enforces these relationships every frame. There are 13+ constraint types covering rigid joints, rotational joints, elastic connections, flexible links, and collision overrides.

## When to Use It

Any time two or more parts need a physical relationship: character rigs, vehicles, doors, elevators, ragdolls, rope bridges, spring platforms, mechanical contraptions.

## Constraint Reference

### Rigid Joints

| Constraint | What It Does | Needs Attachments? | Use Case |
|------------|-------------|-------------------|----------|
| **WeldConstraint** | Locks two parts in fixed relative position/orientation | No (Part0/Part1) | Assembling models, attaching props |
| **RigidConstraint** | Same as Weld but connects Attachments/Bones | Yes | Bone-based rigs, precise alignment |
| **Motor6D** | Animatable weld with C0/C1 transform offsets | No (Part0/Part1) | Character rigs, animated tools, turrets |

#### WeldConstraint

Simplest rigid joint. No attachments needed.

```lua
local weld = Instance.new("WeldConstraint")
weld.Part0 = basePart
weld.Part1 = attachedPart
weld.Parent = basePart
```

#### Motor6D

"A weld 2.0" -- joins two parts while allowing animation. All character rigs (R6: 6 motors, R15: 15 motors) use Motor6D.

```lua
local motor = Instance.new("Motor6D")
motor.Part0 = character.RightHand
motor.Part1 = tool.Handle
motor.C0 = CFrame.new(0, -1, 0)  -- offset from hand
motor.Parent = motor.Part0
```

**Motor6D vs WeldConstraint:**
- Motor6D: animatable (C0/C1 can be manipulated by Animation system or scripts), used for rigs and tools.
- WeldConstraint: static, used for model assembly. Simpler, lower overhead.

### Rotational Joints

| Constraint | Axes | Motor/Servo? | Use Case |
|------------|------|-------------|----------|
| **HingeConstraint** | 1 rotation axis | Yes | Doors, hinged lids, wheels |
| **BallSocketConstraint** | 3 rotation axes (free) | No | Shoulders, ragdoll joints |
| **CylindricalConstraint** | 1 slide + 1 rotation | Yes (both) | Telescoping + rotating mechanisms |
| **PrismaticConstraint** | 1 slide axis (no rotation) | Yes | Sliding doors, pistons, elevators |
| **UniversalConstraint** | 2 axes (perpendicular) | No | Vehicle drive shafts |

#### HingeConstraint Example (Door)

```lua
-- Attachment0 on door frame, Attachment1 on door panel
local hinge = Instance.new("HingeConstraint")
hinge.Attachment0 = doorFrame.HingeAttachment
hinge.Attachment1 = doorPanel.HingeAttachment
hinge.ActuatorType = Enum.ActuatorType.Motor
hinge.AngularVelocity = 2        -- rad/s
hinge.MotorMaxTorque = 1000      -- force limit
hinge.Parent = doorFrame
```

**Critical**: Both Attachment0 and Attachment1 must be assigned and parented to different parts. If either part is Anchored, physics movement will not occur on that part.

### Elastic Constraints

| Constraint | Behavior | Use Case |
|------------|----------|----------|
| **SpringConstraint** | Linear spring + damper (Hooke's Law) | Suspension, bouncy platforms |
| **TorsionSpringConstraint** | Rotational spring + damper | Self-righting mechanisms |

#### SpringConstraint (Vehicle Suspension)

```lua
local spring = Instance.new("SpringConstraint")
spring.Attachment0 = chassis.WheelMount
spring.Attachment1 = wheel.SpringAttachment
spring.Stiffness = 2500
spring.Damping = 250
spring.FreeLength = 2  -- studs at rest
spring.Parent = chassis
```

**Tuning rule**: Damping should be 10-20% of stiffness for stable oscillation.

### Flexible Constraints

| Constraint | Behavior | Use Case |
|------------|----------|----------|
| **RopeConstraint** | Max distance limit, optional winch | Ropes, chains, grappling hooks |
| **RodConstraint** | Fixed distance, optional tilt limits | Pendulums, fixed-length connections |
| **PlaneConstraint** | Constrains to a plane | Surface sliding |

#### RopeConstraint Example

```lua
local rope = Instance.new("RopeConstraint")
rope.Attachment0 = anchor.RopeAttachment
rope.Attachment1 = weight.RopeAttachment
rope.Length = 10           -- max distance in studs
rope.Restitution = 0.3    -- bounciness at max length
rope.Visible = true        -- render rope visual
rope.Parent = anchor
```

### Collision Override

**NoCollisionConstraint**: Prevents collisions between two specific parts while allowing collisions with the rest of the world.

```lua
local nc = Instance.new("NoCollisionConstraint")
nc.Part0 = vehicleBody
nc.Part1 = wheel
nc.Parent = vehicleBody
```

Essential for vehicle wheels that overlap with the chassis.

## Vehicle Physics Patterns

Two approaches exist for vehicle physics:

### Approach 1: Constraint-Based (Recommended)

Uses CylindricalConstraints for wheel drive and SpringConstraints for suspension. The physics engine handles forces.

**Pros**: Realistic behavior, less code, physics engine handles edge cases.
**Cons**: Less control over fine-tuned handling, Roblox friction model limits grip realism.

Key setup per wheel:
1. CylindricalConstraint (rotation motor for drive, slider for suspension travel)
2. SpringConstraint (suspension damping)
3. NoCollisionConstraint (wheel vs body)
4. Primitive cylinder for physics (not mesh)

### Approach 2: Raycast-Based (Advanced)

Custom physics using raycasting for ground detection and VectorForce for suspension/motor/friction.

**Pros**: Full control over handling, realistic friction model, customizable tire behavior.
**Cons**: More code, must handle edge cases manually, heavier on performance.

Suspension formula (Hooke's Law):
```
F = -kx - cv
```
Where k = stiffness (~2500), x = displacement, c = damping (~250), v = velocity.

Per-frame loop: raycast down from each wheel -> calculate spring force -> apply motor force -> apply friction force -> update wheel visual position.

## Pitfalls

- Anchored parts block constraint physics. Unanchor at least one part in the assembly.
- Misaligned attachments cause oscillation and jitter. Verify attachment orientations in Studio.
- Mesh wheels at high speed are unstable. Use primitive cylinders for physics, mesh for visuals.
- Missing NoCollisionConstraint between overlapping parts causes physics explosions.
- Motor6D is for animation; WeldConstraint is for static assembly. Using Motor6D where WeldConstraint suffices wastes overhead.
- SpringConstraint without damping oscillates indefinitely. Always set Damping > 0.

## Related

- [[camera-modes]]
- [[ui-framework-comparison]]

## Sources

- [Mechanical Constraints Overview](wiki/raw/community/articles/physics/mechanical-constraints-overview.md)
- [Vehicle Mechanics Using Constraints](wiki/raw/community/articles/physics/vehicle-constraints-tutorial-devforum.md)
- [Scripted Car Physics (Raycast-Based)](wiki/raw/community/articles/physics/scripted-car-physics-devforum.md)
- [Motor6D Usage Guide](wiki/raw/community/articles/physics/motor6d-usage-devforum.md)
