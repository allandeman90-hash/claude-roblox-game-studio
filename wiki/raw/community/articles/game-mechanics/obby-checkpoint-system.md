---
title: "Obby Checkpoint System and Kill Bricks"
captured_by: mechanics-genres
source: https://devforum.roblox.com/t/how-to-create-an-obby-part-1-checkpoints-system-and-lava-bricks/874825
captured_date: 2026-04-15
type: devforum-tutorial
---

# Obby Checkpoint System

## Checkpoint Setup
- Create neon white parts (Size: 5,1,5), anchored
- Organize in Workspace folder named "Checkpoints"
- Name sequentially: "Checkpoint1", "Checkpoint2", etc.

## Core Script (ServerScriptService)
- GoToCheckpoint: Teleports character via CFrame + CFrame.new(0,1,0) offset
- PlayerAdded: Creates leaderstats with IntValue "Stage", loads from DataStore
- Touched: Detects checkpoint contact, verifies it equals next expected stage

## Kill Brick Script
```lua
local part = script.Parent
part.Touched:Connect(function(touch)
    local hum = touch.Parent:FindFirstChild("Humanoid")
    if hum and hum.Health > 0 then
        hum.Health = 0
    end
end)
```

## Best Practice: CollectionService Approach
```lua
local collectionService = game:GetService("CollectionService")
for number, killBrick in collectionService:GetTagged("KillBrick") do
    killBrick.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then humanoid.Health = 0 end
    end)
end
```
