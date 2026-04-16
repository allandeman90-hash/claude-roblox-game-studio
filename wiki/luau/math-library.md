---
title: math Library
type: luau-feature
category: luau
subcategory: stdlib
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/math-library.md
  - wiki/raw/luau-spec/library/standard-library.md
  - wiki/raw/luau-spec/rfcs/function-math-lerp.md
  - wiki/raw/luau-spec/rfcs/function-math-map.md
related:
  - "[[table-library]]"
  - "[[string-library]]"
  - "[[buffer-type]]"
tags: [luau, stdlib, math]
---

# `math` Library

> Standard math functions and constants. Luau extends Lua 5.1 with `math.clamp`, `math.sign`, `math.round`, `math.noise`, `math.lerp`, and `math.map` plus additional constants.

## Syntax

All functions and constants are accessed via the global `math` variable.

### Constants

| Constant | Value | Description |
|---|---|---|
| `math.pi` | ~3.14159 | Pi |
| `math.huge` | ~2^1024 | Positive infinity |
| `math.nan` | NaN | IEEE 754 Not-a-Number |
| `math.e` | ~2.71828 | Euler's number |
| `math.tau` | ~6.28318 | 2 * pi |
| `math.phi` | ~1.61803 | Golden ratio |
| `math.sqrt2` | ~1.41421 | Square root of 2 |

### Rounding

```lua
math.floor(x) -> int      -- round down
math.ceil(x) -> int       -- round up
math.round(x) -> int      -- round to nearest; ties away from zero (Luau)
```

### Clamping and mapping (Luau extensions)

```lua
math.clamp(x, min, max) -> number   -- constrain x to [min, max]; errors if min > max
math.sign(x) -> int                 -- -1, 0, or 1
math.lerp(a, b, t) -> number        -- linear interpolation: a + (b - a) * t
math.map(x, inmin, inmax, outmin, outmax) -> number  -- remap x between ranges
```

### Trigonometry (radians)

```lua
math.sin(x), math.cos(x), math.tan(x)
math.asin(x), math.acos(x), math.atan(x), math.atan2(y, x)
math.sinh(x), math.cosh(x), math.tanh(x)
math.deg(x) -> number    -- radians to degrees
math.rad(x) -> number    -- degrees to radians
```

### Exponential / logarithmic

```lua
math.exp(x) -> number            -- e^x
math.log(x, base?) -> number     -- logarithm (default base e)
math.log10(x) -> number          -- base-10 logarithm
math.pow(x, y) -> number         -- x^y (equivalent to x ^ y operator)
math.sqrt(x) -> number           -- square root
math.ldexp(s, e) -> number       -- s * 2^e
math.frexp(x) -> (number, int)   -- significand and exponent
```

### Miscellaneous

```lua
math.abs(x) -> number
math.fmod(x, y) -> number        -- remainder (quotient rounded toward zero)
math.modf(x) -> (int, number)    -- integer part and fractional part
math.max(...) -> number
math.min(...) -> number
math.random() -> number           -- [0, 1)
math.random(m) -> int             -- [1, m]
math.random(m, n) -> int          -- [m, n]
math.randomseed(seed)
math.noise(x, y?, z?) -> number   -- Perlin noise in [-1, 1] (Luau)
```

### Numeric checks (Luau extensions)

```lua
math.isfinite(x) -> boolean
math.isinf(x) -> boolean
math.isnan(x) -> boolean
```

## Semantics

### `math.clamp(x, min, max)`

Returns `min` if `x < min`, `max` if `x > max`, otherwise `x`. Throws an error if `min > max`.

```lua
math.clamp(15, 0, 10)  --> 10
math.clamp(-5, 0, 10)  --> 0
math.clamp(5, 0, 10)   --> 5
```

### `math.lerp(a, b, t)`

Linear interpolation. Guarantees: `lerp(a, *, 0) == a`, `lerp(*, b, 1) == b`, `lerp(x, x, t) == x` for all `t`. Results stay in `[a, b]` when `t` is in `[0, 1]`. Values of `t` outside `[0, 1]` extrapolate.

Implementation: `if t == 1 then b else a + (b - a) * t`. Optimized to 6-9 CPU instructions.

```lua
math.lerp(0, 100, 0.5)  --> 50
math.lerp(10, 20, 0)    --> 10
math.lerp(10, 20, 1)    --> 20
```

### `math.map(x, inmin, inmax, outmin, outmax)`

Remaps `x` from `[inmin, inmax]` to `[outmin, outmax]`. Extrapolates if `x` is outside the input range. Use `math.clamp` around it for clamped mapping.

```lua
-- Map a slider value (0-100) to volume (0-1)
math.map(75, 0, 100, 0, 1)  --> 0.75

-- Clamped version
math.clamp(math.map(x, 0, 100, 0, 1), 0, 1)
```

### `math.noise(x, y?, z?)`

3D Perlin noise. Returns a value typically in `[-1, 1]` (can occasionally slightly exceed). `y` and `z` default to 0. Useful for procedural terrain, texture variation, and natural-looking randomness.

```lua
-- Generate terrain height
for x = 1, 100 do
    local height = math.noise(x * 0.05, 0, 0) * 50 + 50
    -- height varies smoothly between ~0 and ~100
end
```

### `math.random` / `math.randomseed`

Pseudo-random number generator. `math.random()` returns a float in `[0, 1)`. `math.random(m)` returns an integer in `[1, m]`. `math.random(m, n)` returns an integer in `[m, n]`. `math.randomseed(seed)` resets the generator for deterministic sequences.

### Deviation from Lua 5.1

Luau adds: `math.clamp`, `math.sign`, `math.round`, `math.noise`, `math.lerp`, `math.map`, `math.isfinite`, `math.isinf`, `math.isnan`, and constants `math.nan`, `math.e`, `math.tau`, `math.phi`, `math.sqrt2`.

## Examples

### Smooth camera follow

```lua
local function updateCamera(current: Vector3, target: Vector3, dt: number): Vector3
    local t = math.clamp(dt * 5, 0, 1)
    return Vector3.new(
        math.lerp(current.X, target.X, t),
        math.lerp(current.Y, target.Y, t),
        math.lerp(current.Z, target.Z, t)
    )
end
```

### Damage scaling with clamp

```lua
local function calculateDamage(base: number, armor: number): number
    local reduced = base - armor
    return math.clamp(reduced, 1, base) -- minimum 1 damage, max = base
end
```

### Perlin noise terrain

```lua
local SCALE = 0.02
local AMPLITUDE = 100

for x = 1, 512 do
    for z = 1, 512 do
        local height = math.noise(x * SCALE, z * SCALE, 0) * AMPLITUDE
        -- Use height to position terrain blocks
    end
end
```

## Pitfalls

- **`math.random` is not cryptographically secure.** Do not use for security-sensitive operations (item IDs, tokens). The sequence is deterministic given the seed.
- **`math.noise` output is not exactly `[-1, 1]`.** Values can slightly exceed the range. Clamp if exact bounds matter.
- **`math.round` ties away from zero.** `math.round(0.5) == 1` and `math.round(-0.5) == -1`. This differs from "round half to even" (banker's rounding).
- **`math.clamp` errors on `min > max`.** Validate inputs before calling if min/max are dynamic.
- **`math.lerp` with NaN.** If `b - a` overflows to infinity, the result may be NaN. Finite inputs within normal ranges are safe.
- **`math.log` returns NaN for negative input.** Check sign before calling if the input could be negative.

## Related

- [[table-library]]
- [[string-library]]
- [[buffer-type]]

## Sources

- [Roblox Creator Docs: math Library](../raw/roblox-creator-docs/luau/math-library.md)
- [Luau Standard Library Reference](../raw/luau-spec/library/standard-library.md)
- [RFC: math.lerp](../raw/luau-spec/rfcs/function-math-lerp.md)
- [RFC: math.map](../raw/luau-spec/rfcs/function-math-map.md)
