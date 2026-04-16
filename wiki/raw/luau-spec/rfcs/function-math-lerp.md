---
title: "RFC: math.lerp"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/function-math-lerp.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, math, lerp]
---

# RFC: math.lerp

## Design

```lua
function math.lerp(a: number, b: number, t: number): number
    return if t == 1 then b else a + (b - a) * t
end
```

Accepts any numeric values for `a` and `b` (including reversed ranges); `t` may fall outside `[0, 1]`.

## Semantics

- **Exactness**: `lerp(a, *, 0) = a` and `lerp(*, b, 1) = b`
- **Consistency**: `lerp(x, x, t) == x` for all `t`
- **Monotonicity**: Maintains order within `[0, 1]` interval
- **Boundedness**: Results stay within `[a, b]` for `t ∈ [0, 1]`

## Precision Guarantees

> "The implementation does not guarantee all possible properties of a `lerp` function, and represents a balance between performance and numerical quality."

**Limitations:**
- **No determinacy guarantee**: May produce NaN if `b - a` overflows
- **Monotonicity caveat**: Not formally proven near `t=1`, though extensive fuzzing (~300 billion test triples) found no counterexamples
- **No FMA analysis**: Properties evaluated without fused multiply-add operations

Prioritizes performance (6-9 CPU instructions) over absolute robustness compared to C++ `std::lerp`.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/function-math-lerp.md
- Captured: 2026-04-16
