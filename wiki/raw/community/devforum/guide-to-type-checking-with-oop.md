---
title: Guide to Type-Checking with OOP
type: raw-source
source_url: https://devforum.roblox.com/t/guide-to-type-checking-with-oop/1997394
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: MagmaBurnsV
post_date: 2022-09-27
tags: [oop, type-checking, luau, metatables, inheritance, strict-mode]
---

# Guide to Type-Checking with OOP

**Author:** MagmaBurnsV
**Posted:** September 27, 2022 (Updated March 4, 2023)

## Overview

This tutorial addresses gaps in Luau's OOP type-checking documentation by presenting a refined method for typing classes using metatables. The guide assumes basic OOP familiarity.

## Core Pattern

### Single Class (Car Example)

The fundamental approach combines a `self` type definition with `typeof()` and `setmetatable()`:

```lua
local Car = {}
Car.__index = Car

type self = {
    Speed: number
}

export type Car = typeof(setmetatable({} :: self, Car))

function Car.new(): Car
    local self = setmetatable({} :: self, Car)
    self.Speed = 100
    return self
end

function Car.Boost(self: Car): ()
    self.Speed += 50
end

return Car
```

**Key points:**
- The `self` type captures property structure
- `typeof(setmetatable())` captures metatable relationship
- Methods use dot notation with explicit `self: Car` typing (not colon syntax)

### Inheritance (Truck Extends Car)

Inheritance uses the intersection operator (`&`) to combine types:

```lua
export type Truck = typeof(setmetatable({} :: self, Truck)) & Car.Car

function Truck.new(): Truck
    local self: Truck = setmetatable(Car.new() :: any, Truck)
    self.Gas = 200
    return self
end

setmetatable(Truck, Car)
return Truck
```

## Alternative Approach (Composition-Focused)

A simpler pattern leveraging `typeof()` for automatic type inference:

```lua
export type Car = typeof(Car.new(...))
```

This approach:
- Requires fewer type annotations
- Works excellently with composition over inheritance
- Methods must be defined *after* the type export statement

## Discussion Highlights

- **Private fields:** The `{} & any` pattern allows undocumented fields without type exposure
- **Strict mode:** Type ascription prevents adding fields to tables without explicit type definitions
- **Limitations:** Current approaches lack true private members and encapsulation

The tutorial emphasizes that Luau's type system requires creative metatable manipulation, acknowledging the complexity involved.

## Source

Original URL: https://devforum.roblox.com/t/guide-to-type-checking-with-oop/1997394
Captured: 2026-04-16
