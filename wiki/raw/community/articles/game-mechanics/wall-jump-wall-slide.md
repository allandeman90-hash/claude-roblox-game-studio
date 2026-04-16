# Wall Jump and Wall Slide Implementation

**Source:** https://devforum.roblox.com/t/making-wall-jump-and-wall-slide/1353049
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

DevForum discussion on implementing wall mechanics using BodyVelocity for sliding and Humanoid state tracking for jumping.

## Wall Slide

Uses a BodyVelocity to slow downward motion:

```lua
local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Velocity = Vector3.new(0, -10, 0)
BodyVelocity.Parent = player.Character.HumanoidRootPart
```

Additional effects: animation playback, smoke particles from hands.

## Wall Jump

Leverages state transitions and input detection:

```lua
function onJumpRequest()
    if canDoubleJump and not hasDoubleJumped then
        hasDoubleJumped = true
        humanoid.JumpPower = oldPower * DOUBLE_JUMP_POWER_MULTIPLIER
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
```

## State Management

- `canDoubleJump` toggles on entering freefall
- `hasDoubleJumped` resets on landing
- Listens to Humanoid StateChanged between Landed and Freefall

## Script Placement

StarterPlayer > StarterCharacterScripts (LocalScript).
