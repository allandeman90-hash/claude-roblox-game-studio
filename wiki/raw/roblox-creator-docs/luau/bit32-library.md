---
title: bit32 Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/bit32
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, bit32, bitwise, library]
---

# bit32 Library

This library provides functions to perform bitwise operations.

## Number Limitations

This library treats numbers as unsigned 32-bit integers; numbers will be converted to this before being used. Numbers with decimal numbers are rounded to the nearest whole number.

## Functions

### bit32.arshift

```
bit32.arshift(x: number, disp: number): number
```

Returns the number `x` shifted `disp` bits to the right. The number `disp` may be any representable integer. Negative displacements shift to the left.

This shift operation is what is called arithmetic shift. Vacant bits on the left are filled with copies of the higher bit of `x`; vacant bits on the right are filled with zeros. Displacements with absolute values higher than 31 result in zero or 0xFFFFFFFF (all original bits are shifted out).

### bit32.band

```
bit32.band(...: Tuple): number
```

Returns the bitwise AND of all provided numbers.

Truth table:
| A | B | Output |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 1 | 1 |

### bit32.bnot

```
bit32.bnot(x: number): number
```

Returns the bitwise negation of `x`. For any integer `x`:

```lua
assert(bit32.bnot(x) == (-1 - x) % 2^32)
```

### bit32.bor

```
bit32.bor(...: Tuple): number
```

Returns the bitwise OR of all provided numbers.

| A | B | Output |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 1 | 1 |

### bit32.btest

```
bit32.btest(...: Tuple): bool
```

Returns a boolean signalling whether the bitwise AND of its operands is different from zero.

### bit32.bxor

```
bit32.bxor(...: Tuple): number
```

Returns the bitwise XOR of all provided numbers.

| A | B | Output |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 1 | 0 |

### bit32.byteswap

```
bit32.byteswap(x: number): number
```

Returns the given number with the order of the bytes swapped.

### bit32.countlz

```
bit32.countlz(n: number): number
```

Returns the number of consecutive zero bits in the 32-bit representation of the provided number starting from the left-most (most significant) bit. Returns 32 if the provided number is zero.

### bit32.countrz

```
bit32.countrz(n: number): number
```

Returns the number of consecutive zero bits in the 32-bit representation of the provided number starting from the right-most (least significant) bit. Returns 32 if the provided number is zero.

### bit32.extract

```
bit32.extract(n: number, field: number, width: number = 1): number
```

Returns the unsigned number formed by the bits `field` to `field + width - 1` from `n`. Bits are numbered from 0 (least significant) to 31 (most significant). All accessed bits must be in the range [0, 31].

### bit32.replace

```
bit32.replace(n: number, v: number, field: number, width: number = 1): number
```

Returns a copy of `n` with the bits `field` to `field + width - 1` replaced by the value `v`.

### bit32.lrotate

```
bit32.lrotate(x: number, disp: number): number
```

Returns the number `x` rotated `disp` bits to the left. For any valid displacement:

```lua
assert(bit32.lrotate(x, disp) == bit32.lrotate(x, disp % 32))
```

In particular, negative displacements rotate to the right.

### bit32.lshift

```
bit32.lshift(x: number, disp: number): number
```

Returns the number `x` shifted `disp` bits to the left. Negative displacements shift to the right. Vacant bits are filled with zeros. Displacements with absolute values higher than 31 result in zero.

For positive displacements:

```lua
assert(bit32.lshift(b, disp) == (b * 2^disp) % 2^32)
```

### bit32.rrotate

```
bit32.rrotate(x: number, disp: number): number
```

Returns the number `x` rotated `disp` bits to the right. For any valid displacement:

```lua
assert(bit32.rrotate(x, disp) == bit32.rrotate(x , disp % 32))
```

Negative displacements rotate to the left.

### bit32.rshift

```
bit32.rshift(x: number, disp: number): number
```

Returns the number `x` shifted `disp` bits to the right. Negative displacements shift to the left. Vacant bits are filled with zeros.

For positive displacements:

```lua
assert(bit32.rshift(b, disp) == (b % 2^32 / 2^disp) // 1)
```

This is a logical shift.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/bit32
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/bit32.yaml
Captured: 2026-04-16
