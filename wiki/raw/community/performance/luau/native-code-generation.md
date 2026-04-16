---
title: Luau Native Code Generation
type: raw-source
source_url: https://create.roblox.com/docs/luau/native-code-gen
source_type: official-docs
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: luau
tags: [luau, native, codegen, performance, machine-code]
---

# Luau Native Code Generation

## What It Is

Luau native code generation translates Luau code directly into CPU machine code (x86-64 or AArch64) instead of bytecode. Works best for "scripts that perform a lot of computation directly inside Luau," particularly those with mathematical operations on tables and `buffer` types.

## Enabling Native Compilation

### Script-level activation
Add a comment at the script's top:
```lua
--!native

print("Hello from native code!")
```

### Function-level activation
Use the `@native` attribute on specific functions:
```lua
@native
local function f(x)
  return (x + 1)
end
```

## Performance Benchmarks

- **Mandelbrot implementation**: 3.2x speedup (community benchmark)
- **Expected range**: 1.5-2.5x improvement for computation-heavy functions
- **Intersection tests**: 2-3x average improvement reported
- Type annotations reportedly improve native code performance

## What Gets Faster

Native compilation accelerates:
- Scalar mathematics and numerical algorithms
- Code with heavy computation on numbers and arrays
- Functions spending significant time on calculations rather than object creation
- Mathematical operations on tables and `buffer` types

## What Does NOT Benefit

Native compilation does **not** accelerate:
- Calls to Roblox Engine APIs (CFrame assignments, UI manipulation)
- Built-in library functions (`table.sort`)
- Code primarily defining data structures
- UI code
- Time spent calling Lua/C functions (engine APIs)

## Type Annotations Matter

The compiler performs better with explicit type declarations:

```lua
-- Slower: assumes table, adds unnecessary checks
local function sumComponentsSlow(v)
    return v.X + v.Y + v.Z
end

-- Faster: specializes for Vector3
local function sumComponentsFast(v: Vector3)
    return v.X + v.Y + v.Z
end
```

## Code to Avoid (Triggers Deoptimization)

Code using these features reverts to interpreted execution:
- Deprecated `getfenv()` / `setfenv()` calls
- Built-in functions with non-numeric arguments (e.g., `math.abs` on non-numbers)
- Improperly typed parameters to typed functions
- Type mismatches in typed functions

## Technical Limits

Native compilation enforces strict memory constraints:

| Limit | Value |
|-------|-------|
| Single code block | 64K instructions max |
| Function code blocks | 32K internal blocks max |
| Module total | 1 million instructions per script |
| Global memory limit | Exists for all native code across experience |

Exceeding these triggers errors like "_Function 'f' exceeded single code block instruction limit_" and requires code simplification or splitting.

## Memory Overhead

Additional memory tracked under these categories in profilers:
- `lua/codegen`
- `lua/codegenpages`

Significant fixed overhead exists even without active native scripts. Choose scripts carefully for native compilation.

## Hardware & Platform Requirements

- **Windows/Intel Mac**: AVX1 instruction set (Intel Sandy Bridge 2011+, AMD Bulldozer+)
- **Apple Silicon**: ARM-native build required; macOS 13 Ventura or later
- **Platforms**: Studio, servers (yes); clients (deferred indefinitely as of 2025)

## Studio Tools Support

### Debugging
Locals/upvalues views may be incomplete; breakpoints disable native execution for affected functions.

### Script Profiler
Native functions display `<native>` annotation; missing labels indicate compilation issues.

### Memory Analysis
Use `debug.dumpcodesize()` from the Command Bar to monitor native code consumption by script and function.

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Mandelbrot speedup | 3.2x |
| Typical speedup | 1.5-2.5x |
| Single code block limit | 64K instructions |
| Function block limit | 32K internal blocks |
| Module instruction limit | 1M instructions |

## Recommendations

- Apply selectively to compute-intensive modules only
- Profile before and after implementing
- Use ScriptProfiler to confirm measurable improvements
- Add explicit type annotations for best results
- Avoid on UI/network/data-structure-only modules

## Source

Original URLs:
- https://create.roblox.com/docs/luau/native-code-gen
- https://devforum.roblox.com/t/luau-native-code-generation-preview-studio-beta/2572587

Captured: 2026-04-16
