---
title: "RFC: table.clone"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/function-table-clone.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, table, clone]
---

# RFC: table.clone

## Overview

`table.clone` creates a shallow copy of a table, preserving its keys, values, and metatable while ensuring the copy is not frozen.

## Design

**Function signature:** `table.clone(t) -> new_table`

**Key behaviors:**
- Copies all key-value pairs from the original table
- Transfers the metatable to the new table
- Returns an **unfrozen** copy, regardless of the original's frozen state
- Fails if the table has a protected metatable (conservative approach)

## Shallow vs. Deep Copying

> "Implementing a deep recursive copy automatically is challenging."

Typically only specific keys require recursive cloning, which users can perform post-clone.

## Efficiency

The built-in function dramatically outperforms manual implementations by directly copying internal structures while preserving capacity and key order, limited only by memory bandwidth.

## Equivalent User Implementation

```lua
local nt = {}
for k, v in pairs(t) do
    nt[k] = v
end
if type(getmetatable(t)) == "table" then
    setmetatable(nt, getmetatable(t))
end
```

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/function-table-clone.md
- Captured: 2026-04-16
