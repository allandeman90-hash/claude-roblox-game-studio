---
title: buffer-type
type: luau-feature
category: luau
subcategory: stdlib
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/library/standard-library.md
  - wiki/raw/community/performance/network/luau-buffer-type.md
related:
  - "[[bandwidth-budget]]"
  - "[[RemoteEvent]]"
tags: [luau, stdlib, performance]
---

# `buffer` Type

**Status:** stub

Binary byte buffer primitive for efficient serialization. Useful for packing RemoteEvent payloads with minimal overhead (Zstd compression on top can yield up to 60x savings for repetitive data).

Operations: `buffer.create(size)`, `buffer.writeu8/u16/u32/i8/i16/i32/f32/f64/string`, corresponding `buffer.readX`, `buffer.len`, `buffer.fill`, `buffer.copy`, `buffer.tostring`, `buffer.fromstring`.

## Related

- [[bandwidth-budget]]
- [[RemoteEvent]]

## Sources

- [wiki/raw/community/performance/network/luau-buffer-type.md](../raw/community/performance/network/luau-buffer-type.md)
