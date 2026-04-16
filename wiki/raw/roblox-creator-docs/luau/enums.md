---
title: Enums
type: raw-source
source_url: https://create.roblox.com/docs/luau/enums
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, enums, datatypes, enum-items]
---

# Enums

> **Info:** Enums are not a [built-in Luau type](https://luau.org/typecheck#builtin-types) and they exist only in Roblox, but they're conceptually similar to other Luau data types and are something you'll work with frequently in Roblox development.

The **enumeration** data type, or `Enum`, is a fixed list of items. You can access enums through the global object called `Enum`. For a full list and their respective items, see [Enums](/reference/engine/enums).

## Enum items

To get all items of an enum, call the `GetEnumItems()` method on it. The following code sample demonstrates how to call `GetEnumItems()` on the `Enum.PartType` enum.

```lua
local partTypes = Enum.PartType:GetEnumItems()

for index, enumItem in partTypes do
	print(enumItem)
end

--[[
	Enum.PartType.Ball
	Enum.PartType.Block
	Enum.PartType.Cylinder
	Enum.PartType.Wedge
	Enum.PartType.CornerWedge
]]
```

## Data type

The `EnumItem` is the data type for items in enums. An `EnumItem` has three properties:

- `Name` — The name of the `EnumItem`.
- `Value` — The numerical index of the `EnumItem`.
- `EnumType` — The parent `Enum` of the `EnumItem`.

Some properties of objects can only be items of certain enums. For example, the `Shape` property of a `Part` object is an item of the `Enum.PartType` enum. The following code sample demonstrates how to print the properties of the `Enum.PartType.Cylinder` enum item.

```lua
print(Enum.PartType.Cylinder.Name) --> "Cylinder"
print(Enum.PartType.Cylinder.Value) --> 2
print(Enum.PartType.Cylinder.EnumType) --> PartType
```

To assign an `EnumItem` as the value of a property, use the full `Enum` declaration. You can also use the item's `Name` property as a string.

```lua
local Workspace = game:GetService("Workspace")

local part = Instance.new("Part") -- Create a new part

part.Shape = Enum.PartType.Cylinder -- By full enum item declaration (best practice)
part.Shape = "Cylinder" -- By enum item's name as a string

part.Parent = Workspace
```

## Source

Original URL: https://create.roblox.com/docs/luau/enums
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/luau/enums.md
Captured: 2026-04-16
