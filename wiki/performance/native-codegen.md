---
title: Native Codegen
type: performance
category: performance
subcategory: luau
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/luau/native-code-generation.md
related:
  - "[[heartbeat-budget]]"
  - "[[microprofiler]]"
  - "[[parallel-luau]]"
tags: [performance, luau, native, codegen]
---

# Native Codegen

## Summary

Luau native code generation compiles Luau source directly to CPU machine code (x86-64 or AArch64) instead of bytecode. It accelerates compute-heavy scripts -- mathematical operations on numbers, tables, and `buffer` types -- with typical speedups of **1.5-2.5x** and up to **3.2x** in benchmarks. It does not accelerate Roblox Engine API calls, built-in library functions, or UI code.

## Measurements / Budgets

| Metric | Value | Source |
|--------|-------|--------|
| **Typical speedup** | **1.5-2.5x** | [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md) |
| **Max observed speedup** (Mandelbrot) | **3.2x** | [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md) |
| Single code block limit | **64K instructions** | [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md) |
| Function block limit | **32K internal blocks** | [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md) |
| Module instruction limit | **1M instructions per script** | [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md) |

### What Gets Faster

- Scalar mathematics and numerical algorithms
- Heavy computation on numbers and arrays
- Functions spending significant time on calculations rather than object creation
- Mathematical operations on `buffer` types

### What Does NOT Benefit

- Calls to Roblox Engine APIs (CFrame assignments, UI manipulation)
- Built-in library functions (`table.sort`, `math.abs`)
- Code primarily defining data structures
- Time spent calling Lua/C functions

## How to Measure

1. Use **ScriptProfiler** (F9 > ScriptProfiler tab) -- native functions display a `<native>` annotation. Missing annotations indicate compilation issues.
2. Use `debug.dumpcodesize()` from the Studio Command Bar to monitor native code consumption by script and function.
3. Monitor memory categories `lua/codegen` and `lua/codegenpages` in the Developer Console.
4. Profile with MicroProfiler before and after adding `--!native` to confirm measurable improvement.

Source: [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md)

## Common Issues

### Deoptimization Triggers

Code using these features reverts to interpreted execution, negating all native gains:
- Deprecated `getfenv()` / `setfenv()` calls
- Built-in functions with non-numeric arguments (e.g., `math.abs` on non-numbers)
- Type mismatches in typed function parameters

### Exceeding Instruction Limits

Functions that exceed 64K instructions or modules exceeding 1M instructions trigger errors like "_Function 'f' exceeded single code block instruction limit_". The fix is to split the function or simplify the logic.

### Memory Overhead

Native code consumes additional memory tracked under `lua/codegen` and `lua/codegenpages`. There is significant fixed overhead even without active native scripts. Apply `--!native` selectively.

## Optimization Patterns

### Script-Level Activation

Add a comment at the top of the script:

```lua
--!native

local function heavyComputation(data: {number}): number
    local sum = 0
    for _, v in data do
        sum += v * v
    end
    return sum
end
```

### Function-Level Activation

Use the `@native` attribute on specific functions:

```lua
@native
local function mandelbrot(cx: number, cy: number): number
    local x, y = 0, 0
    for i = 0, 255 do
        if x * x + y * y > 4 then return i end
        x, y = x * x - y * y + cx, 2 * x * y + cy
    end
    return 256
end
```

### Type Annotations for Better Codegen

The compiler generates better native code with explicit type declarations:

```lua
-- Slower: compiler assumes generic table, adds type checks
local function sumSlow(v)
    return v.X + v.Y + v.Z
end

-- Faster: compiler specializes for Vector3
local function sumFast(v: Vector3)
    return v.X + v.Y + v.Z
end
```

Source: [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md)

## Pitfalls

- **Not available on clients** as of 2025. Works in Studio and on servers only. Client-side native codegen is deferred indefinitely.
- **Hardware requirements**: Windows/Intel Mac requires AVX1 (Sandy Bridge 2011+). Apple Silicon requires macOS 13 Ventura+.
- **Debugging is limited**: locals/upvalues views may be incomplete in native mode. Breakpoints disable native execution for affected functions.
- **Do not blanket-apply `--!native`** to every module. UI code, data structure definitions, and network handlers will not benefit and will consume native code memory budget.

## Related

- [[heartbeat-budget]]
- [[microprofiler]]
- [[parallel-luau]]

## Sources

- [native-code-generation.md](../raw/community/performance/luau/native-code-generation.md)
