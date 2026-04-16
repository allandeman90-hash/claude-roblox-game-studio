---
title: "How to Save Inventory Items in DataStores"
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-save-items-in-datastores/1416618
source_type: devforum
captured_at: 2026-04-15
captured_by: mechanics-rpg
category: devforum-tutorial
author: DevForum Community
post_date: 2021-08-15
tags: [datastore, inventory, saving, guid, serialization]
---

# How to Save Inventory Items in DataStores

**Source:** DevForum Community Tutorial

## Core Concept

Save references to items along with their attributes, not item instances directly.

## Data Structure Approaches

### Method 1: Item Name as Key

```lua
["Inventory"] = {
   ["Sword"] = {
       ["damage"] = 5,
       ["cooldown"] = 1
   }
}
```

**Limitation:** Cannot store multiple swords with different stats.

### Method 2: GUID-Based (Recommended)

```lua
["Inventory"] = {
   ["94b717b2-d54f-4340-a504-bd809ef5bf5c"] = {
       ["Item"] = "Sword",
       ["damage"] = 5,
       ["cooldown"] = 1
   }
}
```

Allows unique items and facilitates future systems like trading.

## Loading Items on Player Join

```lua
for i, v in pairs(RecData["Inventory"]) do
    RS.Items[v["Item"]]:Clone().Parent = plr.Backpack
end
```

## Adding Items

```lua
function AddItem(plr, item, damage, cooldown)
    data[plr][HttpService:GenerateGUID(false)] = {
        ["Item"] = item,
        ["damage"] = damage,
        ["cooldown"] = cooldown
    }
end
```

## Saving on Player Exit

```lua
game.Players.PlayerRemoving:Connect(function(plr)
    DS:SetAsync("UserID_" .. (plr.userId), data[plr])
end)
```

## Best Practices

- Maintain an in-memory data table to avoid repeated GetAsync calls
- Implement retry logic for failed data requests
- Use module scripts for production systems
- Avoid storing inventory in folders or StringValues
