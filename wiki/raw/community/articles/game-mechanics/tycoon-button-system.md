---
title: "Tycoon Button System"
captured_by: mechanics-genres
source: https://devforum.roblox.com/t/tycoon-button-system/1923669
captured_date: 2026-04-15
type: devforum-discussion
---

# Tycoon Button System

## Button Structure
- ButtonPart (visual representation)
- Price.Value (cost to purchase)
- Item.Value (corresponding item to spawn)
- Optional Dependency (unlock requirement)

## Purchase Logic
```lua
if Player:WaitForChild("leaderstats").Money.Value >= v.Price.Value then
  -- deduct money, clone item, hide button
end
```

## Dependency Chain System
Buttons remain hidden until prerequisite items are purchased.
- Original: WaitForChild() to detect dependency item in BroughtItems folder
- Improved: Bool value listener that marks when target item gets bought

## Progression Unlocking
When purchased:
1. Player loses money equal to button price
2. Item clones into BroughtItems folder
3. Button becomes invisible (Transparency = 1, CanCollide = false)
4. Dependent buttons appear
