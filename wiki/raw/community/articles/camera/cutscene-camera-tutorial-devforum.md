---
title: "How to Create Camera Cutscenes"
source_type: devforum-tutorial
url: https://devforum.roblox.com/t/how-to-create-camera-cutscenes/1629318
captured: 2026-04-15
tags: [camera, cutscene, TweenService, CFrame, animation, cinematic]
---

# Camera Cutscene System

## Scene Data Structure
```lua
type cameraScene = {
    InitialOffset: CFrame,  -- Starting camera CFrame relative to anchor
    EndOffset: CFrame,       -- Ending camera CFrame relative to anchor
    TweenInfo: TweenInfo,    -- Duration and easing
    Delay: number            -- Pause before next scene
}
```

## Setup Steps

### 1. Anchor Point
Build a test rig (R15 recommended) with a named PrimaryPart as animation anchor.

### 2. Capture Camera Positions
Position studio camera, then get relative offsets:
```lua
print(workspace.Character.PrimaryPart.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame))
```
Copy output into InitialOffset and EndOffset fields.

### 3. Tween Configuration
```lua
TweenInfo = TweenInfo.new(7, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
```

## Playback Function
1. Store initial camera state
2. Set camera type to "Scriptable"
3. Iterate scenes with `ipairs`
4. For each scene:
   - Convert stored offset to world coords: `rootPart.CFrame:ToWorldSpace(offset)`
   - Create tween via TweenService
   - Wait for completion
5. Restore original camera properties

## Tips
- Use LocalScript (client-side only)
- Slight camera imperfections enhance naturalism
- Delay parameter creates pauses between scenes
- Always restore CameraType after animation completes
- Experiment with EasingStyle: Cubic, Sine, Quart
- Adjust duration to match cinematic timing

## Easing Styles for Cutscenes
- **Cubic/Quart**: Smooth acceleration/deceleration, cinematic feel
- **Sine**: Gentle, subtle movement
- **Linear**: Constant speed, mechanical feel
- **Quad**: Moderate acceleration, natural-looking
