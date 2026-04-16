---
title: "How to Use Motor6D"
source_type: devforum-thread
url: https://devforum.roblox.com/t/how-to-use-motor6d/1436190
captured: 2026-04-15
tags: [Motor6D, animation, character-rig, tool-attachment, weld]
---

# Motor6D Usage Guide

## Definition
Motor6D is "a weld 2.0" that allows two parts to be joined while remaining animatable. It connects two BaseParts with a transform (C0/C1) that animations can manipulate.

## Setup Requirements
- Two parts (Part0 and Part1)
- Part0: The "parent" or reference part
- Part1: The part that moves relative to Part0
- C0: Offset from Part0's CFrame
- C1: Offset from Part1's CFrame

## Primary Applications

### 1. Character Rigs (Animation)
All R6 and R15 character rigs use Motor6Ds to connect body parts. The Animation system manipulates Motor6D transforms to animate characters.
- R6: 6 Motor6Ds (Torso -> Head, Arms, Legs)
- R15: 15 Motor6Ds (more granular body segments)

### 2. Tool/Weapon Attachment
Motor6Ds connect tools to character hands, enabling tool-specific animations:
```lua
local motor = Instance.new("Motor6D")
motor.Part0 = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
motor.Part1 = tool.Handle
motor.Parent = motor.Part0
```

### 3. Mechanical Movement
Turrets, rotating platforms, or any mechanism where scripted rotation is needed:
```lua
motor.C0 = CFrame.Angles(0, math.rad(angle), 0)
```

## Motor6D vs WeldConstraint

| Feature | Motor6D | WeldConstraint |
|---------|---------|----------------|
| Animatable | Yes | No |
| Requires Attachments | No (Part0/Part1) | No (Part0/Part1) |
| Use case | Character rigs, animated tools | Static assembly |
| Transform offsets | C0, C1 | None (fixed relative CFrame) |
| Can be scripted to move | Yes (change C0/C1) | No |

## Known Issues
- Limited documentation on advanced axis manipulation
- Can experience lag in server scripts (prefer client-side for visual animation)
- Proper rigging typically requires plugins (RigEdit, etc.)
