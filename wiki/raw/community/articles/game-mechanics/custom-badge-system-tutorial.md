---
title: "Creating a Custom Badge System"
source_url: "https://devforum.roblox.com/t/creating-a-custom-badge-system/1735737"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: achievement-system
---

# Creating a Custom Badge System

## BadgeService Core

```lua
local badgeService = game:GetService("BadgeService")

local function giftBadge(plr, badgeId)
    badgeService:AwardBadge(plr, badgeId)
end
```

## Disabling Default Badge GUI

Replace Roblox standard notification via LocalScript in StarterGui:

```lua
local starterGui = game:GetService("StarterGui")
starterGui:SetCoreGuiEnabled("BadgesNotificationsActive", false)
```

## Client-Server Communication

Server fires RemoteEvent to notify clients:

```lua
-- Server
local replicatedStorage = game:GetService("ReplicatedStorage")
local event = replicatedStorage:WaitForChild("GiftBadge")
event:FireClient(plr, badgeId)

-- Client
event.OnClientEvent:Connect(function(badgeId)
    -- Custom UI display logic
end)
```

## Custom Notification UI

Populate badge metadata from MarketplaceService:

```lua
gui.namegui.Text = marketPlaceService:GetProductInfo(badgeId).Name
```
