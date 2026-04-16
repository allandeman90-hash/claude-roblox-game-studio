---
title: "Roblox Mechanical Constraints Overview"
source_type: official-docs
url: https://create.roblox.com/docs/physics/mechanical-constraints
github_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/physics/mechanical-constraints.md
captured: 2026-04-15
tags: [constraints, physics, BallSocket, Hinge, Prismatic, Spring, Rope, Rod, Weld, Motor6D]
---

# Roblox Mechanical Constraints Reference

## Constraint Types (13 primary)

### Rotational/Positional

1. **BallSocketConstraint**: Forces two attachments into the same position, allows free rotation about all three axes with optional limits. Good for shoulders, hips, ragdoll joints.

2. **HingeConstraint**: Two attachments rotate about one axis. Optional motor or servo power. Good for doors, hinged lids, wheels.

3. **PrismaticConstraint**: Two attachments slide along one axis but cannot rotate. Optional motor power. Good for sliding doors, pistons, elevators.

4. **CylindricalConstraint**: Attachments slide along one axis and rotate about another axis. Optional angular and/or linear power. Good for telescoping/rotating mechanisms.

5. **UniversalConstraint**: Ensures two axes on two assemblies remain perpendicular. Good for vehicle power transmission (drive shafts).

### Elastic

6. **SpringConstraint**: Applies force based on spring and damper behavior with optional min/max length. Good for suspension, bouncy platforms.

7. **TorsionSpringConstraint**: Applies torque based on relative angle and angular velocity. Good for rotational springs, self-righting mechanisms.

### Rigid

8. **WeldConstraint**: Connects two BaseParts, maintains same relative position/orientation. No Attachments needed (uses Part0/Part1). Good for assembling models, attaching tools.

9. **RigidConstraint**: Connects two Attachments or Bones, maintains relative position/orientation. Good for bone-based rigs, precise attachment points.

10. **RodConstraint**: Keeps two attachments separated by a defined length with optional rotational tilt limits. Good for pendulums, fixed-distance connections.

### Flexible

11. **RopeConstraint**: Prevents two attachments from separating further than a defined length. Optional winch behavior (extending/contracting). Good for ropes, chains, grappling hooks.

12. **PlaneConstraint**: Moves two attachments into a position/orientation along a plane. Good for sliding along surfaces.

### Collision

13. **NoCollisionConstraint**: Prevents collisions between two specific parts while allowing collisions with the rest of the world. Good for overlapping visuals, vehicle wheel-body collision avoidance.

## Creation Methods

- **Model tab** toolbar constraint picker
- **Explorer window** insert from dropdown menu
- **Script**: `Instance.new("HingeConstraint")` etc.

## Important Notes

- Most constraints require connections to **Attachments** or **Bones** (Attachment0/Attachment1)
- Exceptions: WeldConstraint and NoCollisionConstraint link BaseParts directly via Part0/Part1
- If either part connected to a constraint is **Anchored**, physics movement will not occur on that part
- Attachment orientation matters -- misaligned attachments cause unexpected behavior
