---
title: strict-vs-nonstrict
type: luau-feature
category: luau
subcategory: type-system
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/types/types-intro.md
related:
  - "[[type-annotations]]"
  - "[[export-type]]"
tags: [luau, type-system]
---

# Strict vs Non-Strict Type Checking

**Status:** stub

## Summary

Luau has three type-checking modes set via a file header directive:
- `--!strict` — aggressive checking; errors on type mismatches
- `--!nonstrict` — conservative (default); infers types but mostly warns
- `--!nocheck` — disables type checking entirely

Prefer `--!strict` for new code. Use `--!nonstrict` when integrating with untyped third-party modules.

## TODO

- Exact behavior differences between modes
- What errors each mode catches that the others don't
- Migration path from nonstrict to strict
- Per-file vs per-project settings (`.luaurc`)

## Related

- [[type-annotations]]
- [[export-type]]

## Sources

- [wiki/raw/luau-spec/types/types-intro.md](../raw/luau-spec/types/types-intro.md)
