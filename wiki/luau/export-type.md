---
title: export-type
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
  - "[[generic-types]]"
tags: [luau, type-system]
---

# `export type`

**Status: stub**

## Summary

Luau syntax for sharing a `type` definition across modules. `export type Foo = { ... }` in module A lets module B write `type Foo = ModuleA.Foo`.

## TODO

- Exact syntax
- How to import an exported type
- Forward declarations
- Type packs in exports
- Comparison with just returning a table of types

## Related

- [[type-annotations]]
- [[generic-types]]

## Sources

- [wiki/raw/luau-spec/types/generics.md](../raw/luau-spec/types/generics.md)
