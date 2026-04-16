---
title: "RFC: Generalized Iteration"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/generalized-iteration.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, iteration, __iter, metamethod]
---

# RFC: Generalized Iteration

**Status:** Implemented

## Core Problem

Lua requires different iteration syntax for different container types: `ipairs` for arrays, `pairs` for tables, and custom methods for objects. The proposal unifies this through a single `for k, v in obj do` syntax.

## Key Innovation: `__iter` Metamethod

Objects can now define an `__iter` metamethod that returns three values: generator function, state, and initial index. When the iteration protocol encounters an object with this metamethod, it calls it once before the loop begins:

```lua
local Node = {}
function Node:__iter()
    return next, self.children
end
```

This allows "self-iterating objects" without requiring `__call` implementations, making custom iteration both cleaner and more efficient.

## Default Table Behavior

Tables without `__iter` now iterate in predictable order:

1. Numeric keys `1..k` until reaching a nil value
2. Remaining keys (numeric and otherwise) in unspecified order

This combines the ordered guarantees of `ipairs` with the completeness of `pairs`, rendering both mostly obsolete for typical table iteration.

## Implementation

The proposal requires changes to table insertion logic to ensure numeric keys appear in the array portion rather than hash portion, maintaining consistent traversal order. The compiler evaluates `__iter` during loop setup (`FORGPREP` instruction), adding minimal overhead since `__iter` executes only once per loop.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/generalized-iteration.md
- Captured: 2026-04-16
