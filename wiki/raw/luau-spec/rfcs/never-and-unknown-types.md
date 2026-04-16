---
title: "RFC: never and unknown Types"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/never-and-unknown-types.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, never, unknown]
---

# RFC: never and unknown Types

## Overview

Adds two built-in types to Luau's type system: `unknown` (inhabited by everything) and `never` (inhabited by nothing).

## Motivation

The language currently uses `any` as both a top and bottom type, but `any` disables type checking rather than properly handling cases requiring true top/bottom semantics.

## Use Cases

### `unknown` Type — Represents values of indeterminate type requiring runtime narrowing

> "Any use of `unknown` must be narrowed by type refinements."

Functions returning arbitrary values should use `unknown` return types, forcing callers to use type guards before operations.

### `never` Type — Represents impossible states or uninhabitable types

- Occurs in exhaustive type narrowing where all branches are eliminated
- Useful for tagged unions: `Result<T, never>` (successful) vs. `Result<never, E>` (failed)
- Emerges from incompatible type constraints

## Design Details

**Core Semantics:**
- `never` is the bottom type (no values)
- `unknown` is the top type (all values)
- In nonstrict mode, `unknown` behaves identically to `any`

**Type Pack Behavior:** When `never` appears in function return packs, the entire pack becomes `(never, ...never)` to prevent cascading type errors.

## Practical Examples

**Unknown in Type Refinement:**
```lua
function anything(): unknown end

local x = anything()
if type(x) == "number" then
    print(x + 1)  -- type-safe
end
```

**Never in Exhaustive Cases:**
```lua
function f(x: string | number)
    if type(x) == "string" then
        -- x: string
    else
        -- x: never
    end
end
```

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/never-and-unknown-types.md
- Captured: 2026-04-16
