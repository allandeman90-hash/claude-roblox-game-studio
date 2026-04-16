---
title: Luau Type Refinements
type: raw-source
source_url: https://luau.org/types/type-refinements
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, refinement, narrowing]
---

# Type Refinements in Luau

Type refinements narrow the type of a value within a branch based on runtime checks.

## Refinement Methods

Three primary refinement techniques:

### 1. Truthy Testing

```lua
if x then
    -- x refined to be truthy (not nil or false)
end
```

### 2. Type Guards via `type()` / `typeof()`

```lua
if type(x) == "number" then
    -- x refined to number
end
```

### 3. Equality Checks (Singleton Narrowing)

```lua
if x == "hello" then
    -- x refined to singleton type "hello"
end
```

## Composition

Refinements can be "composed with many of `and`/`or`/`not`." The `not` operator and `~=` operator flip resulting refinements — so `not x` refines `x` to be falsy.

## Assert Usage

The `assert(..)` function provides an alternative refinement mechanism, working with the same refinement patterns as if/then statements:

```lua
assert(type(x) == "number")
-- x refined to number for the rest of the scope
```

## Tagged Union Discrimination

Combined with singleton types, refinements power tagged unions:

```lua
type Result<T, E> = { type: "ok", value: T } | { type: "err", error: E }

local r: Result<number, string> = ...
if r.type == "ok" then
    print(r.value) -- r narrowed to Ok branch
end
```

## Complexity

> "Support for this is arbitrarily complex."

Luau's type refinement system is quite sophisticated and supports compound boolean expressions.

## Source

- Original URL: https://luau.org/types/type-refinements
- Captured: 2026-04-16
