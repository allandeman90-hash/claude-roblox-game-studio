---
title: "In Depth Scripted Car Physics"
source_type: devforum-tutorial
url: https://devforum.roblox.com/t/in-depth-scripted-car-physics/3915628
captured: 2026-04-15
tags: [vehicle-physics, raycasting, suspension, hookes-law, friction, scripted-physics]
---

# Scripted Car Physics (Raycast-Based Approach)

## Overview
Custom car physics from scratch using raycasting, without SpringConstraints. Covers suspension, wheel positioning, movement, friction, and steering.

## Suspension System (Hooke's Law)
```
F = -kx - cv
```
Where k = stiffness, x = displacement, c = damping constant, v = velocity.

Constants:
- STIFFNESS = 2500
- DAMPING = 250
- REST_LENGTH = 2 studs
- WHEEL_RADIUS = 1.5 studs

Rule of thumb: Stiffness should be ~10x damping for stable suspension.

## Raycasting for Ground Detection
Rays shoot downward from wheel attachment points. Ray distance = REST_LENGTH + WHEEL_RADIUS. Forces only apply when wheels contact ground.

## Architecture

### Per-Frame Loop (Heartbeat)
For each wheel:
1. Raycast to ground
2. Calculate displacement from rest length
3. Apply spring force (VectorForce constraints)
4. Apply motor force (throttle along forward direction)
5. Apply friction force (opposes sideways sliding)
6. Update wheel weld offset for visual positioning

### Velocity at Wheel Points
Combines linear and angular velocity using cross product.

### Motor Force
Throttle (-1 to 1) along car's forward direction. Speed capped via dot product against maximum speed.

### Friction
```
F = mu * N
```
Where mu = friction coefficient, N = normal force.
- Calculates velocity perpendicular to wheel direction
- Applies opposing friction force when sliding
- Only applies when wheels touch ground

## Advanced: Wheel Casting
10 rays around wheel circumference detect ground contact earlier, providing smoother response on curved surfaces.

## Implementation Flow
1. Create attachments on body at wheel positions
2. Attach VectorForces to each attachment
3. Each Heartbeat: raycast, compute forces, apply forces, update visuals
