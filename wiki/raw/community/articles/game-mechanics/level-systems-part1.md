---
title: "Level Systems (Part 1)"
type: raw-source
source_url: https://devforum.roblox.com/t/level-systems-part-1/296963
source_type: devforum
captured_at: 2026-04-15
captured_by: mechanics-rpg
category: devforum-tutorial
author: DevForum Community
post_date: 2019-06-23
tags: [xp, level-up, progression, experience-curve, linear-scaling]
---

# Level Systems (Part 1)

**Source:** DevForum Community Tutorial

## XP Formula

Linear scaling model for experience requirements:

**Formula:** `constant + Level * ExperienceScale`

```lua
local Level = 0
local constant, ExperienceScale = 100, 10
local EF = (function(level) return constant + (level * ExperienceScale) end)
```

This ensures level 0 needs 0 experience to reach level 1.

## Level-Up Algorithm

Overflow handling through recursion:

```lua
local function AddExp(amount)
    if (currentExperience + amount) > EF(Level) then
        local LeftOverExp = (currentExperience + amount) - EF(Level)
        Level = Level + 1
        currentExperience = 0
        AddExp(LeftOverExp)
    elseif (currentExperience + amount) == EF(Level) then
        Level = Level + 1
        currentExperience = 0
    else
        currentExperience = currentExperience + amount
    end
end
```

## Progress Bar Scaling

UI representation formula: `(currentExperience / EF(Level)) * BarDimension`

## Community Feedback

- Stack overflow risks with large experience amounts (recursive approach)
- Incorrect level-up calculations when updating the experience function mid-calculation
- Part 2 planned for sanity checks
