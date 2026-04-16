---
title: String Concatenation Performance - table.concat vs ..
type: raw-source
source_url: https://devforum.roblox.com/t/stringbuilder-library-much-faster-concatenation/475708
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: luau
tags: [string, concatenation, table-concat, stringbuilder, benchmark]
---

# String Concatenation Performance

## The Issue

Luau's `..` string concatenation operator creates a new string object for each operation. In tight loops with many concatenations, this causes significant memory allocation and performance degradation.

## Benchmarks

### 100,000 steps, 100 concatenations each

| Method | Time |
|--------|------|
| Raw `..` concatenation | 3.79 ms |
| `table.concat` | 3.59 ms |
| StringBuilder | 5.66 ms |

### 10,000 steps, 1,000 concatenations each

| Method | Time |
|--------|------|
| Raw `..` concatenation | **31.38 ms** |
| `table.concat` | **3.87 ms** |
| StringBuilder | 6.01 ms |

**Key observation**: At 1,000 concatenations per iteration, raw `..` took ~8x longer than `table.concat`. The gap grows as concatenation count increases.

## Critical Insight

Table concatenation dramatically outperforms the raw `..` operator when performing many concatenation operations. The standard pattern:

```lua
-- BAD: O(n^2) string allocation
local result = ""
for i = 1, 1000 do
    result = result .. tostring(i) .. ","
end

-- GOOD: Single allocation at the end
local parts = {}
for i = 1, 1000 do
    parts[#parts + 1] = tostring(i)
end
local result = table.concat(parts, ",")
```

## Why

The `..` operator allocates a new string each time, copying all previous content. This is O(n^2) when accumulating in a loop. `table.concat` performs a single allocation after all parts are known, which is O(n).

## When to Use What

| Use Case | Recommended Method |
|----------|-------------------|
| 2-3 concatenations | `..` is fine |
| Loop, <10 iterations | `..` is fine |
| Loop, 10-100 iterations | `table.concat` preferred |
| Loop, 100+ iterations | `table.concat` required |
| Building large strings | `table.concat` always |

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| `..` 1000 concats (per iter) | 31.38 ms / 10k iters |
| `table.concat` 1000 concats | 3.87 ms / 10k iters |
| Speedup at 1000 concats | ~8x |

## Source

Original URL: https://devforum.roblox.com/t/stringbuilder-library-much-faster-concatenation/475708
Captured: 2026-04-16
