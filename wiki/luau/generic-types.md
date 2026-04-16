---
title: Generic Types
type: luau-feature
category: luau
subcategory: type-system
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/types/generics.md
  - wiki/raw/roblox-creator-docs/luau/type-checking.md
  - wiki/raw/luau-spec/rfcs/generic-functions.md
related:
  - "[[type-annotations]]"
  - "[[export-type]]"
  - "[[strict-vs-nonstrict]]"
tags: [luau, type-system, generics, polymorphism]
---

# Generic Types

> Type parameters that let a single type alias or function work with any concrete type, preserving type safety without resorting to `any`.

## Syntax

### Generic type aliases

```lua
type List<T> = {T}
type Map<K, V> = {[K]: V}
type Container<T> = { value: T, metadata: string }

type State<T> = {
    Key: string,
    Value: T,
}
```

The `<T>` (or `<K, V>`, etc.) declares one or more type parameters. These are substituted when the alias is instantiated:

```lua
local names: List<string> = {"Alice", "Bob"}
local scores: Map<string, number> = { Alice = 100, Bob = 85 }
local box: Container<boolean> = { value = true, metadata = "flag" }
```

### Generic functions

Add `<T>` after the function name:

```lua
function id<T>(x: T): T
    return x
end

local function firstOf<T>(list: {T}): T?
    return list[1]
end

local function State<T>(key: string, value: T): State<T>
    return { Key = key, Value = value }
end
```

Luau infers the type argument from the call site:

```lua
local s = id("hello")       -- s: string
local n = id(42)             -- n: number
local activated = State("Activated", false)  -- State<boolean>
```

### Generic function types

```lua
local id: <a>(a) -> a = function(x) return x end
```

### Type packs (variadic generics)

For functions returning multiple values or accepting variadic typed arguments:

```lua
function compose<a...>(...: a...): (a...)
    return ...
end
```

Type packs use `T...` syntax and capture an ordered sequence of types.

### Exported generics

```lua
export type Result<T, E> =
    { type: "ok", value: T }
    | { type: "err", error: E }
```

## Semantics

- Generics are **erased at runtime**. They exist only during type analysis and produce no bytecode.
- Type arguments are **inferred** from usage. Luau resolves the concrete type from function arguments or assignment context.
- Multiple type parameters are comma-separated: `<K, V>`, `<T, U, R>`.
- Generics support **Rank-N polymorphism**: a function can return a generic function whose type parameters bind at the call site of the returned function, not at the outer function.

  ```lua
  -- f returns a generic function; T binds when the returned function is called
  local f: () -> <T>(T) -> T
  ```

- Generic type aliases and generic functions are distinct. A generic alias is instantiated where it is referenced; a generic function's type parameters are instantiated at each call.

### Built-in generics

The standard library uses generics extensively:

- `table.insert` has type `<T>({T}, T) -> ()`
- `table.find` has type `<T>({T}, T, number?) -> number?`
- `table.freeze` has type `<T>(T) -> T`

### Deviation from Lua 5.1

Lua 5.1 has no type system. Generics are entirely a Luau addition.

## Examples

### Type-safe data container

```lua
--!strict
type Queue<T> = {
    items: {T},
    push: (Queue<T>, T) -> (),
    pop: (Queue<T>) -> T?,
}

local function createQueue<T>(): Queue<T>
    local q: Queue<T> = {
        items = {},
        push = function(self, item)
            table.insert(self.items, item)
        end,
        pop = function(self)
            return table.remove(self.items, 1)
        end,
    }
    return q
end

local strQueue = createQueue() :: Queue<string>
strQueue:push("hello")
local val = strQueue:pop() -- val: string?
```

### Tagged union with generics

```lua
--!strict
type Result<T, E> =
    { type: "ok", value: T }
    | { type: "err", error: E }

local function tryParse(input: string): Result<number, string>
    local n = tonumber(input)
    if n then
        return { type = "ok", value = n }
    else
        return { type = "err", error = `Failed to parse "{input}"` }
    end
end

local result = tryParse("42")
if result.type == "ok" then
    print(result.value) -- number
end
```

### Generic map function

```lua
local function map<T, U>(list: {T}, fn: (T) -> U): {U}
    local result = table.create(#list)
    for i, v in list do
        result[i] = fn(v)
    end
    return result
end

local doubled = map({1, 2, 3}, function(n) return n * 2 end)
-- doubled: {number}
```

## Pitfalls

- **No turbofish syntax.** You cannot explicitly pass type arguments: `id<number>(42)` is a parse error because `<` is ambiguous with the comparison operator. Rely on inference or type-annotate the receiving variable.
- **No default type parameters.** Unlike TypeScript, you cannot write `type Foo<T = string>`.
- **No bounded generics.** You cannot constrain a type parameter (e.g., `<T: {name: string}>`). Any constraint must be enforced at the call site.
- **Generic functions vs. generic aliases.** Confusing where `<T>` binds leads to subtle type errors. `type Fn<T> = (T) -> T` is a generic alias (T fixed at alias use). `<T>(T) -> T` is a generic function type (T fixed at each call).
- **Inference limitations.** Complex nested generics sometimes fail to infer; adding explicit type annotations to intermediate variables resolves this.

## Related

- [[type-annotations]]
- [[export-type]]
- [[strict-vs-nonstrict]]

## Sources

- [Luau Generics and Polymorphism](../raw/luau-spec/types/generics.md)
- [Roblox Creator Docs: Type Checking](../raw/roblox-creator-docs/luau/type-checking.md)
- [RFC: Generic Functions](../raw/luau-spec/rfcs/generic-functions.md)
