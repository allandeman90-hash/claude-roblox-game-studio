---
title: generic-types
type: luau-feature
category: luau
subcategory: type-system
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/types/generics.md
related:
  - "[[type-annotations]]"
  - "[[export-type]]"
tags: [luau, type-system]
---

# Generic Types

**Status:** stub

Luau supports generic type parameters via `<T>` syntax for both functions and type aliases:

```lua
local function firstOf<T>(list: {T}): T?
    return list[1]
end

type Container<T> = { value: T, metadata: string }
```

Also type packs `<T...>` for variadic generics.

## Related

- [[type-annotations]]
- [[export-type]]

## Sources

- [wiki/raw/luau-spec/types/generics.md](../raw/luau-spec/types/generics.md)
