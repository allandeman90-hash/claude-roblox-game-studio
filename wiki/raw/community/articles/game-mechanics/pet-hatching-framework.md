---
title: "Pet Hatching Framework"
captured_by: mechanics-genres
source: https://devforum.roblox.com/t/pet-hatching-framework-part-1/1480291
captured_date: 2026-04-15
type: devforum-tutorial
---

# Pet Hatching Framework

## Weighted Random Selection
```lua
local function RandomPet(pets, Chance)
    local luck = math.random(Chance)
    for _, pet in ipairs(pets) do
        if luck > pet.Chance then
            luck -= pet.Chance
        else
            return pet.Name, pet.Rarity
        end
    end
end
```

## Rarity Colors
```lua
local PetRarityColors = {
    Common = Color3.fromRGB(85, 255, 127),
    Uncommon = Color3.fromRGB(223, 201, 34),
    Rare = Color3.fromRGB(255, 47, 47),
    Mythic = Color3.fromRGB(211, 79, 255),
}
```

## Egg Configuration
- Egg_Container folder with decorative parts
- Egg mesh part positioned outside container
- UI part (invisible anchor) for frame placement
- Price attribute defining cost

## Hatching Animation
- Lift egg via tween
- Rotate back-and-forth with decreasing delay
- Flash effect
- Spawn pet model with transparency transitions
- Gradually reduce blur over 1 second
