---
title: "FullShop - An In-game Currency Shop"
type: raw-source
source_url: https://devforum.roblox.com/t/fullshop-an-in-game-currency-shop/2040498
source_type: devforum
captured_at: 2026-04-15
captured_by: mechanics-rpg
category: devforum-resource
author: DevForum Community
post_date: 2022-12-15
tags: [shop, in-game-currency, inventory, purchase, leaderstats]
---

# FullShop - An In-game Currency Shop

**Source:** DevForum Community Resource

## Architecture

Core Components:
- Item display grid layout with visual feedback
- Viewport preview system (versions 2.x+)
- Currency tracking via leaderstats
- Inventory management with persistence options

## Currency Handling

- Currency names are customizable and assignable per item
- Version 1.x uses leaderstats integration
- Version 2.1 runs without datastore availability being a requirement
- Multiple currencies planned for version 3.x

## Item Catalog Setup (ObjectModule)

```lua
local module = {}
module.Price = 0
module.Object = script
module.Name = "Configure Me"
return module
```

Items placed in ReplicatedStorage or any folder, with ObjectModule tables containing Name, Price, and Object reference.

## Purchase Validation

- Version 1.x shows affordability states with glowing red outlines
- Version 2.1 includes context-aware prompts

## Data Persistence

- Inventory saving per-user
- Items equipped as tools persist in player backpacks across rejoins
- Version 3.x plans support for adding items to the inventory for events
