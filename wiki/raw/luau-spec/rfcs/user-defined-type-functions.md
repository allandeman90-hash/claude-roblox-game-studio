---
title: "RFC: User-Defined Type Functions"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/user-defined-type-functions.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, type-functions, metaprogramming]
---

# RFC: User-Defined Type Functions

## Summary

Luau's type inference engine introduces a system for user-defined type functions, enabling developers to create custom type-level computations. This extends an existing built-in type function system to "include built-in type functions that correspond to built-in runtime-level operations in the language."

## Motivation

- "Enable more precise type definitions that can capture complex relations on types"
- "Facilitate the creation of type-safe, reusable and composable libraries"
- "Enhance Luau's support for type-level programming"

Current limitations prevent programmers from constructing relational types — for example, producing a table where every property becomes optional in a predictable manner.

## Syntax

```lua
type function f(...)
    -- implementation of the type function
end
```

## Example: `rawget` Type Function

```lua
type function rawget(tbl, key)
    if not tbl:is("table") then
        error("first parameter must be a table type!")
    end

    for k, v in tbl:properties() do
        if k == key then
            if v.read ~= v.write then
                error("mismatched read/write types found for the property")
            end

            return v.read
        end
    end

    error("key not found!")
end

type Person = {
    name: string,
    age: number
}

type ty = rawget<Person, "name"> -- resolves to `string`
```

## Type Runtime Architecture

During type analysis, when encountering user-defined type functions like `rawget<...>`, Luau "will serialize the type parameters of that call into a form that Luau can manipulate, and then execute the body of the type function in a Luau VM."

A central concept is the `type` userdata: "An instance of the `type` userdata is a type runtime representation of a type within the program, and it provides a set of API calls that can be used to inspect and manipulate the type."

## Library Naming

Rather than using `type` (which conflicts with the built-in `type()` function), "the name of the library for constructing `type`s will be `types`."

## Scoping

"The scoping and shadowing rules of user-defined type functions will be made to match the existing rules for type aliases...they are order-independent, and can refer to one another."

## Sandboxed Environment

Type functions execute in a restricted VM with access to:

- Error handling: `assert`, `error`, `print`
- Iteration: `next`, `ipairs`, `pairs`, `select`, `unpack`
- Built-in operations: `getmetatable`, `setmetatable`, `rawget`, `rawset`, `rawlen`, `rawequal`, `tonumber`, `tostring`, `type`, `typeof`
- Libraries: `math`, `table`, `string`, `bit32`, `utf8`, `buffer`

## The Halting Problem

The RFC acknowledges that "type inference for Luau's type system is already, in general, undecidable." Rather than attempting to prevent infinite loops, the design accepts that "type functions, like the rest of Luau's type system, are already not guaranteed to terminate in general." The mitigation relies on existing analysis limits and cancellation systems.

## Types API Reference

### `types` Library Properties

| Property | Type | Description |
|---|---|---|
| `unknown` | `type` | Built-in `unknown` type (immutable) |
| `never` | `type` | Built-in `never` type (immutable) |
| `any` | `type` | Built-in `any` type (immutable) |
| `boolean` | `type` | Built-in `boolean` type (immutable) |
| `number` | `type` | Built-in `number` type (immutable) |
| `string` | `type` | Built-in `string` type (immutable) |

### `types` Library Functions

| Function | Return Type | Description |
|---|---|---|
| `singleton(arg: string \| boolean \| nil)` | `type` | Returns immutable singleton type instance |
| `negationof(arg: type)` | `type` | Returns immutable negated type (cannot be table/function) |
| `unionof(...: type)` | `type` | Returns immutable union type (requires >=2 parameters) |
| `intersectionof(...: type)` | `type` | Returns immutable intersection type (requires >=2 parameters) |
| `newtable(props?, indexer?, metatable?)` | `type` | Returns mutable table type |
| `newfunction(parameters, returns)` | `type` | Returns mutable function type |
| `copy(arg: type)` | `type` | Returns deep copy of type |

### `type` Instance Properties

| Property | Type | Description |
|---|---|---|
| `tag` | string | Immutable tag: "nil", "unknown", "never", "any", "boolean", "number", "string", "singleton", "negation", "union", "intersection", "table", "function", or "class" |

### `type` Instance Methods (All Types)

| Method | Return Type | Description |
|---|---|---|
| `__eq(arg: type)` | `boolean` | Syntactic equality (semantically equivalent types don't compare equal) |
| `is(arg: string)` | `boolean` | Returns true if tag matches argument |

### Negation Type Methods

```lua
inner() -- returns the type being negated
```

### Singleton Type Methods

```lua
value() -- returns string, boolean, or nil
```

### Table Type Methods

```lua
setproperty(key: type, value: type?)
setreadproperty(key: type, value: type?)
setwriteproperty(key: type, value: type?)
readproperty(key: type)   -- returns type? for reading
writeproperty(key: type)  -- returns type? for writing
properties()              -- returns {[type]: { read: type?, write: type? }}

setindexer(index: type, result: type)
setreadindexer(index: type, result: type)
setwriteindexer(index: type, result: type)
indexer()                 -- returns { index: type, readresult: type, writeresult: type }?
readindexer()             -- returns { index: type, result: type }?
writeindexer()            -- returns { index: type, result: type }?

setmetatable(arg: type)
metatable()               -- returns type?
```

### Function Type Methods

```lua
setparameters(head: {type}?, tail: type?)
parameters()              -- returns { head: {type}?, tail: type? }

setreturns(head: {type}?, tail: type?)
returns()                 -- returns { head: {type}?, tail: type? }
```

### Union Type Methods

```lua
components() -- returns {type} array
```

### Intersection Type Methods

```lua
components() -- returns {type} array
```

### Class Type Methods

```lua
properties()       -- returns {[type]: { read: type, write: type }}
readparent()       -- returns type?
writeparent()      -- returns type?
metatable()        -- returns type?
indexer()          -- returns { index: type, readresult: type, writeresult: type }?
readindexer()      -- returns { index: type, result: type }?
writeindexer()     -- returns { index: type, result: type }?
```

## Drawbacks

The primary concern involves "making analysis explicitly depend on the Luau runtime in order to evaluate type functions." However, the RFC argues this is mitigated because "we still retain a separation between the type runtime and its evaluation of type functions versus the overall runtime." This design ensures "the runtime semantics of code in type function bodies is always consistent with the runtime semantics of ordinary Luau code."

## Alternatives Considered

- **Table runtime representation** — rejected because it "makes it more difficult to apply basic well-formedness restrictions to the interface of type functions" and "makes the creation of new types at runtime messier and more prone to errors."
- **Compile-time interpreter** — has "higher complexity and carries a greater maintenance burden" and conflicts with the goal of making type function development feel like ordinary Luau programming.
- **More built-in type functions** — "type manipulation would still be limited to the predefined set of type functions designed by the Luau team" and "continuously expanding the set of built-in type functions leads to bloat and complexity."

## Future Work

- **Kind checking** — type-checking type functions themselves
- **Expanded library access** — additional libraries for more expressive type functions, including support for "generic types or named parameters for function types"
- **Type alias availability** — making type aliases "available as part of the type function environment"

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/user-defined-type-functions.md
- Captured: 2026-04-16
