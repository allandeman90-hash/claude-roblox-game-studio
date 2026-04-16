---
title: Type Annotations - A Guide to Writing Luau Code that is Actually Good
type: raw-source
source_url: https://devforum.roblox.com/t/type-annotations-a-guide-to-writing-luau-code-that-is-actually-good%E2%84%A2/2843221
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: Maximum_ADHD
post_date: 2024-02-18
tags: [types, type-checking, luau, strict-mode, annotations, tutorial]
---

# Type Annotations! A Guide to Writing Luau Code that is Actually Good

**Author:** Maximum_ADHD
**Posted:** February 18, 2024

## Core Purpose

This tutorial teaches developers how to use Luau's type annotation system to create more maintainable, self-documenting code with better IDE support and fewer runtime errors.

## Key Recommendations

The author emphasizes adding `--!strict` at the script's top to enable proper type inference rather than defaulting to `any`.

## Type Annotation Patterns

**Basic syntax:**
```lua
local value: number = 0
local part: Part = Instance.new("Part")
```

**Nullable types use `?` suffix:**
```lua
local inst = workspace:FindFirstChild("Instance") -- Type: [Instance?]
```

**Type refinement methods include:**
- Inline: `(maybe and maybe + 1)`
- If statements: `if value then ... end`
- Assertions: `assert(value, "message")`

## Built-in Types

Ten core types exist: `nil`, `string`, `number`, `thread`, `boolean`, `vector`, `buffer`, `any`, `never`, and `unknown`.

**Special types:**
- `any`: Accepts any value (disables type checking)
- `unknown`: Requires runtime type checking via `type()`/`typeof()`
- `never`: Cannot be refined into other types

## Functions

```lua
local function addNumbers(a: number, b: number): number
    return a + b
end
```

**Function type annotations:**
```lua
local coolFunc: (BasePart) -> (CFrame, Vector3) = function(part)
    return part.CFrame, part.Size
end
```

**Variadic functions:**
```lua
local function debugPrint(...: unknown)
    if DEBUG then print(...) end
end
```

## Collections

**Arrays:**
```lua
local objects: {Instance} = workspace:GetChildren()
```

**Dictionaries with indexers:**
```lua
local positionMap = {} :: {[Player]: Vector3?}
```

**Type declarations for structures:**
```lua
type SimpleType = {
    Number: number,
    String: string,
}
```

## Metatables & Classes

```lua
export type Class = typeof(setmetatable({} :: {
    FirstName: string,
    LastName: string,
}, Person))

function Person.new(firstName: string, lastName: string): Class
    return setmetatable({FirstName = firstName, LastName = lastName}, Person)
end
```

## Typecasting with `::`

The `::` operator overrides inferred types when necessary:

```lua
local data = {
    Kills = {} :: {[Player]: number},
    Deaths = {} :: {[Player]: number},
}
```

**Rules:**
- All types convert to/from `any`, `unknown`, `never`
- Empty tables cast to indexer types
- Concrete types cast upward to base classes only

## Best Practices

- Use explicit type annotations for function parameters and returns
- Leverage type refinement to handle nullable values safely
- Define reusable type aliases for complex structures
- Avoid casting to `any` except when absolutely necessary, as it bypasses type contracts

## Source

Original URL: https://devforum.roblox.com/t/type-annotations-a-guide-to-writing-luau-code-that-is-actually-good%E2%84%A2/2843221
Captured: 2026-04-16
