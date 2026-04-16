---
title: Introduction to Luau Types
type: raw-source
source_url: https://luau.org/types
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, strict, nonstrict, nocheck]
---

# Introduction to Luau Types

Luau implements a gradual type system combining type annotations with type inference.

> "Type checking helps you find bugs early — while you're writing code — rather than discovering when your program crashes at runtime."

## Type Inference Modes

Luau provides three modes, controlled by file header directives at the top of each file:

### `--!nocheck`

Completely disables type checking. The system provides no feedback on types, allowing code errors to pass without warnings.

### `--!nonstrict` (default)

A forgiving approach where the type checker infers `any` when it cannot determine a type early. This permits code to proceed without errors even when type mismatches exist that would fail at runtime.

### `--!strict`

The most rigorous mode. The type checker "is smarter about tracking types across statements," catching type incompatibilities like attempting to add a string and number, which would otherwise go undetected.

## Structural Type System

Luau uses structural typing by default, meaning the system "inspect[s] the shape of two tables to see if they are similar enough." This approach aligns with Lua 5.1's inherent structure.

## Type Annotations & Casts

Types can be explicitly specified using colons (`:`) for annotations:

```lua
local x: number = 5
local function add(a: number, b: number): number
    return a + b
end
```

The `::` operator enables type casts to override inferred types:

```lua
local y = x :: any
```

Type casts themselves are checked to ensure "one of the conversion operands is the subtype of the other or `any`," preventing unsafe conversions between incompatible types.

## Source

- Original URL: https://luau.org/types
- Captured: 2026-04-16
