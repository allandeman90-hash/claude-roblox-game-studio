---
title: "NPC Boss Attack System"
source_url: "https://devforum.roblox.com/t/npc-boss-attack-system/1940539"
source_type: devforum-discussion
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# NPC Boss Attack System

Range-based boss attack pattern with cooldowns.

## Range Detection
```lua
local Distance = (Boss.HumanoidRootPart.Position
    - Character.HumanoidRootPart.Position).Magnitude

if Distance <= Range then
    -- Attack logic
end
```

## Attack Loop
```lua
local function Attack1()
    for i, Player in pairs(Players:GetPlayers()) do
        local Character = Player.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local Distance = (Boss.HumanoidRootPart.Position
                - Character.HumanoidRootPart.Position).Magnitude
            if Distance <= Range then
                Character:FindFirstChild("Humanoid").Health -= 10
            end
        end
    end
end

while task.wait(10) do
    Attack1()
end
```

## Scope
Covers basic range detection, damage application, 10-second cooldown intervals.
Does not cover attack pattern variety, telegraph/windup, or phase transitions.
