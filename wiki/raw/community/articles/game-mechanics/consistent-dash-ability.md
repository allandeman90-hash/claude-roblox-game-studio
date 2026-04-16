# Consistent Dash Ability Implementation

**Source:** https://devforum.roblox.com/t/how-do-i-achieve-a-dash-ability-that-moves-a-consistent-distance-each-time/2305209
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

DevForum discussion on creating dash abilities that travel a consistent distance regardless of air/ground state.

## BodyPosition Method

```lua
local function DashForward(RootPart: BasePart)
    local bodyPos = Instance.new('BodyPosition')
    bodyPos.MaxForce = Vector3.new(1000000, 0, 1000000)
    bodyPos.P = 100000
    bodyPos.D = 2000
    bodyPos.Position = (RootPart.CFrame * CFrame.new(0, 0, -20)).Position
    bodyPos.Parent = RootPart
    task.spawn(function()
        task.wait(0.2)
        bodyPos:Destroy()
    end)
end
```

Fine-tune P value for desired dash speed. D for damping.

## LinearVelocity (Recommended Modern Approach)

LinearVelocity provides superior control and consistency. Prevents inconsistencies from gravity and air/ground differences.

## Gravity Cancellation

Set Y-component of MaxForce to non-zero to counteract gravity during airborne dashes.

## Key Insight

Both approaches enable predictable distances regardless of grounded/airborne state. LinearVelocity is preferred for new implementations as BodyPosition/BodyVelocity are legacy.
