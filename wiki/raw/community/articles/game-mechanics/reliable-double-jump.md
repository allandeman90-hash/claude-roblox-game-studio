# Reliable Customisable Double Jump System

**Source:** https://devforum.roblox.com/t/reliable-customisable-double-jump-system/1853471
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Community resource providing a reliable double jump system with configurable multipliers and extra jump counts. Works regardless of device performance/lag.

## Configuration

```lua
local JUMP_MULTI = 2        -- Jump height multiplier
local MAX_EXTRA_JUMPS = 1   -- 0 = single jump; 1 = double jump
```

## State Tracking

- `boostCount`: counts additional jumps performed
- `lastJump`: tracks previous frame's jump input

## Jump Reset

First RenderStepped connection monitors ground contact:
- Checks `Humanoid.FloorMaterial == Material.Air`
- Resets multiplier when airborne or boost count at zero

## Boost Function

1. Checks if max jumps exceeded
2. Applies multiplier on first boost
3. Increments counter
4. Forces `Enum.HumanoidStateType.Jumping`

## Detection

Second RenderStepped monitors jump input while airborne. Compares current vs previous jump state to detect new attempts.

## Key Advantage

Device-performance independent. Works on laggy clients where StateChanged events might be unreliable.
