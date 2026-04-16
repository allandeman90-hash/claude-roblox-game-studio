---
title: Luau Union and Intersection Types
type: raw-source
source_url: https://luau.org/types/unions-and-intersections
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, unions, intersections, tagged-unions]
---

# Union and Intersection Types

## Union Types

A union type represents "one of the types in this set." If a union is passed to something expecting a more specific type, it will fail. For example, passing `string | number` to a function expecting `number` could fail if the actual value is a string.

**Important constraint:** It's impossible to call a function if there are two or more function types in a union.

### Tagged Unions

Tagged unions are union types of tables with some common properties but differing structures. They use a discriminator property for type refinement:

```lua
type Result<T, E> =
    { type: "ok", value: T }
    | { type: "err", error: E }
```

You can discriminate these using type refinements on the `type` property. When `type` is `"ok"`, the `value: T` property exists; when `type` is `"err"`, the `error: E` property exists.

```lua
local result: Result<number, string> = ...
if result.type == "ok" then
    -- result :: { type: "ok", value: number }
    print(result.value)
else
    -- result :: { type: "err", error: string }
    error(result.error)
end
```

## Intersection Types

An intersection type represents "all of the types in this set." It serves two purposes:

1. Joining multiple tables
2. Specifying overloadable functions

### Key Limitations

- "It's impossible to create an intersection type of some primitive types, e.g. `string & number`, or `string & boolean`"
- "Luau still does not support user-defined overloaded functions," though some Roblox and Lua 5.1 functions require this feature internally

## Source

- Original URL: https://luau.org/types/unions-and-intersections
- Captured: 2026-04-16
