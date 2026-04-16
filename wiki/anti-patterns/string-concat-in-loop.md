---
title: string-concat-in-loop
type: anti-pattern
category: anti-patterns
subcategory: performance
owner: performance-analyst
status: draft
created: 2026-04-16
updated: 2026-04-16
severity: low
sources:
  - .claude/docs/luau-style-guide.md
related:
  - "[[table-library]]"
tags: [anti-pattern, performance]
---

# String Concatenation in Loop

> Using `s = s .. "text"` inside a loop. Each concatenation allocates a new string, making the total cost O(n^2) in the number of iterations.

**Severity:** Low

## What It Looks Like

```lua
-- Building a leaderboard string
local result = ""
for i, entry in ipairs(leaderboard) do
    result = result .. entry.name .. ": " .. tostring(entry.score) .. "\n"
end

-- Serializing inventory
local output = "{"
for itemId, count in pairs(inventory) do
    output = output .. itemId .. "=" .. tostring(count) .. ","
end
output = output .. "}"

-- Logging with concatenation in a hot path
RunService.Heartbeat:Connect(function()
    local log = ""
    for _, player in ipairs(Players:GetPlayers()) do
        log = log .. player.Name .. " "
    end
    -- ...
end)
```

## Why It's Bad

1. **O(n^2) allocation cost**: Luau strings are immutable. Each `s = s .. "x"` creates a brand-new string that copies all of `s` plus the appended text. For a loop of N iterations, the total bytes copied is approximately 1 + 2 + 3 + ... + N = N(N+1)/2, which is O(n^2).
2. **GC pressure**: each intermediate string becomes garbage immediately after the next concatenation. For a 1000-iteration loop, that is 999 temporary string objects the garbage collector must eventually sweep.
3. **Frame time impact**: in hot paths (Heartbeat, RenderStepped), the allocation and GC overhead can cause frame-time spikes visible in the MicroProfiler.
4. **Scales poorly**: the cost is invisible at 10 iterations but becomes a real problem at 100-1000+. Leaderboards, inventories, chat logs, and serialization routines regularly hit these sizes.

Benchmark: `table.concat` is approximately 8x faster than `..` at 1000 iterations on Roblox servers.

## How to Fix It

Collect pieces into a table, then join with `table.concat`:

```lua
-- Before (O(n^2))
local result = ""
for i, entry in ipairs(leaderboard) do
    result = result .. entry.name .. ": " .. tostring(entry.score) .. "\n"
end

-- After (O(n))
local parts = table.create(#leaderboard)
for i, entry in ipairs(leaderboard) do
    parts[i] = entry.name .. ": " .. tostring(entry.score)
end
local result = table.concat(parts, "\n")
```

For more complex formatting, use `string.format`:

```lua
local parts = table.create(#leaderboard)
for i, entry in ipairs(leaderboard) do
    parts[i] = string.format("%s: %d", entry.name, entry.score)
end
local result = table.concat(parts, "\n")
```

Use `table.create(n)` to preallocate the array when the size is known, avoiding incremental table resizing.

**Exception**: a small, fixed number of concatenations (2-3) outside a loop is fine. The anti-pattern is specifically concatenation inside a loop.

## Detection

```
= .* %.%. .* -- inside a for/while block
for.*do[^]*%.%.[^]*end
```

More practically, search for patterns like:

```
result = result ..
output = output ..
str = str ..
s = s ..
```

Any of these inside a `for` or `while` block is a violation.

## Related

- [[table-library]]

## Sources

- [Luau Style Guide](../../.claude/docs/luau-style-guide.md)
- [Luau Performance: string concatenation benchmarks](../raw/community/performance/luau/string-concatenation-performance.md)
