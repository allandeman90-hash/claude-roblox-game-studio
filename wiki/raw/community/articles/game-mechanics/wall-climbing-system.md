# Wall Climbing System (With Wall Switching)

**Source:** https://devforum.roblox.com/t/creating-a-wall-climbing-system-with-wall-switching/3645787
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Tutorial by Doomcolp implementing wall climbing with wall-switching for PC and mobile.

## Architecture

- LocalScript (Client) for input/movement
- Climb module for climbing logic
- RemoteEvent for server-client communication
- Raycast system for wall detection

## Raycast Setup

```lua
FilterDescendantsInstances = {Character}
FilterType = Enum.RaycastFilterType.Exclude
```

## Three Module Functions

1. **Init()** — detects walls ahead, anchors character
2. **Start()** — manages continuous climbing based on input
3. **Switch()** — transitions between adjacent walls/surfaces

## Movement Logic

`CLIMB_MULTIPLIER = 0.25` applied to directional vectors. Derives from HumanoidRootPart CFrame (UpVector, RightVector, LookVector).

```lua
HumanoidRootPart.CFrame = CFrame.lookAt(
    HumanoidRootPart.Position,
    Cast.Position - Cast.Normal
) + KeyMovement * CLIMB_MULTIPLIER
```

## Wall Switching

Two specialized raycasts:
1. **Adjacent Ray** — forward-and-left to detect perpendicular wall sides
2. **Perpendicular Ray** — directly leftward to detect adjacent walls

Prioritizes adjacent walls; falls back to perpendicular surfaces.

## Mobile Support

Detects input via `UserInputService.KeyboardEnabled`. Uses `Humanoid.MoveDirection` with Vector3 dot product (targeting 1) for thumbstick direction.

## Limitations

- Jittery movement noted
- Animations absent
- Server-side anchoring requires client-side redundancy for position sync
