---
title: "RFC: Generic Functions"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/generic-functions.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, generics, polymorphism]
---

# RFC: Generic Functions

## Core Proposal

Introduces explicit generic functions to Luau, allowing developers to annotate type parameters alongside function parameters. Previously, generics could only be inferred.

## Syntax

**Basic generic function:**
```lua
function id<a>(x: a): a
    return x
end
```

**Generic type pack parameters for varargs:**
```lua
function compose<a...>(...: a...) -> (a...)
    return ...
end
```

**Generic function types:**
```lua
local id: <a>(a) -> a = function(x) return x end
```

## Key Semantic Distinction

Type binders become semantically significant. Two functions with identical behavior can have different types based on where type parameters bind:

- `f : () -> <a>(a) -> a` — type variable binds at **call site**
- `g : <a>() -> (a) -> a` — type variable binds at **function definition**

This distinction prevents unsound code where a closure captures a value, then gets used as a generic function.

## Supported Features

> "We propose supporting type parameters which can be instantiated with any type...but not type functions...or types with constraints."

This is **Rank-N polymorphism** without higher-kinded types or bounded polymorphism.

## Notable Limitation: No Turbofish

The RFC explicitly rejects explicit type argument syntax like `id<number>(y)` due to parsing ambiguity with comparison operators. Future disambiguation could use `foo:<number>()` or `foo.<number>()`.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/generic-functions.md
- Captured: 2026-04-16
