---
title: String Interpolation
type: luau-feature
category: luau
subcategory: syntax
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/rfcs/syntax-string-interpolation.md
  - wiki/raw/roblox-creator-docs/luau/strings.md
related:
  - "[[string-library]]"
tags: [luau, syntax, strings, interpolation]
---

# String Interpolation

**Status:** stub

## Summary

Luau supports string interpolation via backtick-delimited literals with `{expression}` placeholders. This replaces most uses of `string.format()` with a more readable and type-safe syntax.

```lua
local name = "World"
print(`Hello {name}!`)          --> Hello World!
print(`Result: {1 + 2}`)        --> Result: 3
print(`Items: {table.concat(list, ", ")}`)
```

Expressions inside `{}` are evaluated and converted to strings via `tostring()`. Escape backticks with `\``, braces with `\{` and `\}`. Newlines are permitted between expression braces. The syntax `{{` is explicitly rejected (unlike C#/Rust).

## TODO

- Full syntax grammar and escaping rules
- Comparison with `string.format` (performance, readability, limitations)
- Interaction with type system (interpolated strings cannot appear in type annotations)
- Edge cases: nested backticks, multi-line expressions
- Migration guide from `string.format` to interpolation

## Related

- [[string-library]]

## Sources

- [RFC: String Interpolation](../raw/luau-spec/rfcs/syntax-string-interpolation.md)
- [Roblox Creator Docs: Strings](../raw/roblox-creator-docs/luau/strings.md)
