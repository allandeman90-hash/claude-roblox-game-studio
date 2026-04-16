---
title: export type
type: luau-feature
category: luau
subcategory: type-system
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/types/generics.md
  - wiki/raw/roblox-creator-docs/luau/type-checking.md
related:
  - "[[type-annotations]]"
  - "[[generic-types]]"
  - "[[module-scripts]]"
  - "[[strict-vs-nonstrict]]"
tags: [luau, type-system, modules]
---

# `export type`

> Luau keyword for sharing type definitions across module boundaries. `export type Foo = { ... }` makes `Foo` available to any script that `require`s the module.

## Syntax

### Declaring an exported type

```lua
-- In a ModuleScript (e.g., ReplicatedStorage/Types)
export type PlayerData = {
    gold: number,
    level: number,
    inventory: {string},
}

export type Result<T, E> = { type: "ok", value: T } | { type: "err", error: E }
```

The `export` keyword precedes `type`. Only `type` aliases can be exported; you cannot export a local variable's inferred type directly.

### Importing an exported type

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Types)

-- Use the module name as a prefix
local data: Types.PlayerData = {
    gold = 100,
    level = 1,
    inventory = {},
}
```

The consumer references the type as `ModuleVariable.TypeName`. No special import syntax exists; it piggybacks on `require`.

### Re-exporting

A module can re-export a type from another module:

```lua
local Types = require(game.ReplicatedStorage.Types)

-- Re-export under the same name
export type PlayerData = Types.PlayerData

-- Or re-export with a different name
export type PD = Types.PlayerData
```

### Generic exports

Exported types support generic parameters:

```lua
export type Container<T> = {
    value: T,
    metadata: string,
}

export type Map<K, V> = { [K]: V }
```

Consumers instantiate the generic at the use site:

```lua
local Types = require(game.ReplicatedStorage.Types)
local box: Types.Container<number> = { value = 42, metadata = "count" }
```

## Semantics

- `export type` is **module-scoped**. Without `export`, a `type` alias is local to the file and invisible to consumers.
- The export is a **type-level** construct only. It has no runtime cost and produces no bytecode. The `require` call returns the module's runtime value (typically a table); the type system resolves exported types separately.
- Exported types participate in Luau's **structural type system**. The consumer does not need to reference the original type by name; any table matching the shape is compatible.
- Multiple `export type` declarations can appear in a single module.
- Circular type references between modules are not supported and cause recursion errors (same constraint as circular `require` calls).

### Deviation from Lua 5.1

Lua 5.1 has no type system. `export type` is entirely a Luau addition.

## Examples

### Shared types module pattern

```lua
-- ReplicatedStorage/Shared/Types.lua
export type WeaponConfig = {
    name: string,
    damage: number,
    cooldown: number,
    range: number,
}

export type CombatResult = {
    hit: boolean,
    damage: number,
    critical: boolean,
}

return {} -- runtime value can be empty; types are resolved at analysis time
```

```lua
-- ServerScriptService/CombatService.server.lua
--!strict
local Types = require(game.ReplicatedStorage.Shared.Types)

local function applyDamage(weapon: Types.WeaponConfig, target: Humanoid): Types.CombatResult
    local dmg = weapon.damage
    local crit = math.random() < 0.1
    if crit then dmg *= 2 end
    target:TakeDamage(dmg)
    return { hit = true, damage = dmg, critical = crit }
end
```

### Exporting OOP-style types

```lua
export type Cat = {
    Name: string,
    Meow: (Cat) -> (),
}
```

```lua
local Types = require(game.ReplicatedStorage.Types)

local newCat: Types.Cat = {
    Name = "metatablecat",
    Meow = function(self)
        print(`{self.Name} said meow`)
    end,
}

newCat:Meow() --> metatablecat said meow
```

## Pitfalls

- **Empty return tables.** A types-only module still needs `return {}` (or some value). Forgetting the return statement causes a `require` error at runtime.
- **No runtime enforcement.** `export type` is purely for static analysis. A malicious or buggy caller can still pass a mismatched table at runtime; server code must validate remote inputs regardless of type annotations.
- **Metatable types are not exported.** `export type` works with structural table shapes. Metatable-based "classes" need `typeof(setmetatable(...))` patterns which are harder to export cleanly.
- **Naming collisions.** If two required modules export the same type name, the consumer must alias them via the module variable prefix (`ModA.Foo` vs `ModB.Foo`).

## Related

- [[type-annotations]]
- [[generic-types]]
- [[module-scripts]]
- [[strict-vs-nonstrict]]

## Sources

- [Luau Generics and Polymorphism](../raw/luau-spec/types/generics.md)
- [Roblox Creator Docs: Type Checking](../raw/roblox-creator-docs/luau/type-checking.md)
