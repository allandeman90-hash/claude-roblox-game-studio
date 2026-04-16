---
title: "Level Up System Math"
type: raw-source
source_url: https://devforum.roblox.com/t/level-up-system-math/1474055
source_type: devforum
captured_at: 2026-04-15
captured_by: mechanics-rpg
category: devforum-tutorial
author: DevForum Community
post_date: 2021-09-19
tags: [xp, level-math, quadratic-formula, inverse-xp, constant-time-levelup]
---

# Level Up System Math

**Source:** DevForum Community Tutorial

## Core Concept

Efficient mathematical approach to calculating level progression without looping through each level individually.

## Key Formulas

### Total XP Required to Reach a Level (Quadratic)

```
totalXpNeeded = ((xpPerLevel / 2) * (level ^ 2)) + ((xpPerLevel / 2) * level)
```

### Calculate Level from Experience (Inverse)

```
level = ((-xpPerLevel / 2) + math.sqrt(((xpPerLevel / 2) ^ 2) + ((xpPerLevel * 2) * totalXp))) / xpPerLevel
```

## Implementation

```lua
function GetRequiredXP(level)
    return ((xpPerLevel / 2) * (level ^ 2)) + ((xpPerLevel / 2) * level)
end

local xpToCurrentLevel = GetRequiredXP(level.Value)
local totalXp = xpToCurrentLevel + xp.Value
local predictedLevel = math.min(math.floor(
    ((-xpPerLevel / 2) + math.sqrt(((xpPerLevel / 2) ^ 2) +
    ((xpPerLevel * 2) * totalXp))) / xpPerLevel), levelCap)
local levelsGained = predictedLevel - level.Value

if levelsGained > 0 then
    local xpTaken = GetRequiredXP(predictedLevel) - xpToCurrentLevel
    xp.Value -= xpTaken
    level.Value = predictedLevel
end
```

## Key Advantage

Calculates multiple simultaneous level-ups in constant time, eliminating the need to iterate through each level separately. Uses Desmos graphing calculator to visualize and verify curves before coding.
