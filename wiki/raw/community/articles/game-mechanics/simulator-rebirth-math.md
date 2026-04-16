---
title: "Simulator Rebirth Math Formulas"
captured_by: mechanics-genres
source: https://devforum.roblox.com/t/how-to-make-a-simulator-rebirth-math/2501720
captured_date: 2026-04-15
type: devforum-tutorial
---

# Rebirth Math Formula

## Core Formula
Cost = Starting Amount x Current Rebirth Number

## Implementation
```lua
function rebirthMath(currentAmount, rebirths)
  return currentAmount * rebirths
end

local currentAmount = 5000000
for i = 1, profile.Data.Rebirths, 1 do
  currentAmount = rebirthMath(currentAmount, i)
end
```

## Cost Progression
Starting with 5,000,000 as base:
- 1st rebirth: 5,000,000
- 2nd rebirth: 10,000,000
- 3rd rebirth: 30,000,000

Each subsequent rebirth multiplies the previous requirement by the new rebirth number, creating exponential cost growth.
