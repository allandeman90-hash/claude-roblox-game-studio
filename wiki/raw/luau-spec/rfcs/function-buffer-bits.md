---
title: "RFC: buffer.readbits / buffer.writebits"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/function-buffer-bits.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, buffer, bits]
---

# RFC: buffer.readbits / buffer.writebits

**Status:** Implemented

## Function Signatures

```lua
buffer.readbits(b: buffer, bitOffset: number, bitCount: number): number
buffer.writebits(b: buffer, bitOffset: number, bitCount: number, value: number): ()
```

## Key Semantics

**`bitCount` Parameter:** "An integer in range [0, 32]. Error is thrown if number is not in range."

**Zero-width Operations:** Reading 0 bits returns 0; writing has no effect.

**Bounds Checking:** "If `bitOffset` and `bitCount` cause a bit access outside the bounds of the buffer, an error is thrown."

**Value Handling:** In `writebits`, the value is treated as unsigned 32-bit, with only the least significant bits up to `bitCount` written. The `readbits` function returns unsigned values.

**Byte Order:** "Operations are always performed in little-endian byte order and starting from least significant bits."

## Example Usage

```lua
buffer.readbits(b, 0, 8) == buffer.readu8(b, 0)
buffer.readbits(b, 0, 16) == buffer.readu16(b, 0)
buffer.readbits(b, 0, 32) == buffer.readu32(b, 0)

buffer.writebits(b, 0, 1, 1)
buffer.readi8(b, 0) == 1

buffer.writebits(b, 1, 1, 1)
buffer.readi8(b, 0) == 3
```

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/function-buffer-bits.md
- Captured: 2026-04-16
