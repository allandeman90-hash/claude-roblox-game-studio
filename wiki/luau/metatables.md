---
title: Metatables
type: luau-feature
category: luau
subcategory: language
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/metatables.md
related:
  - "[[table-library]]"
  - "[[export-type]]"
tags: [luau, metatables, metamethods, oop]
---

# Metatables

**Status:** stub

## Summary

Metatables attach behavior to tables via metamethods. `setmetatable(t, mt)` assigns a metatable; `getmetatable(t)` retrieves it. Metamethods are special keys in the metatable (`__index`, `__newindex`, `__call`, `__add`, `__tostring`, `__len`, `__iter`, etc.) that fire when specific operations are performed on the table.

Key metamethods:
- `__index`: fallback for missing key lookups (can be a table or function)
- `__newindex`: intercepts writes to missing keys
- `__call`: makes a table callable like a function
- Arithmetic: `__add`, `__sub`, `__mul`, `__div`, `__mod`, `__pow`, `__unm`, `__idiv`
- Comparison: `__eq`, `__lt`, `__le`
- `__tostring`: custom string representation
- `__metatable`: locks the metatable (hides it from `getmetatable`, blocks `setmetatable`)
- `__iter`: custom iterator for generalized iteration

Metatables are the foundation of OOP patterns in Luau. The `__index = ClassName` pattern creates prototype-based inheritance.

## TODO

- Full metamethod reference table with signatures
- OOP class pattern with `__index` (constructor, methods, inheritance)
- `rawget`, `rawset`, `rawequal`, `rawlen` for bypassing metamethods
- Frozen table interaction (metatables on frozen tables)
- Performance implications of metamethod dispatch
- Weak tables (`__mode`)
- Luau-specific: `__iter` for custom iterators

## Related

- [[table-library]]
- [[export-type]]

## Sources

- [Roblox Creator Docs: Metatables](../raw/roblox-creator-docs/luau/metatables.md)
