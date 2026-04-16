---
title: "RFC: Singleton Types"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-singleton-types.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, singletons, tagged-unions]
---

# RFC: Singleton Types

## Core Concept

Singleton types represent "a constant runtime value as a type," allowing developers to use literal values in type annotations alongside traditional types.

## String Literal Types

```lua
type Animals = "Dog" | "Cat" | "Bird"
type Ok<T> = { type: "ok", value: T }
type Err<E> = { type: "error", error: E }
```

Table properties can use string literals: `{["foo"]: number}` is parsed as a named property rather than an indexer.

## Boolean Literal Types

```lua
type TrueOrNil = true?
local foo: true = true
```

This enables the type system to understand conditional branches with boolean expressions.

## Tagged Unions (Discriminated Unions)

```lua
local result: Result<number, string> = ...
if result.type == "ok" then
    -- result :: Ok<number>
    print(result.value)
else
    -- result :: Err<string>
    error(result.error)
end
```

## Type Semantics

- Assignments narrow upward: specific literals accept general types (`"Hello world"` → `string`)
- Assignments don't narrow downward: general types reject literals (`string` ↛ `"Hello world"`)

## Drawbacks

Increased type-checking costs and potential complexity for developers unfamiliar with literal types as subtypes.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-singleton-types.md
- Captured: 2026-04-16
