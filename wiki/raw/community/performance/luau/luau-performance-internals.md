---
title: How Luau Makes Code Fast - Performance Internals
type: raw-source
source_url: https://luau.org/performance/
source_type: official-docs
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: luau
tags: [luau, inline-cache, vector, fastcall, jit, gc, internals]
---

# How Luau Makes Code Fast - Performance Internals

## Core Interpreter Design

Luau features a "highly tuned portable bytecode interpreter" written in C that achieves performance comparable to LuaJIT's hand-optimized assembly on some workloads. The interpreter compiles to approximately **16 KB on x64**, preserving instruction cache efficiency.

## Compiler Architecture

Multi-pass compiler with separate frontend (AST parsing) and backend (bytecode generation).

**Throughput**: ~950K lines of code per second on modern hardware with optimizations enabled.

## Inline Caching Strategy

Table field access leverages "inline caching blended with HREFs" for rapid lookups.

**Performance depends on:**
1. Compile-time-known field names
2. Avoidance of metatables for field access
3. Uniform object structures

**Recommendation**: Use `table.field` notation rather than `table["field"]` bracket syntax for optimal results.

## Vector Type Support

Luau provides a **native vector type** storing "a 32-bit floating point vector with 3 components," offering first-class SIMD support.

Benefits:
- Reduced garbage collection pressure
- Execution time savings for vector-heavy computations

## Method Call Optimization

Specialized "namecall" mechanisms optimize method invocations on reflected userdata. Minimizes interop overhead compared to traditional Lua binding models.

```lua
-- Fast path (namecall specialization)
part:Clone()  -- single bytecode dispatch

-- Slower
local clone = part.Clone
clone(part)
```

## Fastcall Mechanism

Built-in functions undergo "fastcall" specialization in pure environments, bypassing stack frame setup.

**Supported**: math library, string/table utilities, type checking functions.

Some specializations like `math.floor` leverage "advanced SIMD instruction sets like SSE4.1 when available."

## Upvalue Optimization

Immutable upvalues avoid allocation overhead - captured by value rather than requiring GC objects. Addresses the reality that "**90% or more of upvalues aren't mutated in typical Lua code.**"

## JIT Compilation

Optional JIT (native codegen) targets x64 and arm64 platforms:
- Compiles selected functions with type-annotation specialization
- Lacks automated compilation decisions based on runtime analysis
- Unlike LuaJIT's profiling-driven approach, requires `--!native` directive

## Garbage Collection

Incremental collector implementation:
- **Proportional-integral-derivative controller** for heap pacing
- Incremental coroutine marking to reduce atomic pauses
- **Paged sweeper**: 2-3x faster sweeping than linked-list approaches
- Saves **16 bytes per object** compared to older designs

## Advanced Optimizations (Level 2)

Aggressive compilation:
- Function inlining for local functions
- Loop unrolling for compile-time-bounded loops
- Heuristics determine profitability automatically

## Key Performance Rules

1. Use `:` method syntax (namecall specialization)
2. Use dot notation `t.field` over bracket `t["field"]`
3. Mark `local` to help upvalue analysis
4. Use `vector` type for 3D math (SIMD)
5. Use built-in library functions (fastcall)
6. Avoid `getfenv`/`setfenv` (deoptimizes)
7. Annotate types for native codegen
8. Keep uniform object shapes (helps inline cache)

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Interpreter size (x64) | ~16 KB |
| Compiler throughput | 950K LoC/s |
| GC per-object savings | 16 bytes |
| Paged sweeper speedup | 2-3x |
| Upvalue immutability rate | 90%+ |

## Source

Original URL: https://luau.org/performance/
Captured: 2026-04-16
