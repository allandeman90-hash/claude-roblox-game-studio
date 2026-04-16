---
title: type-annotations
type: luau-feature
category: luau
subcategory: type-system
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/type-checking.md
  - .claude/docs/luau-style-guide.md
related:
  - "[[export-type]]"
  - "[[generic-types]]"
  - "[[strict-vs-nonstrict]]"
tags: [luau, type-system]
---

# Type Annotations

> Luau's gradual type system. Lets you annotate variables, parameters, returns, and tables with types, and the type checker verifies consistency.

## Syntax

### Variables

```lua
local x: number = 42
local name: string = "Alice"
local isReady: boolean = false
local player: Player = game.Players.LocalPlayer
```

### Function Parameters and Returns

```lua
local function add(a: number, b: number): number
    return a + b
end

local function greet(player: Player): string
    return "Hello, " .. player.Name
end

-- Multiple returns
local function divmod(a: number, b: number): (number, number)
    return a // b, a % b
end
```

### Table Types

```lua
type Point = { x: number, y: number }

local p: Point = { x = 3, y = 4 }
```

### Array-Like Tables

```lua
local numbers: {number} = {1, 2, 3}
local names: {string} = {"Alice", "Bob"}
```

Dictionary-like:

```lua
local scores: {[string]: number} = {Alice = 100, Bob = 85}
```

### Optional Types

Append `?` to mean "or nil":

```lua
local function find(name: string): Player?
    return game.Players:FindFirstChild(name)  -- may return nil
end
```

### Union Types

```lua
type Id = number | string

local function display(id: Id): string
    if typeof(id) == "number" then
        return tostring(id)  -- id is narrowed to number here
    else
        return id  -- id is narrowed to string here
    end
end
```

### Intersection Types

```lua
type Named = { name: string }
type Aged = { age: number }
type Person = Named & Aged

local alice: Person = { name = "Alice", age = 30 }
```

### Function Types

```lua
type Predicate = (x: number) -> boolean

local isPositive: Predicate = function(x) return x > 0 end
```

## Semantics

### Gradual Typing

Luau's type system is **gradual** — you can type some things and leave others untyped. Untyped locals and parameters have type `any`, which disables type checking for them.

### Strict vs Non-Strict Mode

Put a directive at the top of a file to control checking:

```lua
--!strict       -- aggressive checking; errors on type mismatches
--!nonstrict    -- conservative (default); infers types but doesn't error
--!nocheck      -- disables type checking entirely
```

Prefer `--!strict` for new code. Use `--!nonstrict` when integrating with untyped third-party modules.

### Type Inference

Luau infers types even without annotations. You don't have to annotate every local:

```lua
local x = 42              -- inferred as number
local name = "Alice"      -- inferred as string
local nums = {1, 2, 3}    -- inferred as {number}
```

The explicit annotation is needed when:
- Inference can't decide (e.g., empty table)
- You want to constrain a wider type
- Public API signatures where annotation serves as documentation

### `typeof` vs `type`

- `type(x)` returns a Lua 5.1 string: `"number"`, `"string"`, `"boolean"`, `"table"`, `"function"`, `"nil"`, `"userdata"`, `"thread"`
- `typeof(x)` is Roblox-specific and distinguishes Roblox types: `"Vector3"`, `"CFrame"`, `"Instance"`, etc.

For Roblox code, always prefer `typeof`.

## Examples

### Type-safe module interface

```lua
--!strict
local PlayerData = {}

export type PlayerData = {
    gold: number,
    level: number,
    inventory: {[string]: number},
}

local cache: {[Player]: PlayerData} = {}

function PlayerData.get(player: Player): PlayerData?
    return cache[player]
end

function PlayerData.set(player: Player, data: PlayerData)
    cache[player] = data
end

return PlayerData
```

### Narrowing with `typeof`

```lua
local function handleInput(value: number | string): number
    if typeof(value) == "number" then
        return value  -- narrowed to number
    else
        return tonumber(value) or 0  -- narrowed to string
    end
end
```

### Constraining a generic

```lua
local function firstOf<T>(list: {T}): T?
    return list[1]
end

local n: number? = firstOf({1, 2, 3})   -- T = number
local s: string? = firstOf({"a", "b"})  -- T = string
```

## Pitfalls

- **Assuming `any` is safe**: `any` disables checking entirely for that expression. Prefer specific types.
- **Over-using `any` to silence the checker**: indicates a type mismatch; fix it instead.
- **Not exporting types that other modules need**: see [[export-type]].
- **Forgetting to annotate table fields**: `{}` inferred as `{any}`; give it a proper table type.
- **Circular types**: not all circular types are supported. Use type aliases and forward declarations.
- **Non-strict default**: new files default to non-strict. Add `--!strict` explicitly for tight checking.
- **Typeof string mismatch**: `typeof(x) == "Number"` (wrong — lowercase) vs `"number"` (right).

## Related

- [[export-type]] — sharing types across modules
- [[generic-types]] — `<T>` type parameters
- [[strict-vs-nonstrict]] — type checking modes
- [Luau type checking docs](https://create.roblox.com/docs/luau/type-checking)

## Sources

- [wiki/raw/roblox-creator-docs/luau/type-checking.md](../raw/roblox-creator-docs/luau/type-checking.md)
- [.claude/docs/luau-style-guide.md](../../.claude/docs/luau-style-guide.md)
