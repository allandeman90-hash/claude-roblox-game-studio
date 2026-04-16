---
title: "RFC: index Type Operator"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/index-type-operator.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, index, type-functions]
---

# RFC: index Type Operator

## Syntax

The `index` type function accepts two arguments:
- **Indexee**: The type being accessed
- **Indexer**: The property key(s) to access

```lua
index<Person, "age">
index<Person, keyof<Person>>
index<Person, "age" | "name">
```

## Examples

**Basic property access:**
```lua
type Person = {
    age: number,
    name: string,
    alive: boolean
}

local function doSmt(param: index<Person, "age">)  -- param = number
end
```

**Union of all properties:**
```lua
type idxType = index<Person, keyof<Person>>        -- number | string | boolean
```

**Multiple specific properties:**
```lua
type idxType2 = index<Person, "age" | "name">      -- number | string
```

## Semantics

**Distribution over unions:** When the indexee is a union type, the function distributes across each member:
```lua
type Person2 = { age: string }
type idxType3 = index<Person | Person2, "age">     -- number | string
```

**Metamethod handling:** If a property isn't found directly, `__index` metamethods are consulted (up to 100 levels deep).

**Error conditions:**
- Nonexistent properties → `"Property 'ager' does not exist on type 'Person'"`
- Non-type indexers → `"Second argument to index<Person,_> is not a valid index type"`

## Future Syntactic Sugar

Potential shorthand notations (not yet implemented):
- `Person["age"]`
- `Person.age`

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/index-type-operator.md
- Captured: 2026-04-16
