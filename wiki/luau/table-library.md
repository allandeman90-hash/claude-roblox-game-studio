---
title: table-library
type: luau-feature
category: luau
subcategory: stdlib
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/table-library.md
  - wiki/raw/luau-spec/library/standard-library.md
related:
  - "[[string-library]]"
  - "[[math-library]]"
tags: [luau, stdlib]
---

# `table` Library

**Status:** stub

Luau's standard `table` library with Roblox/Luau-specific extensions beyond Lua 5.1:

- `table.insert(t, v)`, `table.remove(t, i)`, `table.sort(t, cmp)`, `table.concat(t, sep)`
- **Luau extras**: `table.create(n, v?)`, `table.clear(t)`, `table.clone(t)`, `table.freeze(t)`, `table.isfrozen(t)`, `table.find(t, v)`, `table.move(src, a, b, dst)`, `table.pack(...)`, `table.unpack(t, i?, j?)`

Use `table.create(n)` to preallocate for known sizes. Use `table.concat` instead of `..` in loops (~8x faster).

## Related

- [[string-library]]
- [[math-library]]

## Sources

- [wiki/raw/roblox-creator-docs/luau/table-library.md](../raw/roblox-creator-docs/luau/table-library.md)
