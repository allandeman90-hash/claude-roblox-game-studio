---
title: Create Moving Objects
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/create-moving-objects
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, physics, linearvelocity, prismaticconstraint, applyimpulse, mover-constraint, constraints]
difficulty: intermediate
---

# Create Moving Objects

**Moving objects** are objects that move on one or more axes within the 3D space. Using the built-in power of Roblox's simulation engine, you can make objects move and interact with their environment in a way that emulates real-world physical behavior.

This tutorial explains:
- Using a `LinearVelocity` mover constraint to move an entire assembly at a constant linear velocity.
- Using a `PrismaticConstraint` to constrain an assembly to a single axis and move it relative to a point.
- Using `BasePart:ApplyImpulse()` to move an assembly with an initial impulse of force.

## Steps

### Linear motion and physical forces

**Linear motion** is movement along an axis. According to Newton's first law, stationary objects remain stationary and moving objects remain in motion with a constant velocity unless they are acted on by an external force.

- **Force**: The direction and magnitude of a physical push or pull, measured in Rowtons
- **Acceleration**: A change in velocity
- **Linear velocity**: How fast an object changes its position along an axis, measured in studs per second
- **Studs**: Roblox's primary physical units for measuring length (about 28cm each)

### Use LinearVelocity constraints

`LinearVelocity` objects are a type of mover constraint that apply force on an entire assembly to maintain a constant linear velocity. Without locking the assembly's position to an axis, it's free to rotate as it collides with other objects.

**Add attachment:**
1. Insert an `Attachment` into your part.
2. Rename to `MoveAttachment`.

**Configure constraint:**
1. Insert a `LinearVelocity` constraint into the part.
2. In Properties:
   - Set **Attachment0** to your attachment
   - Set **MaxForce** to `5000` (Rowtons)
   - Keep **RelativeTo** as **World**
   - Set **VelocityConstraint** to **Line**
   - Set **LineDirection** to `-1, 0, 0` (negative X axis)
   - Set **LineVelocity** to `15` (studs per second)

### Use PrismaticConstraint

`PrismaticConstraint` objects create a rigid joint between two attachments, allowing their parent assemblies to move along one axis **relative to each other**. By locking position to a single axis, assemblies rotate only if they rotate together.

When `ActuatorType` is set to **Motor**, this constraint applies force to reach and maintain a constant linear velocity.

**Configure attachments:**
1. Insert an attachment into the moving part (rename to `LogAttachment`).
2. Insert an attachment into the anchored reference part (rename to `AnchorAttachment`).
3. Rotate both attachments so their primary axis (yellow arrow) faces the desired direction.
4. Reposition `AnchorAttachment` so both are aligned on the movement axis.

**Configure constraint:**
1. Insert a `PrismaticConstraint` into the moving part.
2. Set **Attachment0** to `AnchorAttachment`.
3. Set **Attachment1** to `LogAttachment`.
4. Set **ActuatorType** to **Motor**.
5. Set **MotorMaxForce** to `50000`.
6. Set **Velocity** to `40`.

### Use ApplyImpulse

`BasePart:ApplyImpulse()` applies force on an entire assembly to obtain an initial linear velocity before slowing to a stop when there are oppositional forces. Useful for explosions, impact collisions, jump pads, etc.

```lua
local volume = script.Parent

local function onTouched(other)
    local impulse = Vector3.new(0, 2500, 0)
    local character = other.Parent
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid and other.Name == "LeftFoot" then
        other:ApplyImpulse(impulse)
    end
end

volume.Touched:Connect(onTouched)
```

## Key Concepts

- **LinearVelocity constraint**: Applies force to maintain constant velocity; free rotation allowed
- **PrismaticConstraint**: Rigid joint locking movement to one axis relative to another attachment
- **ApplyImpulse**: One-shot force application; best for instantaneous events
- **Rowtons**: Roblox's force units
- **Studs**: Roblox length units (~28cm)
- **MaxForce**: Upper limit on how much force the engine can apply
- **RelativeTo (World / Attachment)**: Reference frame for direction
- **ActuatorType = Motor**: Enables constant-velocity driving
- **Attachment primary axis (yellow)**: Direction of movement for prismatic
- **Attachment secondary axis (orange)**: Reference direction

## Notes

- Heavier objects need more MaxForce to reach target velocity
- Use LinearVelocity for free-rotating physics objects (lily pads, bumper cars)
- Use PrismaticConstraint for rigid linear movement (sliding doors, elevators)
- Use ApplyImpulse for one-time events (jump pads, explosions)
- Enable **Show Constraint Details** from View menu to see arrows

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/create-moving-objects
Captured: 2026-04-16
