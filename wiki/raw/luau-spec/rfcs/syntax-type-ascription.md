---
title: "RFC: Type Ascription (:: operator)"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-type-ascription.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, syntax, types, cast]
---

# RFC: Type Ascription (`::` Operator)

## Overview

Implements type ascriptions in Luau using the `::` operator to assert that values conform to specific types.

## Motivation

Luau needed a mechanism to enforce type requirements at specific points in code. The original proposal used `as` syntax, but this created parsing ambiguity with function calls: `foo() as (bar)` could be interpreted as either two function calls or a type assertion.

## Solution: The `::` Operator

The RFC adopts `::` as the type ascription syntax, borrowing from Haskell's approach.

## Key Syntax Rules

**Binding Precedence:** The operator binds tightly. In `b + c :: number`, the assertion applies only to `c`, not the sum.

**Single Value Casting:** The `::` operator casts individual values only, not type packs:
- `foo(1, bar())` passes all values from `bar()`
- `foo(1, bar() :: any)` passes only `bar()`'s first value

**Example Usage:**
```lua
local foo = (a + b) :: number
```

## Drawbacks

1. Symbols as operators are uncommon in Lua (outside arithmetic and `..`)
2. TypeScript users familiar with `as` syntax may find `::` unfamiliar
3. Future adoption of Turbofish syntax (`::<>`) may conflict

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-type-ascription.md
- Captured: 2026-04-16
