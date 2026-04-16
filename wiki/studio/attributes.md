---
title: Attributes
type: studio
category: studio
subcategory: patterns
owner: roblox-studio-specialist
status: draft
created: 2026-04-16
updated: 2026-04-15
sources:
  - wiki/raw/roblox-creator-docs/services/CollectionService.md
related:
  - "[[collection-service-tags]]"
  - "[[CollectionService]]"
  - "[[DataStoreService]]"
tags: [studio, patterns, attributes, instance-data]
---

# Attributes

> Typed key-value pairs attached to any Instance. Replicate from server to client. The preferred way for designers to attach data to parts without adding Value objects or extra scripts.

## Summary

Attributes are named, typed values stored directly on any `Instance`. They are set and read via `:SetAttribute()` and `:GetAttribute()`, replicate from server to client, and are serialized with the place file. They replace the older pattern of using `IntValue`/`StringValue`/`BoolValue` children for per-Instance configuration.

Attributes are editable in Studio's Properties panel under the **Attributes** section, making them accessible to designers without code changes.

## API

```lua
-- Write
part:SetAttribute("Damage", 50)
part:SetAttribute("IsCritical", true)
part:SetAttribute("DisplayName", "Fire Trap")

-- Read
local dmg: number = part:GetAttribute("Damage")
local crit: boolean = part:GetAttribute("IsCritical")

-- Get all attributes as a dictionary
local all: {[string]: any} = part:GetAttributes()

-- Listen to a specific attribute change
part:GetAttributeChangedSignal("Damage"):Connect(function()
    local newDmg = part:GetAttribute("Damage")
    print("Damage changed to", newDmg)
end)

-- Remove an attribute
part:SetAttribute("Damage", nil)
```

## Supported Types

| Type | Example |
|---|---|
| `boolean` | `true` |
| `number` | `42`, `3.14` |
| `string` | `"Fire Trap"` |
| `Vector3` | `Vector3.new(1, 2, 3)` |
| `Vector2` | `Vector2.new(0.5, 0.5)` |
| `CFrame` | `CFrame.new(0, 10, 0)` |
| `Color3` | `Color3.fromRGB(255, 0, 0)` |
| `UDim` | `UDim.new(0.5, 100)` |
| `UDim2` | `UDim2.new(0.5, 0, 0.5, 0)` |
| `Rect` | `Rect.new(0, 0, 100, 100)` |
| `NumberRange` | `NumberRange.new(1, 10)` |
| `NumberSequence` | gradient values |
| `ColorSequence` | gradient colors |
| `BrickColor` | `BrickColor.new("Bright red")` |
| `Font` | `Font.fromEnum(Enum.Font.GothamBold)` |

Instance references, tables, and functions are **not** supported as attribute values.

## Workflow: Designer-Editable Data

Attributes shine when designers need to tune per-Instance values without touching code:

1. A programmer creates a Binder (see [[collection-service-tags]]) that reads attributes on tagged Instances.
2. A designer places parts in Studio, tags them, and sets attribute values in the Properties panel.
3. At runtime, the Binder reads the attributes and applies the behavior.

```lua
-- Server script: Binder for "DamageTrap" tag
local CollectionService = game:GetService("CollectionService")

local function setupTrap(part: Part)
    local damage = part:GetAttribute("Damage") or 10
    local cooldown = part:GetAttribute("Cooldown") or 2

    local lastHit: {[Player]: number} = {}

    part.Touched:Connect(function(hit)
        local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid")
        if not humanoid then return end
        local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
        if not player then return end

        local now = os.clock()
        if lastHit[player] and now - lastHit[player] < cooldown then return end
        lastHit[player] = now

        humanoid:TakeDamage(damage)
    end)
end

for _, part in CollectionService:GetTagged("DamageTrap") do
    setupTrap(part)
end
CollectionService:GetInstanceAddedSignal("DamageTrap"):Connect(setupTrap)
```

The designer sets `Damage = 25` and `Cooldown = 1.5` on each trap part in Studio. No code changes needed.

## Attributes vs. Tags vs. Value Objects

| Mechanism | Best for | Replicates | Editable in Studio |
|---|---|---|---|
| **Attributes** | Typed config data on Instances (Damage, Speed, Color) | Yes | Yes (Properties panel) |
| **Tags** (CollectionService) | Categorizing Instances for bulk behavior | Yes | Yes (Tag Editor) |
| **Value objects** (IntValue, etc.) | Legacy; replaced by Attributes | Yes | Yes |
| **ModuleScript config** | Shared constants, centralized tuning tables | Via require | No (code only) |

## Replication

Attributes replicate from server to client. Client-set attributes are local-only and can be overwritten if the server modifies any attribute on the same Instance (the server sends the full attribute set).

## Limits

- Attribute name: max **100 bytes**.
- Total serialized attribute data per Instance: max **10 KB**.
- No Instance references, tables, or functions as values.

## Pitfalls

- **Serialization limit.** If an Instance accumulates too many or too-large attributes, writes will silently fail. Keep per-Instance attribute data well under 10 KB.
- **No tables.** Store structured data in a ModuleScript config or use multiple flat attributes. Do not try to serialize tables into a string attribute -- use a proper data layer.
- **Replication is all-or-nothing.** Changing one attribute on the server replicates the entire attribute set, overwriting any client-side attribute changes on that Instance.

## Related

- [[collection-service-tags]]
- [[CollectionService]]
- [[DataStoreService]]

## Sources

- [CollectionService reference (covers tag/attribute interplay)](../raw/roblox-creator-docs/services/CollectionService.md)
- Official docs: https://create.roblox.com/docs/reference/engine/classes/Instance#SetAttribute
