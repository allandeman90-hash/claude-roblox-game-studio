---
title: "RFC: math.map"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/function-math-map.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, math]
---

# RFC: math.map

**Status:** Implemented

## Purpose

Maps numbers between different ranges, commonly needed in game development. Implementation formula:

```lua
outmin + (x - inmin) * (outmax - outmin) / (inmax - inmin)
```

## Details

**Function Signature:** Takes five parameters — the value to map and the min/max bounds of both input and output ranges — returning the mapped number.

**Design Choice:** Allows values outside the input range (extrapolation). Clamped versions aren't included since "clamped mapping is not as widely used and can be easily replicated using `math.clamp`."

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/function-math-map.md
- Captured: 2026-04-16
