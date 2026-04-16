---
title: Foreign Types from the Embedder (Roblox Types)
type: raw-source
source_url: https://luau.org/types/roblox-types
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, roblox, embedder]
---

# Foreign Types from the Embedder

## Overview

Roblox supports a rich set of classes and data types documented at the Roblox API reference. All of them are readily available for the type checker to use by their name (e.g. `Part` or `RaycastResult`).

## Inheritance

The type system automatically recognizes inheritance hierarchies. When one type inherits from another, the type checker models this relationship and allows casting a subclass to the parent class implicitly. So you can pass a `Part` to a function that expects an `Instance`.

## Enums

Enumerated types are accessible through the `Enum` namespace:

```lua
local m: Enum.Material = part.Material
```

## Automatic Type Deduction

The type checker can infer return types from common Roblox constructors like `Instance.new` and `game:GetService`.

## Type Refinement with `IsA`

Roblox types can be refined using `IsA`:

```lua
if instance:IsA("Part") then
    -- instance :: Part
end
```

## Naming Conventions

Many of these types provide properties and methods in both `lowerCase` and `UpperCase`; the `lowerCase` variants are deprecated, and the type system will ask you to use the `UpperCase` variants instead.

## Source

- Original URL: https://luau.org/types/roblox-types
- Captured: 2026-04-16
