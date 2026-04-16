---
title: Luau Table Types
type: raw-source
source_url: https://luau.org/types/tables
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, tables, sealed, unsealed]
---

# Luau Table Types

Luau's type system categorizes tables into three states: **unsealed**, **sealed**, and **generic**.

## Unsealed Tables

> "An unsealed table is a table which supports adding new properties, which updates the table's type."

- Created using table literals
- Allow accumulation of shape knowledge
- Explicit type annotations seal them
- When scope exits, unsealed tables become sealed automatically
- They are **exact** — all properties must be named in the type

## Sealed Tables

> "A sealed table is a table that is now locked down."

- Created through explicit type annotations or function returns
- Sealed tables are **inexact** — they may contain properties not mentioned in the type
- Support **width subtyping**: tables with additional properties can substitute for tables with fewer properties

## Generic Tables

Generic tables appear when symbols lack annotated or inferred concrete types. Indexing on parameters requests a table matching a specific interface.

## Table Indexers

Luau provides concise syntax for array-like tables:

```lua
type Names = {string}            -- equivalent to { [number]: string }
```

More explicit indexer definitions remain useful for non-numeric keys or mixed-property tables:

```lua
type Dict = { [string]: number }
type Array = { [number]: string, n: number }
```

## Source

- Original URL: https://luau.org/types/tables
- Captured: 2026-04-16
