---
title: Create Spinning Objects
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/create-spinning-objects
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, physics, angularvelocity, hingeconstraint, applyangularimpulse, torque, constraints]
difficulty: intermediate
---

# Create Spinning Objects

**Spinning objects** are objects that rotate on one or more axes within the 3D space. Using Roblox's simulation engine, you can make objects spin and interact with their environment in a way that emulates real-world physical behavior.

This tutorial explains:
- Using an `AngularVelocity` mover constraint to spin an entire assembly at a constant angular velocity.
- Using a `HingeConstraint` mechanical constraint to spin a part within an assembly as the rest remains stationary.
- Using `BasePart:ApplyAngularImpulse()` to spin an assembly with an initial impulse of angular force.

## Steps

### Angular motion and physical forces

**Angular motion** (rotational motion) is movement around a fixed point or axis.

- **Torque**: Measure of physical force causing rotation, measured in Rowton-studs
- **Angular velocity**: How fast an object rotates, measured in radians per second
- **2π radians (~6.283)** = one full rotation
- **Moment of inertia**: Larger objects need more torque to accelerate at the same rate

### Use AngularVelocity constraints

`AngularVelocity` objects are mover constraints that apply torque on an entire assembly to maintain a constant angular velocity.

**Add attachment:**
1. Insert a **block** part into **Workspace**.
2. Insert an `Attachment` into the part.
3. Rename to `SpinAttachment`.

**Configure constraint:**
1. Enable **Show Constraint Details** from View menu.
2. Insert an `AngularVelocity` constraint into the part.
3. In Properties:
   - Set **Attachment0** to `SpinAttachment`
   - Set **AngularVelocity** to `0, 6, 0` (6 radians/sec on Y axis — about 1 full rotation/sec)
   - Set **MaxTorque** to `1000` (Rowton-studs)
   - Keep **RelativeTo** as **World**

> Negative values spin clockwise; positive values spin counterclockwise.
> Larger / heavier objects need more `MaxTorque` (sometimes 300,000+ Rowton-studs).

### Use HingeConstraint

`HingeConstraint` objects allow two attachments to rotate around one axis. When `ActuatorType = Motor`, the constraint applies torque to reach and maintain a constant angular velocity. If one assembly is anchored, the other spins while the anchor stays still.

**Configure attachments:**
1. Insert an `Attachment` into both the **Head** (propeller) and **Base** parts.
2. Rename `HeadAttachment` and `BaseAttachment`.
3. Rotate both so their primary axis (yellow arrow) points **upward** on Y.
4. Move `BaseAttachment` to the top of Base, and `HeadAttachment` to the bottom edge of the propeller.

**Configure constraint:**
1. Insert a `HingeConstraint` into the **Head**.
2. In Properties:
   - Set **Attachment0** to `BaseAttachment`
   - Set **Attachment1** to `HeadAttachment`
   - Set **ActuatorType** to **Motor**
   - Set **MotorMaxTorque** to `1000`
   - Set **AngularVelocity** to `3` (3 radians/sec)

### Use ApplyAngularImpulse

`BasePart:ApplyAngularImpulse()` applies torque to obtain an initial angular velocity before decelerating.

```lua
local part = script.Parent
local impulse = Vector3.new(0, math.random(0, 100), 0)
part:ApplyAngularImpulse(impulse)
```

## Key Concepts

- **AngularVelocity constraint**: Spins an entire assembly at constant velocity
- **HingeConstraint**: Rotates one part relative to another along a fixed axis
- **ApplyAngularImpulse**: One-shot angular force
- **Rowton-studs**: Torque units
- **Radians per second**: Rotation rate (2π ≈ 6.283 per full rotation)
- **MaxTorque / MotorMaxTorque**: Upper limit of force applied
- **ActuatorType = Motor**: Enables constant-velocity driving (vs free-rotation)
- **Primary axis (yellow)**: Defines the rotation axis
- **Moment of inertia**: Larger = needs more torque to spin

## Notes

- Use AngularVelocity for freely spinning objects
- Use HingeConstraint for propellers, wheels, doors hinged to a stationary base
- Use ApplyAngularImpulse for instantaneous spin events (explosions, wind gusts)
- Remember that 2π radians = one full rotation per unit time
- Adjust `MaxTorque` based on object mass and oppositional forces (friction, gravity)

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/create-spinning-objects
Captured: 2026-04-16
