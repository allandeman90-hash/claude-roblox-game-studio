---
title: "RFC: Continue Statement"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-continue-statement.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, syntax, continue, loops]
---

# RFC: Continue Statement

**Status:** Implemented

## Motivation

> "Often you want the loop to only process items of a specific kind, so you can say `if item.kind ~= 'blah' then continue end`" at the loop's start.

While `continue` doesn't enable previously impossible functionality, it improves code ergonomics by reducing nested conditionals.

## Design Approach

Rather than treating `continue` as a reserved keyword, the RFC implements it as **context-sensitive**. A `continue` statement is recognized only when the identifier isn't followed by `.`, `[`, `:`, `{`, `(`, `=`, string literals, or commas — tokens that would indicate function calls or assignments.

**Valid continue statement:**
```lua
do
    continue
end
```

**Invalid (parsed as assignment):**
```lua
do
    continue = 5
end
```

**Invalid (parsed as function call):**
```lua
do
    continue(5)
end
```

## Semantic Behavior

Continue skips remaining loop body code, evaluates loop continuation conditions, and properly closes local variables.

**Notable constraint:** Using `continue` in `repeat...until` loops is disallowed if the `until` expression would access locally-scoped variables declared after the `continue` statement.

## Block Terminator

The RFC treats `continue` as a block terminator, requiring the enclosing block to end immediately after. This prevents ambiguous parsing of constructs like `continue (foo())(5)`.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-continue-statement.md
- Captured: 2026-04-16
