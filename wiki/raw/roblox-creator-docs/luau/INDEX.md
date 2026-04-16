---
title: Luau Documentation Index (Roblox Creator Docs)
type: index
category: luau-language
captured_at: 2026-04-16
captured_by: research-agent-2
source_base_url: https://create.roblox.com/docs/luau/
github_source_base: https://github.com/Roblox/creator-docs/tree/main/content/en-us/luau
---

# Luau Documentation Index — Roblox Creator Docs

This index lists every Luau topic captured from Roblox's official creator documentation at `create.roblox.com/docs/luau/` and the related engine library references at `create.roblox.com/docs/reference/engine/libraries/`. All files were sourced from the public `Roblox/creator-docs` GitHub repository (raw markdown/YAML) for fidelity.

**Base URL:** https://create.roblox.com/docs/luau/ (Luau language topics)
**Library URL:** https://create.roblox.com/docs/reference/engine/libraries/ (standard library references)
**GitHub mirror:** https://github.com/Roblox/creator-docs/tree/main/content/en-us/

## Language Fundamentals

| File | Source URL | Summary |
|---|---|---|
| [booleans.md](./booleans.md) | https://create.roblox.com/docs/luau/booleans | The `bool` type, conditionals, and how Luau evaluates truthiness (both `0` and `""` are truthy). |
| [numbers.md](./numbers.md) | https://create.roblox.com/docs/luau/numbers | Double-precision numbers, `float`/`int`/`int64` classifications, notation (decimal, hex, binary, scientific, underscore separators), rounding. |
| [strings.md](./strings.md) | https://create.roblox.com/docs/luau/strings | String declaration, multi-line/nested brackets, concatenation, escape sequences, string interpolation (backticks), comparisons, and the full string pattern reference (classes, magic chars, anchors, modifiers, sets, captures). |
| [nil.md](./nil.md) | https://create.roblox.com/docs/luau/nil | `nil` as non-existence, garbage collection, using `nil` to remove variables/table entries/instance parents. |
| [variables.md](./variables.md) | https://create.roblox.com/docs/luau/variables | Variable naming rules, reserved keywords, best-practice naming (PascalCase, camelCase, LOUD_SNAKE_CASE), multiple assignment, `local` vs global. |
| [operators.md](./operators.md) | https://create.roblox.com/docs/luau/operators | Logical (`and`/`or`/`not`), relational, arithmetic, compound assignment (`+=`, `-=`, `..=`), concatenation `..`, length `#`, metamethod associations. |
| [control-structures.md](./control-structures.md) | https://create.roblox.com/docs/luau/control-structures | `if`/`elseif`/`else`, `while`, `repeat-until`, numeric `for`, generic `for` with `ipairs`/`pairs`, generalized iteration with `__iter`, `break`, `continue`. |
| [functions.md](./functions.md) | https://create.roblox.com/docs/luau/functions | Function definitions, parameters, return values, methods (colon syntax, `self`), callbacks, event handlers, anonymous functions, variadic functions (`...`), `unpack()`. |
| [tables.md](./tables.md) | https://create.roblox.com/docs/luau/tables | Tables as arrays and dictionaries, 1-based indexing, insert/remove, iteration, table references (not copies), shallow/deep clones, shallow/deep freezes. |
| [metatables.md](./metatables.md) | https://create.roblox.com/docs/luau/metatables | `setmetatable`/`getmetatable`, full metamethod list (`__index`, `__newindex`, `__call`, `__add`, `__eq`, `__lt`, `__iter`, `__mode`, etc.), `rawset`, set datatype example. |
| [scope.md](./scope.md) | https://create.roblox.com/docs/luau/scope | Global vs local scope, performance implications of globals, capturing upvalues, variable shadowing. |
| [comments.md](./comments.md) | https://create.roblox.com/docs/luau/comments | Single-line (`--`), block (`--[[ ]]`), nested brackets, comment directives (`--!strict`, `--!nonstrict`, `--!nocheck`, `--!native`, `--!optimize 0/1/2`), `TODO` highlighting. |
| [tuples.md](./tuples.md) | https://create.roblox.com/docs/luau/tuples | Tuples as multi-value parameters and returns in the Roblox API, worked example with `Players:GetUserThumbnailAsync`. |
| [userdata.md](./userdata.md) | https://create.roblox.com/docs/luau/userdata | Userdata as arbitrary C/C++ data in Luau (stub page — links to Lua PIL). |
| [enums.md](./enums.md) | https://create.roblox.com/docs/luau/enums | `Enum` global, `GetEnumItems()`, `EnumItem` properties (`Name`, `Value`, `EnumType`), setting enum values by full declaration or string name. |

## Luau-Specific Features

| File | Source URL | Summary |
|---|---|---|
| [type-checking.md](./type-checking.md) | https://create.roblox.com/docs/luau/type-checking | Gradual type system: `type` keyword, inference modes (`--!nocheck`, `--!nonstrict`, `--!strict`), primitive types, optional types (`?`), literal types, type casts (`::`), function typing, table types, variadics, unions/intersections, `typeof`, generics (`<T>`), `export type`. |

## Standard Libraries

| File | Source URL | Summary |
|---|---|---|
| [task-library.md](./task-library.md) | https://create.roblox.com/docs/reference/engine/libraries/task | `task.spawn`, `task.defer`, `task.delay`, `task.wait`, `task.cancel`, `task.synchronize`, `task.desynchronize` — Roblox scheduler-integrated alternatives to deprecated globals. |
| [coroutine-library.md](./coroutine-library.md) | https://create.roblox.com/docs/reference/engine/libraries/coroutine | `coroutine.create/resume/yield/wrap/status/close/running/isyieldable` — explicit cooperative multitasking. |
| [table-library.md](./table-library.md) | https://create.roblox.com/docs/reference/engine/libraries/table | `table.clear/clone/concat/create/find/freeze/insert/isfrozen/move/pack/remove/sort/unpack`, plus deprecated `table.foreach/foreachi/getn`. |
| [string-library.md](./string-library.md) | https://create.roblox.com/docs/reference/engine/libraries/string | `string.byte/char/find/format/gmatch/gsub/len/lower/match/pack/packsize/rep/reverse/split/sub/unpack/upper` — full specifier/flag/width/precision tables for `string.format`. |
| [math-library.md](./math-library.md) | https://create.roblox.com/docs/reference/engine/libraries/math | `math.huge/pi/e/phi/tau/sqrt2/nan` constants; `math.abs/ceil/floor/round/clamp/lerp/map/sign`, trig, hyperbolic, `math.random/randomseed`, `math.noise` (Perlin), `math.isfinite/isinf/isnan`. |
| [os-library.md](./os-library.md) | https://create.roblox.com/docs/reference/engine/libraries/os | `os.clock` (benchmarking), `os.time`, `os.date` (strftime specifiers), `os.difftime` — sandboxed from standard Lua `os`. |
| [buffer-library.md](./buffer-library.md) | https://create.roblox.com/docs/reference/engine/libraries/buffer | Fixed-size mutable binary memory: `create/fromstring/tostring/len`, read/write `i8`/`u8`/`i16`/`u16`/`i32`/`u32`/`f32`/`f64`, `readbits`/`writebits`, `readstring`/`writestring`, `copy`, `fill`. Little-endian. |
| [bit32-library.md](./bit32-library.md) | https://create.roblox.com/docs/reference/engine/libraries/bit32 | 32-bit integer bitwise ops: `band/bor/bxor/bnot/btest`, shifts (`lshift/rshift/arshift`), rotates (`lrotate/rrotate`), `extract/replace`, `countlz/countrz`, `byteswap`. |
| [debug-library.md](./debug-library.md) | https://create.roblox.com/docs/reference/engine/libraries/debug | `debug.traceback/info`, MicroProfiler (`profilebegin/profileend`), memory categories, `dumpcodesize`. Restricted vs standard Lua. |

## Scripting & Concurrency

| File | Source URL | Summary |
|---|---|---|
| [task-scheduler.md](./task-scheduler.md) | https://create.roblox.com/docs/scripting/scheduler | Overview of why `task.*` methods replace deprecated globals (`wait`, `spawn`, `delay`), with legacy-vs-modern comparison table. |
| [module-scripts.md](./module-scripts.md) | https://create.roblox.com/docs/scripting/module | `ModuleScript` basics, `require()`, module caching, circular-dependency warning, `WaitForChild()` for replication safety. |

## Topics NOT captured (handoff to agent-5)

The following topics were referenced inside these files but not directly captured, and should be picked up from the luau-lang.org spec by agent-5:

- **Error handling** — `pcall`, `xpcall`, `error`, `assert` — Roblox creator-docs does not host a dedicated markdown page for these globals. The `coroutine` doc mentions that yielding inside pcall/xpcall is the exception to the metamethod-yielding prohibition, but does not document the globals themselves. See https://luau.org/ or the Lua 5.1 manual for formal specs.
- **Native code generation (`native-code-gen.md`)** — referenced in `comments.md` (`--!native` directive) but not fetched due to budget constraints. File exists at https://github.com/Roblox/creator-docs/blob/main/content/en-us/luau/native-code-gen.md
- **Queues (`queues.md`)** and **Stacks (`stacks.md`)** — Luau-specific data-structure examples; not fetched due to budget.
- **Type coercion (`type-coercion.md`)** — not fetched due to budget.
- **C# comparison (`luau-csharp-comparison.md`)** — not a core language topic.
- **Parallel Luau (`scripting/multithreading.md`)** — referenced heavily in `task-library.md` for `task.synchronize`/`desynchronize`; detailed doc lives outside the `/luau/` directory.
- **`utf8` library** and **`vector` library** — listed in the libraries directory but not captured due to budget.

## Notes on URL structure

The **actual base URL** for Luau language topics on create.roblox.com is:

```
https://create.roblox.com/docs/luau/<topic>
```

(NOT `/docs/scripting/luau/` as hypothesized in the original scope.) Standard library references live at:

```
https://create.roblox.com/docs/reference/engine/libraries/<library>
```

Scripting and concurrency topics (scheduler, module, multithreading, etc.) live under:

```
https://create.roblox.com/docs/scripting/<topic>
```

All source files are mirrored verbatim in the public `Roblox/creator-docs` GitHub repository under `content/en-us/`. Fetching `raw.githubusercontent.com` URLs directly is the fastest and most faithful way to capture these docs — the rendered HTML on create.roblox.com adds navigation chrome that obscures the text.
