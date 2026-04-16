---
title: Luau Type Functions
type: raw-source
source_url: https://luau.org/types/type-functions
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, type-functions, metaprogramming]
---

# Luau Type Functions

## Overview

Type functions are compile-time operations that work on types rather than runtime values. They are "functions that run during analysis time and operate on types, instead of runtime values."

## Core Capability

Type functions can leverage the types library to transform existing types or generate new ones.

The documentation provides `keyof` as a simplified example — a built-in type function that accepts a table type and returns its property names as a union of singleton types.

## Syntax

```lua
type function f(...)
    -- implementation of the type function
end
```

## Example: `rawget`-style Type Function

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

## Available Environment

Type functions have access to a restricted runtime environment including:

- **Essential functions:** `assert`, `error`, `print`, `next`, `ipairs`, `pairs`, `select`, `unpack`
- **Meta-operations:** `getmetatable`, `setmetatable`, `rawget`, `rawset`, `rawlen`, `raweq`
- **Conversion utilities:** `tonumber`, `tostring`, `type`, `typeof`
- **Standard libraries:** `math`, `table`, `string`, `bit32`, `utf8`, `buffer`

Refer to RFC `user-defined-type-functions` for the complete `types` library API.

## Source

- Original URL: https://luau.org/types/type-functions
- Captured: 2026-04-16
