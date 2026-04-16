---
title: "RFC: table.freeze and table.isfrozen"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/function-table-freeze.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, table, freeze, immutability]
---

# RFC: table.freeze and table.isfrozen

## Motivation

Currently, Lua tables are freely modifiable. While developers can use metatables with `__newindex` to restrict modifications, creating truly read-only tables requires complex workarounds that harm performance and break iteration:

> "To make an existing table read-only, one needs to combine these mechanisms... However, this results in iteration and length operator not working on the resulting table."

Two key use cases:
1. **Security**: Exposing sandboxed objects resistant to monkey-patching
2. **Immutability**: Supporting immutable data structures more efficiently

## Design

**Two new functions:**
- `table.freeze(t)` — Freezes a table; returns the table or fails if already frozen or locked
- `table.isfrozen(t)` — Returns boolean indicating frozen status

**Frozen table semantics:**
- Existing keys cannot be modified (assignments, `rawset`, etc. all fail)
- New keys cannot be added unless `__newindex` is defined
- Metatable changes are blocked
- Reading and iteration work normally

**Important constraint:** `table.freeze()` fails on tables with locked metatables.

## Rejected Alternatives

The RFC explicitly rejects recursive freezing and unfreezing functionality, citing implementation complexity and lack of compelling use cases.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/function-table-freeze.md
- Captured: 2026-04-16
