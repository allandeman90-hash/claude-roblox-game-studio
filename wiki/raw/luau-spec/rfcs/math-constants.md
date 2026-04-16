---
title: "RFC: math Constants"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/math-constants.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, math, constants]
---

# RFC: math Constants

## Overview

Expands Luau's `math` library with new constants.

## Existing Constants

- `math.pi` (since Lua 5.0)
- `math.huge` (since Lua 5.1)

## Proposed New Constants

- **`math.nan`** — some `NaN` value as defined by IEEE 754
- **`math.e`** — Euler's number (~2.718)
- **`math.phi`** — The golden ratio (~1.618)
- **`math.sqrt2`** — The square root of 2 (equal to `math.sqrt(2)`)
- **`math.tau`** — The mathematical constant τ, defined as `2 * math.pi`

## Motivation

`math.nan` works properly with the new `math.isnan()` function, since comparing directly to NaN always returns false in IEEE 754 floating-point arithmetic.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/math-constants.md
- Captured: 2026-04-16
