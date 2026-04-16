---
title: How Luau is Made Fast
type: raw-source
source_url: https://luau.org/performance
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: performance
tags: [luau, performance, vm, native-codegen, gc]
---

# Luau Performance

Luau prioritizes stable, high-performance interpreted code execution. The language focuses on making idiomatic code faster while enabling further optimization through careful tuning. Key distinction: Luau emphasizes interpreter performance over JIT compilation, as many target platforms lack JIT support.

## Core Interpreter & Compilation

### Fast Bytecode Interpreter

The interpreter uses a highly tuned C implementation with compiler-specific optimizations for Clang and MSVC. The interpreter core loop and builtins on x64 compile into ~16 KB, leaving half of the instruction cache for other infrequently called code. Performance rivals LuaJIT's interpreter while maintaining portability.

### Optimizing Compiler

Luau employs multi-pass compilation: source parsing into AST, then bytecode generation. This enables flexible optimization including:

- Deep constant folding across functions
- Upvalue analysis for unmutated values
- Builtin function analysis
- Peephole optimizations

The compiler supports aggressive optimization levels (`-O2`), achieving approximately **"950K lines of Luau code in 1 second on a single core."**

## Advanced Optimizations

### Inline Caching

Table and global field access uses hybrid inline caching and HREF mechanisms. Fastest access requires compile-time known field names (using `table.field` notation) and avoids metatables. Uniform object structures maximize effectiveness.

### Global Access Imports

Chains like `math.max` resolve at load time rather than execution, except in "impure" environments (those using `loadstring`, `getfenv`, or `setfenv`). This eliminates redundant table lookups.

### Method Call Specialization

The `obj:Method` syntax triggers VM-level optimizations. Recommended design: metatables with `__index` pointing directly to a table, avoiding function-based `__index` and deep chains.

### Specialized Builtin Calls ("Fastcall")

In pure environments, builtin functions bypass standard stack frame setup. Direct calls to functions like `math.max(x, 1)` execute significantly faster. Partial specializations include:

- `assert` optimization when return values unused
- `bit32.extract` with constant parameters
- `select(x, ...)` O(1) optimization

## Memory & Data Structure Optimizations

### Table Operations

- Table literals trigger "template" optimizations for object creation
- `table.create()` preallocates storage for array-like tables
- Iteration (`ipairs`, `pairs`, generalized iteration) uses custom internal iterators avoiding function calls per cycle
- Table length uses binary search with branch-free implementation and caching

### Native Vector Math

First-class support for 3-component 32-bit float vectors reduces GC pressure and provides hand-vectorization capability.

### Upvalue Optimization

Immutable upvalues (majority of cases) avoid extra allocations and object closing. Only mutable upvalues require allocated objects, minimizing overhead.

### Closure Caching

Identical function expressions with no upvalues or only immutable module-scope upvalues reuse cached closures, reducing allocation traffic.

### Fast Memory Allocator

Custom allocator inspired by pool allocators and mimalloc outperforms general-purpose allocators (`rpmalloc`, `jemalloc`, `tcmalloc`). Frequent allocations trigger garbage collection assists, so tight-loop allocation should be minimized.

## Garbage Collection

### Incremental Design with Pacing

The incremental collector uses a proportional-integral-derivative controller to maintain target heap size as a percentage of live data, enabling better tuning than Lua 5.x approaches.

### Atomic Phase Reduction

- "Remark" step revisits modified objects incrementally
- Coroutine marking made incremental by distinguishing "active" from "inactive" coroutines
- Weak tables support `s` flag in `__mode` for shrinkable behavior during GC

### Paged Sweeping

Objects of uniform size allocate in 16 KB pages, enabling 2-3x faster sweeping versus linked-list approaches. Eliminates per-object allocation metadata overhead.

## Advanced Code Generation

### Function Inlining & Loop Unrolling (Optimization Level 2)

- Only local functions eligible for inlining when body is simple enough
- Loops with compile-time bounds unroll when profitable
- Both enable secondary optimizations (constant folding, instruction specialization)
- Recursive calls cannot be inlined; disabled for modules using `getfenv`/`setfenv`

### Debugger Implementation

First-class breakpoint support via bytecode patching and custom interpreter loop avoids hook overhead, maintaining "stable and predictable performance" during debugging.

## String & Library Optimizations

Dynamic string buffers optimize smaller strings while handling larger concatenations without unnecessary copies. Functions like `table.sort` use `introsort` for guaranteed O(N log N) worst-case complexity.

## Source

- Original URL: https://luau.org/performance
- Captured: 2026-04-16
