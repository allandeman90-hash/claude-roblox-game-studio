---
title: "RFC: Extended Number Literals"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-number-literals.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, syntax, numbers, literals]
---

# RFC: Extended Number Literals

**Status:** Implemented

## Binary Literals

Binary number notation with the prefix `0b` or `0B`, followed by at least one binary digit:

```lua
local b = 0b10101010101
```

## Hexadecimal Literals

Existing hexadecimal syntax preserved using `0x` or `0X` prefixes (already existed in Lua).

## Number Separators

> "We will allow an arbitrary number and arrangement of underscores in all numeric literals, including hexadecimal and binary."

Examples:
```lua
local a = 1_034_123
local b = 0xFFFF_FFFF
local c = 0b_0101_0101
```

## Key Features

- Separators work across all numeric literal types (decimal, binary, hexadecimal)
- Underscores are purely stylistic and don't affect the numeric value
- Both uppercase and lowercase prefixes are supported

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-number-literals.md
- Captured: 2026-04-16
