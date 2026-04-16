---
title: "RFC: If-Then-Else Expression"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-if-expression.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, syntax, expression, conditional]
---

# RFC: If-Then-Else Expression

## Summary

First-class ternary conditional operator using `if cond then value else alternative` syntax.

## Motivation

Luau previously lacked a proper ternary operator. The common workaround `cond and value or alternative` breaks when `value` is `false` or `nil`: "this expression evaluates to `value` if `cond` and `value` are truthy, and `alternative` otherwise," which doesn't match actual ternary logic.

Using `if` statements requires mutable variables and lacks ergonomics; immediately invoked functions are cumbersome and slow.

## Syntax

Pattern: `if <expr> then <expr> else <expr>`

**Key characteristics:**
- Only one branch evaluates (short-circuit behavior)
- `else` is required — no optional syntax
- Optional `elseif` chains supported
- No terminating `end` keyword

## Examples

```lua
local x = if FFlagFoo then A else B

MyComponent.validateProps = t.strictInterface({
    layoutOrder = t.optional(t.number),
    newThing = if FFlagUseNewThing then t.whatever() else nil,
})

local category = if x < 0 then "negative"
                 elseif x == 0 then "zero"
                 else "positive"
```

## Drawbacks

- **Editor compatibility:** Studio's autocomplete adds indented blocks with `end` after `then` tokens
- **Parser recovery:** The leading `if` keyword can complicate error recovery
- **Future interactions:** Potential conflicts with hypothetical mid-block `return` statements

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-if-expression.md
- Captured: 2026-04-16
