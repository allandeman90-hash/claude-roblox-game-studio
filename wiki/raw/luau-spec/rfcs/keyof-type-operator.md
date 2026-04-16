---
title: "RFC: keyof Type Operator"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/keyof-type-operator.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, keyof, type-functions]
---

# RFC: keyof Type Operator

## Overview

Proposes two type functions — `keyof` and `rawkeyof` — to automatically derive key types from tables and classes, reducing code duplication.

## Syntax

```lua
type Keys = keyof<T>        -- All indexable keys
type RawKeys = rawkeyof<T>  -- Only direct keys (excluding __index)
```

## Core Problem

Users previously needed to manually duplicate type definitions:
```lua
type AnimalType = "cat" | "dog" | "monkey" | "fox"
local animals = { cat = {...}, dog = {...}, ... }
```

## Solution

Automatically derive key types from table structure:
```lua
local animals = { cat = {...}, dog = {...}, ... }
type AnimalType = keyof<typeof(animals)>
```

## Semantics

**`keyof<T>`**: Returns union of all legally indexable keys, incorporating `__index` metamethod behavior (equivalent to `t[i]` operations).

**`rawkeyof<T>`**: Returns only directly present keys, excluding metatable-provided properties (equivalent to `rawget(t, i)` semantics).

## Union Type Handling

When applied to unions like `{ x: number, y: number } | { a: number, y: number }`, the operator returns the greatest common subset of keys (`"y"`), representing safely indexable properties across all union members.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/keyof-type-operator.md
- Captured: 2026-04-16
