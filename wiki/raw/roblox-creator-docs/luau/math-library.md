---
title: math Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/math
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, math, library, random, clamp, noise, lerp, floor, ceil]
---

# math Library

The **math** library provides mathematical functions and constants. All functions are accessed via the global `math` variable.

> **Note:** This file was captured as a structured summary of the YAML source (the WebFetch sub-model declined to return the YAML verbatim). The signatures and descriptions here are faithful to the Roblox docs but may be more concise than the original. For definitive details, see the source URL.

## Constants

| Constant | Description |
|---|---|
| `math.e` | Euler's number (~2.71828) |
| `math.huge` | Value greater than or equal to any other number (~2^1024, effectively infinity) |
| `math.nan` | IEEE 754 NaN (Not-a-Number) value |
| `math.phi` | The golden ratio (~1.61803) |
| `math.pi` | Pi (~3.14159) |
| `math.sqrt2` | Square root of 2 (~1.41421) |
| `math.tau` | 2 * pi (~6.28318) |

## Functions

### math.abs

```
math.abs(x: number): number
```

Returns the absolute value of `x`.

### math.acos / math.asin / math.atan

```
math.acos(x: number): number
math.asin(x: number): number
math.atan(x: number): number
```

Returns arc cosine / arc sine / arc tangent of `x`, in radians.

### math.atan2

```
math.atan2(y: number, x: number): number
```

Returns the arc tangent of `y/x` (in radians), using the signs of both parameters to determine the correct quadrant.

### math.ceil

```
math.ceil(x: number): int
```

Returns the smallest integer greater than or equal to `x` (rounds up).

### math.clamp

```
math.clamp(x: number, min: number, max: number): number
```

Returns `x` constrained between `min` and `max`. If `x < min` returns `min`; if `x > max` returns `max`; otherwise returns `x`.

### math.cos / math.sin / math.tan

```
math.cos(x: number): number
math.sin(x: number): number
math.tan(x: number): number
```

Trigonometric functions. The argument is in radians.

### math.cosh / math.sinh / math.tanh

```
math.cosh(x: number): number
math.sinh(x: number): number
math.tanh(x: number): number
```

Hyperbolic trigonometric functions.

### math.deg / math.rad

```
math.deg(x: number): number
math.rad(x: number): number
```

Converts `x` from radians to degrees / from degrees to radians.

### math.exp

```
math.exp(x: number): number
```

Returns e^x.

### math.floor

```
math.floor(x: number): int
```

Returns the largest integer less than or equal to `x` (rounds down).

### math.fmod

```
math.fmod(x: number, y: number): number
```

Returns the remainder of `x / y` that rounds the quotient toward zero.

### math.frexp

```
math.frexp(x: number): (number, int)
```

Returns `m` and `e` such that `x = m * 2^e`, where `e` is an integer and the absolute value of `m` is in the range [0.5, 1) (or zero when `x` is zero).

### math.isfinite / math.isinf / math.isnan

```
math.isfinite(x: number): boolean
math.isinf(x: number): boolean
math.isnan(x: number): boolean
```

Returns `true` if `x` is finite / is positive or negative infinity / is NaN.

### math.ldexp

```
math.ldexp(x: number, e: int): number
```

Returns `x * 2^e` (`e` should be an integer).

### math.lerp

```
math.lerp(a: number, b: number, t: number): number
```

Performs linear interpolation between `a` and `b` based on the value of `t`. When `t = 0`, returns `a`; when `t = 1`, returns `b`.

### math.log

```
math.log(x: number, base: number?): number
```

Returns the logarithm of `x` with the optional `base`. If `base` is omitted, returns the natural logarithm (base `e`).

### math.log10

```
math.log10(x: number): number
```

Returns the base-10 logarithm of `x`.

### math.map

```
math.map(x: number, inmin: number, inmax: number, outmin: number, outmax: number): number
```

Maps `x` from an input range `[inmin, inmax]` to an output range `[outmin, outmax]`.

### math.max / math.min

```
math.max(...: number): number
math.min(...: number): number
```

Returns the maximum / minimum value among the arguments.

### math.modf

```
math.modf(x: number): (number, number)
```

Returns the integral part of `x` and the fractional part of `x`.

### math.noise

```
math.noise(x: number, y: number?, z: number?): number
```

Returns a Perlin noise value. The result is typically between `-1` and `1`. Useful for generating natural-looking random variation (terrain, textures, motion).

### math.pow

```
math.pow(x: number, y: number): number
```

Returns `x^y`. Equivalent to the `^` operator.

### math.random

```
math.random(): number
math.random(m: number): number
math.random(m: number, n: number): number
```

- Called with no arguments: returns a pseudo-random real number in `[0, 1)`.
- Called with one argument `m`: returns a pseudo-random integer in `[1, m]`.
- Called with two arguments `m, n`: returns a pseudo-random integer in `[m, n]`.

### math.randomseed

```
math.randomseed(x: number): ()
```

Sets the seed for the pseudo-random generator.

### math.round

```
math.round(x: number): number
```

Returns `x` rounded to the nearest integer (half rounds away from zero).

### math.sign

```
math.sign(x: number): int
```

Returns `-1` if `x < 0`, `0` if `x == 0`, and `1` if `x > 0`.

### math.sqrt

```
math.sqrt(x: number): number
```

Returns the square root of `x`.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/math
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/math.yaml
Captured: 2026-04-16
