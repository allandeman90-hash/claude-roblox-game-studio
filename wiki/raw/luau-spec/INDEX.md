---
title: Luau Spec Raw Source Index
type: index
category: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
---

# Luau Language Specification - Raw Source Index

This directory contains captures of the authoritative Luau language specification from **luau.org** (formerly luau-lang.org) and the **luau-lang/luau** / **luau-lang/rfcs** GitHub repositories, captured 2026-04-16.

It does NOT include Roblox's scripting docs (agent-2), Roblox class references (agent-1), or community tutorials (agents 6-10).

## language/ — Language Overview, Syntax & Semantics

| File | Topic |
|---|---|
| `language/home.md` | Luau overview / why Luau / adoption |
| `language/syntax.md` | Full syntax reference (strings, numbers, continue, compound assignment, type annotations, if-expressions, generalized iteration, string interpolation, floor division) |
| `language/compatibility.md` | Lua 5.1 / 5.2 / 5.3 / 5.4 / 5.5 compatibility matrix and intentional deviations |
| `language/grammar.md` | EBNF grammar overview |
| `language/lint.md` | Luau linter (28 lint rules documented with severity guidance) |

## types/ — Type System

| File | Topic |
|---|---|
| `types/types-intro.md` | Gradual type system, `--!strict`/`--!nonstrict`/`--!nocheck` modes, type casts |
| `types/basic-types.md` | Primitives (`nil`, `string`, `number`, `boolean`, `table`, `function`, `thread`, `userdata`, `vector`, `buffer`), `any`/`unknown`/`never`, variadics, type packs, singletons |
| `types/tables.md` | Sealed/unsealed/generic tables, array shorthand `{T}`, indexers |
| `types/unions-and-intersections.md` | `\|` and `&` types, tagged unions, discrimination |
| `types/generics.md` | Generic functions, type parameters, built-in examples |
| `types/type-refinements.md` | Truthy, `type()`, equality refinements; `assert`; tagged union narrowing |
| `types/type-functions.md` | Compile-time `type function`, types library overview |
| `types/oop.md` | `self` typing, method pattern with `setmetatable` |
| `types/considerations.md` | Modules, statically resolvable `require`, cyclic dependencies |
| `types/roblox-types.md` | Foreign types from the embedder, Roblox classes, `Enum.*`, `IsA` refinement |

## library/ — Standard Library

| File | Topic |
|---|---|
| `library/standard-library.md` | Full reference for globals, `math`, `table`, `string`, `coroutine`, `bit32`, `utf8`, `os`, `debug`, `buffer`, `vector` — including every Luau-specific function (`table.clone`, `table.freeze`, `table.isfrozen`, `table.create`, `table.find`, `table.clear`, `math.clamp`, `math.noise`, `math.round`, `math.sign`, `math.lerp`, `math.map`, `string.split`, `bit32.countlz`, `bit32.countrz`, `bit32.byteswap`, all of `buffer.*`, all of `vector.*`) |

## performance/ — Performance & Sandboxing

| File | Topic |
|---|---|
| `performance/performance.md` | Bytecode interpreter, optimizing compiler, inline caches, fastcalls, table/vector optimizations, GC pacing, paged sweeping, function inlining, native codegen |
| `performance/sandbox.md` | Removed libraries, readonly globals, per-script environment isolation, `__gc` removal, CPU interrupt mechanism |

## rfcs/ — Language RFCs

Captured from `luau-lang/rfcs/docs/`. See `rfcs/rfc-process.md` for the full list of all 85 RFCs; captures below focus on the highest-impact language/type/library ones.

### Syntax RFCs
| File | Topic |
|---|---|
| `rfcs/syntax-string-interpolation.md` | Backtick string interpolation |
| `rfcs/syntax-if-expression.md` | `if X then A else B` expressions |
| `rfcs/syntax-continue-statement.md` | `continue` as a context-sensitive keyword |
| `rfcs/syntax-compound-assignment.md` | `+=`, `-=`, `*=`, `/=`, `%=`, `^=`, `..=` |
| `rfcs/syntax-type-ascription.md` | `::` type cast operator |
| `rfcs/syntax-singleton-types.md` | String/boolean literal types; tagged unions |
| `rfcs/syntax-number-literals.md` | Binary `0b`, underscore separators |
| `rfcs/syntax-array-like-table-types.md` | `{T}` shorthand for `{ [number]: T }` |
| `rfcs/syntax-type-alias-type-packs.md` | Type pack parameters in aliases |
| `rfcs/syntax-attributes-functions.md` | `@native`, `@inline`, `@deprecated` |
| `rfcs/syntax-attribute-functions-native.md` | `@native` attribute details |

### Type System RFCs
| File | Topic |
|---|---|
| `rfcs/user-defined-type-functions.md` | `type function` blocks with full `types` library API (types userdata, properties, methods) |
| `rfcs/keyof-type-operator.md` | `keyof<T>` / `rawkeyof<T>` |
| `rfcs/index-type-operator.md` | `index<T, K>` |
| `rfcs/generic-functions.md` | Rank-N polymorphism, `<T>` binders, no turbofish |
| `rfcs/never-and-unknown-types.md` | Top (`unknown`) and bottom (`never`) types |
| `rfcs/new-nonstrict.md` | Unified nonstrict mode, `@checked` annotation |
| `rfcs/property-readonly.md` | `read p: T`, default-readonly methods |
| `rfcs/local-type-inference.md` | New type solver, bounds-based inference |

### Library RFCs
| File | Topic |
|---|---|
| `rfcs/type-byte-buffer.md` | `buffer` type and library |
| `rfcs/function-buffer-bits.md` | `buffer.readbits` / `buffer.writebits` |
| `rfcs/vector-library.md` | Built-in `vector` library |
| `rfcs/function-table-clone.md` | `table.clone` shallow copy |
| `rfcs/function-table-freeze.md` | `table.freeze` / `table.isfrozen` |
| `rfcs/function-math-lerp.md` | `math.lerp` |
| `rfcs/function-math-map.md` | `math.map` |
| `rfcs/math-constants.md` | `math.e`, `math.phi`, `math.tau`, `math.sqrt2`, `math.nan` |

### Semantics & Tooling RFCs
| File | Topic |
|---|---|
| `rfcs/generalized-iteration.md` | `__iter` metamethod, `for x in obj do` |
| `rfcs/config-luaurc.md` | `.luaurc` config format |
| `rfcs/new-require-by-string-semantics.md` | Relative path resolution, `init.luau` |
| `rfcs/deprecate-getfenv-setfenv.md` | Deprecation of `getfenv`/`setfenv` |
| `rfcs/deprecate-table-getn-foreach.md` | Deprecation of `table.getn`/`foreach`/`foreachi` |
| `rfcs/function-inlining.md` | Explanation of why user-controlled inlining is NOT supported |
| `rfcs/rfc-process.md` | RFC process overview + full list of all 85 RFCs |

## Topics Referenced But Not Deeply Covered in Official Docs

The following topics are mentioned in the spec but would benefit from capture by community/practical agents:

- **`math.isnan` / `math.isfinite` / `math.isinf`** — RFC file returned 404; likely not yet in docs
- **Tagged unions in practice** — the Luau docs mention them but don't show exhaustive pattern-matching idioms
- **Advanced type refinement combinations** — docs are terse ("arbitrarily complex")
- **`--!native` file directive** — only briefly mentioned in RFC text; not a dedicated doc page
- **Native code generation details** — the performance page mentions x64/arm64 native codegen but doesn't detail usage
- **`debug.info` format specifiers** — covered in library ref but lacks real-world examples
- **`string.pack` / `string.unpack` format strings** — signatures listed but full format grammar only partially documented
- **Profiling (`/guides/profile/`)** — not yet fetched; dedicated guide exists
- **`--!optimize` level directive** — referenced but not individually documented
- **CHANGELOG.md** — returned 404 at expected path; may be elsewhere
- **Pattern matching / switch** — NOT a Luau feature; tagged unions via refinements are the closest idiom

Community and practical-capture agents (6-10) should focus on:
- Real Luau code idioms showing type refinement combined with `assert`
- Worked examples of user-defined type functions doing real work
- Native codegen benchmarks and guidance
- Patterns for migrating a nonstrict codebase to strict

## Source Summary

- **luau.org** — 11 pages fetched (home, getting-started, syntax, compatibility, performance, sandbox, lint, types root + 9 subpages, library, grammar)
- **github.com/luau-lang/luau** — README fetched
- **github.com/luau-lang/rfcs** — README + directory index + 24 individual RFC files fetched

Total files created: 39 (this INDEX.md plus 38 content files).
