---
title: "RFC: Compound Assignment"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-compound-assignment.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, syntax, operators]
---

# RFC: Compound Assignment

## Operators Introduced

`+=`, `-=`, `*=`, `/=`, `%=`, `^=`, `..=` (and later `//=`)

## Core Semantics

1. **Single Values Only**: Only one value can be on the left and right hand side
2. **Left-Hand Side Evaluation**: The left operand is evaluated once as an l-value
3. **Right-Hand Side Processing**: The right operand becomes a single Lua value through r-value evaluation
4. **Statement, Not Expression**: These constructs function as assignment statements exclusively. Syntax like `a = (b += 1)` remains invalid.

## Metamethod Handling

> "This proposal does not introduce new metamethods, and instead uses the existing metamethods and table access semantics."

## Performance

For indexed access patterns: `data[index].cost += 1` evaluates `data[index]` **only once**, whereas traditional assignment repeats the lookup.

## Implementation

Requires AST modifications but no new opcodes, metatables, or runtime overhead — fully backwards-compatible.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-compound-assignment.md
- Captured: 2026-04-16
