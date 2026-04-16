---
title: PhysicsSteppingMethod - Adaptive Timestepping
type: raw-source
source_url: https://devforum.roblox.com/t/new-physics-stepping-method-adaptive-timestepping/1038853
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: physics
tags: [physics, adaptive-timestepping, physics-stepping, 240hz, 60hz]
---

# PhysicsSteppingMethod - Adaptive Timestepping

## Overview

Roblox's `Workspace.PhysicsSteppingMethod` property has three options:
- **Default** = **Fixed**: identical, traditional physics behavior
- **Adaptive**: intelligent stepping rate based on simulation needs

## Stepping Frequencies

Three stepping rates supported:

| Frequency | Visualization Color | Use |
|-----------|--------------------|----|
| 60 Hz | Green | Low-intensity, slow-moving, static |
| 120 Hz | Yellow | Moderate activity |
| 240 Hz | Red | Fast movement, complex interactions |

**Previously**: All physics simulations ran at a fixed 240 Hz. Adaptive automatically throttles frequency based on simulation needs.

## How Adaptive Mode Works

The engine intelligently assigns stepping frequencies by:
- Lowering frequency when movement is mild or objects are static
- Maintaining higher frequencies for fast-moving or complex interactions
- Synchronizing to the higher frequency when low and high-frequency bodies interact

"If high-freq. bodies and low-freq bodies interact, the stepping rate will follow the higher rate"

## Performance & Accuracy Trade-offs

**Benefits**: Reduced CPU usage by freeing processing time for other operations

**Drawbacks**: "The physics won't be as accurate" compared to constant 240 Hz simulation

The system compensates by analyzing movement speed, rotation rates, and constraint complexity.

## Ideal Use Cases

Best improvements occur with: "Large amount of physics + Low Intensity simulations"

Examples:
- Games with many NPCs
- Ragdolls
- Scenes with numerous stationary objects
- Large persistent world games

## When NOT to Use

- Precision physics (racing sims, physics puzzles)
- Complex constraint systems requiring consistent timestep
- Games where determinism matters

## Testing & Tools

- Studio visualization tool: "Are Timesteps Shown" displays real-time frequency assignments
- Color-coded overlay shows per-part stepping rate

## Adaptive is Now Default

As of the Adaptive Timestepping as Default announcement, `Adaptive` is the default mode for new Workspaces.

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Maximum rate | 240 Hz |
| Medium rate | 120 Hz |
| Minimum rate | 60 Hz |
| Previous fixed rate | 240 Hz (all sims) |

## Source

Original URL: https://devforum.roblox.com/t/new-physics-stepping-method-adaptive-timestepping/1038853
Captured: 2026-04-16
