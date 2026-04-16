---
title: "RFC: Read-Only Properties"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/property-readonly.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, readonly, properties]
---

# RFC: Read-Only Properties

## Overview

Adds read-only property modifiers to Luau's type system, enabling the distinction between properties that can and cannot be modified.

## Motivation

1. **Roblox API gaps**: "Currently, Roblox APIs have read-only properties of classes, but our type system does not track this."
2. **User code clarity**: Developers need mechanisms to indicate that properties shouldn't be modified
3. **Function parameters**: Many functions legitimately need only read access to parameters

## Proposed Syntax

The notation `read p: T` indicates a read-only property of type `T`.

## Type Semantics

**Covariance of read-only properties:** If `T` is a subtype of `U`, then `{ read p: T }` is a subtype of `{ read p: U }`.

**Subtyping relationship:** "Read-write properties are a subtype of read-only properties."

## Key Examples

**Inference:**
```lua
function f(t)
    t.p = 1 + t.p + t.q
end
-- Inferred type: f: (t: { p: number, read q: number }) -> ()
```

**Covariant arrays solve the variance problem:**
```lua
local dogs: {Dog}
function f(a: {read Animal}) ... end
f(dogs) -- Now typechecks safely
```

**Methods default to read-only:**
```lua
local t = { read f: () -> (), read m: (self) -> () }
```

## Notable Design Decision

Methods are read-only by default, making idiomatic Lua patterns type-safe while preventing unsound covariance violations with generic factories.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/property-readonly.md
- Captured: 2026-04-16
