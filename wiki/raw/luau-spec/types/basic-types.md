---
title: Luau Primitives and Simple Types
type: raw-source
source_url: https://luau.org/types/basic-types
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, primitives, any, unknown, never]
---

# Luau Primitives and Simple Types

## Primitive Types

Luau supports 10 primitive types that can be used in type annotations:

1. `nil`
2. `string`
3. `number`
4. `boolean`
5. `table`
6. `function`
7. `thread`
8. `userdata`
9. `vector`
10. `buffer`

Most can be specified directly by name in type annotations. However, `table` and `function` use dedicated syntax (table shapes, function type syntax) rather than being written by name.

## Special Builtin Types

The type checker provides three additional special types:

### `unknown`

The _top_ type — a union of all types. Unlike `any`, variables typed as `unknown` cannot be used as different types without applying type refinements first.

### `never`

The _bottom_ type — no value inhabits it. It represents impossible scenarios proven by type refinements.

### `any`

Similar to `unknown` but "allows itself to be used as an arbitrary type without further checks," effectively opting out of the type system.

## Function Types

In strict mode, inferred function types use generic notation. For example, a function parameter that's returned has type `<A>(A) -> A`, showing the parameter and return share the same type.

## Variadic Types and Type Packs

Variadic parameters use the `...` symbol with type annotation:

```lua
function f(...: number)
```

This indicates the function accepts any number of `number` values. In type annotations, variadic syntax is written as `...T`.

Type packs represent multiple return values and variadic parameters as lists of types. Generic type pack parameters use the notation `U...` for variable-length packs containing any number of types.

## Singleton Types

Luau supports singleton (literal) types for strings and booleans, enabling representation of specific values. These are particularly useful with type refinements and tagged unions to "enforce program invariants in the type system."

```lua
type Status = "ok" | "error"
type Flag = true
```

## Source

- Original URL: https://luau.org/types/basic-types
- Captured: 2026-04-16
