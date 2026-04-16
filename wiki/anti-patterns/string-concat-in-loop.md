---
title: string-concat-in-loop
type: anti-pattern
category: anti-patterns
subcategory: performance
owner: performance-analyst
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: low
related:
  - "[[table-library]]"
tags: [anti-pattern, performance]
---

# String Concatenation in Loop

**Severity:** Low
**Status:** stub

Using `s = s .. "foo"` inside a loop. Each concatenation creates a new string — the total cost is O(n²) in the number of iterations. For long loops, use `table.concat`.

## Fix

```lua
-- ❌
local s = ""
for i = 1, 1000 do
    s = s .. tostring(i)
end

-- ✅
local parts = table.create(1000)
for i = 1, 1000 do
    parts[i] = tostring(i)
end
local s = table.concat(parts)
```

Benchmark: `table.concat` is ~8x faster than `..` at 1000 iterations. (Source: `wiki/raw/community/performance/luau/string-concatenation-performance.md`)

## Related

- [[table-library]]
- [wiki/raw/community/performance/luau/string-concatenation-performance.md](../raw/community/performance/luau/string-concatenation-performance.md)
