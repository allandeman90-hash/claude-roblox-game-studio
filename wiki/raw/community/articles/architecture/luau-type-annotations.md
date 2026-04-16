---
title: Luau Type Annotations — A Practical Guide
type: raw-source
source_url: https://devforum.roblox.com/t/type-annotations-a-guide-to-writing-luau-code-that-is-actually-good%E2%84%A2/2843221
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: architecture
tags: [luau, type-checking, annotations, strict, generics, typeof]
---

# Luau Type Annotations — A Practical Guide

**Sources:** Community tutorial "Type Annotations! A guide to writing Luau code that is Actually Good" + Luau official docs

## Why types matter in a dynamic language

Lua is traditionally dynamically typed — any variable holds any value, errors surface at runtime, and the compiler can't help you. Luau adds an optional type system on top, which when enabled with `--!strict` gives you:

- Editor autocomplete that works
- Type errors caught at edit time instead of at runtime
- Refactoring with confidence (renaming a field and having the tool find every caller)
- Self-documenting function signatures

The type system is *gradual* — you can annotate as much or as little as you want, and un-annotated code continues to work. But the benefits are proportional to coverage: a half-typed codebase gives you half the errors.

## Enabling strict mode

At the top of every script that you want type-checked:

```lua
--!strict
```

Without this directive, Luau defaults to `nonstrict` mode, where most errors are silently downgraded to `any`. Strict mode is where the type system actually helps you.

## Basic types

Luau provides 10 built-in primitive types:

- **`nil`** — the absence of a value
- **`boolean`** — true/false
- **`number`** — all numeric values
- **`string`** — text
- **`thread`** — a coroutine
- **`vector`** — Luau's built-in 3D vector (distinct from Roblox `Vector3`, though they interoperate)
- **`buffer`** — raw binary data
- **`any`** — opt-out of type checking (use sparingly)
- **`unknown`** — requires type refinement before use
- **`never`** — an impossible value (empty type)

## Annotating variables and functions

```lua
local count: number = 0
local name: string = "Alice"
local items: {string} = {}

local function add(a: number, b: number): number
    return a + b
end
```

Annotation syntax:
- `name: Type` after any variable or parameter declaration
- `-> ReturnType` for function returns
- `{Type}` for arrays (shorthand for `{[number]: Type}`)
- `{[KeyType]: ValueType}` for dictionaries

## Optional types

Use `?` for nullable values:

```lua
local function findItem(id: string): Item?
    for _, item in ipairs(items) do
        if item.id == id then
            return item
        end
    end
    return nil  -- allowed because return type is Item?
end

local item = findItem("sword")
if item then
    -- inside this branch, `item` is refined to Item (no longer Item?)
    print(item.name)
end
```

The `if item then` check is called **refinement** — the type checker understands that inside the branch, `item` cannot be `nil`, so you can access its fields without a null-check.

## Union and intersection types

```lua
-- Union: this OR that
type Id = string | number

-- Intersection: this AND that (less common)
type ReadWrite = Readable & Writable
```

Unions combine with refinement for tagged-union style:

```lua
type Event =
    { kind: "damage", amount: number }
    | { kind: "heal", amount: number }
    | { kind: "move", position: Vector3 }

local function handleEvent(ev: Event)
    if ev.kind == "damage" then
        -- type checker knows ev is the damage variant
        applyDamage(ev.amount)
    elseif ev.kind == "move" then
        applyMove(ev.position)
    end
end
```

This is how you do sum types / discriminated unions in Luau. Each variant has a common `kind` field, and checking the tag refines the whole record to the corresponding variant shape.

## Table types — structured vs. indexed

```lua
-- Structured: specific fields, known at type-definition time
type Player = {
    Name: string,
    Score: number,
    Inventory: {string},
}

-- Indexed: any key of the given type maps to a value of the given type
type Scores = {[string]: number}   -- dictionary: string → number
type Grid = {{number}}              -- 2D array (shorthand)
```

Use structured types for known shapes (player state, config objects) and indexed types for maps/arrays.

## Function types

```lua
-- Function type
type Callback = (player: Player, score: number) -> boolean

-- Variadic
type Logger = (level: string, ...any) -> ()

-- Multiple return
type Maybe<T> = () -> (boolean, T?)

-- Nullable function
local handler: ((Instance) -> ())? = nil
```

Function types are first-class citizens; you can store them in variables and pass them around just like any other type.

## Type assertions (`::`)

When the type checker is wrong (or doesn't know enough), you can override with the `::` cast operator:

```lua
local raw = someUntypedValue()
local typed = raw :: string  -- trust me, it's a string

local t = {} :: {[string]: number}  -- empty table; force the type
```

Use this sparingly — every `::` is a place where your type promise could diverge from reality.

## Generics

Generics let you write functions and types that work for any type, parameterized by a type variable:

```lua
type List<T> = {T}

local function first<T>(list: {T}): T?
    return list[1]
end

local numbers: List<number> = {1, 2, 3}
local n = first(numbers)  -- n: number?

local names: List<string> = {"Alice", "Bob"}
local s = first(names)    -- s: string?
```

The `<T>` is a type parameter. When you call `first(numbers)`, Luau infers `T = number` and adjusts the return type accordingly.

## Typed OOP with `typeof(setmetatable(...))`

This is the canonical pattern for typed Luau classes:

```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(value: number)
    local self = setmetatable({}, MyClass)
    self.value = value
    return self
end

function MyClass:getValue(): number
    return self.value
end

export type MyClass = typeof(MyClass.new(...))
```

The trick: `typeof(MyClass.new(...))` asks Luau "whatever type `MyClass.new` returns — call that the `MyClass` type." The `...` is valid syntax here because Luau is inferring structurally; it doesn't need actual arguments.

This is fragile if `new` itself is complicated, so larger projects use the explicit three-type (`Proto`, `Impl`, class-type) pattern shown in the OOP article.

## Exported types

```lua
-- In Module.luau
export type Config = {
    width: number,
    height: number,
    title: string,
}

return {}

-- In another file
local Module = require(somewhere.Module)
local config: Module.Config = {
    width = 800,
    height = 600,
    title = "Game",
}
```

`export type` makes a type visible to other modules via the `Module.TypeName` syntax.

## Unknown vs any

- **`any`** — the type system will let you do anything with the value. Accessing a missing field, calling it like a function, passing it anywhere — all allowed. **This turns off type checking for that value.**
- **`unknown`** — the type system accepts any value *coming in*, but won't let you do anything with it until you've refined it. This is the type-safe alternative to `any`.

```lua
local raw: unknown = someDynamicThing()

-- Cannot do this: error, unknown doesn't have a .field
-- print(raw.field)

if typeof(raw) == "string" then
    -- inside this branch, raw is refined to string
    print(#raw)
end
```

Prefer `unknown` over `any` whenever possible — it forces you to handle the uncertainty explicitly instead of pretending it doesn't exist.

## The practical workflow

1. Start with `--!strict` at the top of a new file.
2. Annotate function parameters and return types as you write them.
3. Define `type`s for structured data (configs, events, messages).
4. Use `export type` to share types across module boundaries.
5. Let type inference handle the rest — annotate only when the checker can't figure it out.

Over time, the type graph of your project grows until most operations have static types flowing through them, and the editor becomes actively useful as a refactoring tool.

## Sources

- https://devforum.roblox.com/t/type-annotations-a-guide-to-writing-luau-code-that-is-actually-good%E2%84%A2/2843221
- https://luau.org/types/
- https://create.roblox.com/docs/luau/type-checking
Captured: 2026-04-15
