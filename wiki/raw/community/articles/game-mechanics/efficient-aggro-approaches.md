---
title: "Efficient Aggro Approaches"
source_url: "https://devforum.roblox.com/t/efficient-aggro-approaches/501394"
source_type: devforum-discussion
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# Efficient Aggro Approaches

Discussion on NPC aggro mechanics comparing centralized vs distributed scripting.

## Magnitude Checks
Primary recommended method: distance calculation over collision detection.
`DistanceFromCharacter(part)` returns total studs distance.

## Centralized Script Approach
Single master script monitors all NPCs:

```lua
local Npcs = game.Workspace.Npcs:GetChildren()
local AmountOfStuds = 10

for _, Npc in pairs(Npcs) do
    while true do
        for _, Player in pairs(game.Players:GetChildren()) do
            local Distance = Player:DistanceFromCharacter(Npc.Torso.Position)
            if Distance < AmountOfStuds then
                Npc:MoveTo(Player.Character.HumanoidRootPart)
            end
        end
    end
end
```

## Performance
Recommended yielding ~100ms (wait(0.1)) every loop to prevent server resource hogging.

## Not Covered
- Deaggro mechanics
- Target priority systems
- Leash distances
- Spatial hashing
