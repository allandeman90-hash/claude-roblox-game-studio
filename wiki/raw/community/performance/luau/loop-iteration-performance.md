---
title: Luau Loop Iteration Performance - pairs vs ipairs vs generalized
type: raw-source
source_url: https://devforum.roblox.com/t/thats-why-you-should-never-use-the-pairs-and-ipairs-iterators-in-luau/3345240
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: luau
tags: [loops, pairs, ipairs, iteration, performance]
---

# Luau Loop Iteration Performance

## Modern Luau: Generalized Iteration

In modern Luau, you can iterate directly over a table without `pairs` or `ipairs`:

```lua
-- Modern Luau (fastest)
for i, v in array do
    -- ...
end

-- vs older patterns
for i, v in ipairs(array) do end  -- slower
for k, v in pairs(dict) do end    -- slower
```

## Benchmark Results

### Test 1: Exponentiation (1,000 element array, 100,000 iterations)
| Method | Time |
|--------|------|
| Direct loop (`in array`) | 6.402 us |
| `ipairs` | ~6.7 us (~8% slower) |
| `pairs` | 6.44 us (~0.7% slower) |

### Test 2: String Concatenation (1,000 strings, 10,000 iterations)
| Method | Time |
|--------|------|
| Direct loop | 303.65 us |
| `ipairs` | 303.45 us (~0.07% faster) |
| `pairs` | 305.98 us (~0.75% slower) |

### Test 3: Table Creation (1,000 elements, 1,000 iterations)
| Method | Difference |
|--------|-----------|
| Direct loop | baseline |
| `ipairs` | ~0.61% slower |
| `pairs` | ~1.56% slower |

## Technical Explanation

Both `pairs` and `ipairs` are higher-order functions returning iterator functions, introducing function call overhead compared to direct array access, which "bypasses intermediate functions."

## Fastest Patterns

For maximum speed, use:
```lua
-- Best: direct generalized iteration
for i, v in array do end

-- Fast: next iterator (small arrays)
for i, v in next, array do end

-- For arrays only, if you only need values:
for i = 1, #array do
    local v = array[i]
end
```

## When to Use What

| Use Case | Recommended |
|----------|-------------|
| Arrays (1, 2, 3, ...) | `for i, v in array` or `for i = 1, #array` |
| Dictionaries | `for k, v in dict` (generalized) |
| Sparse arrays | `for k, v in dict` |
| Ordered numeric index | `for i = 1, N` |

## Key Insight

The difference is tiny (<10%). Don't rewrite existing `pairs`/`ipairs` code for a 1% gain. But prefer generalized iteration for new code.

"ipairs works really fast in Luau, contrary to what most online resources say about ipairs in vanilla Lua"

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| ipairs overhead | <8% |
| pairs overhead | <2% |
| Generalized iteration | baseline (fastest) |

## Source

Original URL: https://devforum.roblox.com/t/thats-why-you-should-never-use-the-pairs-and-ipairs-iterators-in-luau/3345240
Captured: 2026-04-16
