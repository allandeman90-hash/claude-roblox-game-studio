---
title: table Library
type: luau-feature
category: luau
subcategory: stdlib
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/table-library.md
  - wiki/raw/roblox-creator-docs/luau/tables.md
  - wiki/raw/luau-spec/library/standard-library.md
  - wiki/raw/luau-spec/rfcs/function-table-clone.md
  - wiki/raw/luau-spec/rfcs/function-table-freeze.md
related:
  - "[[string-library]]"
  - "[[math-library]]"
  - "[[buffer-type]]"
  - "[[metatables]]"
tags: [luau, stdlib, table]
---

# `table` Library

> Standard library for array and table manipulation. Luau extends Lua 5.1's `table` library with `create`, `clear`, `clone`, `freeze`, `isfrozen`, `find`, and `move`.

## Syntax

All functions are accessed via the global `table` variable. Most functions operate on the array portion of a table (integer keys from 1 to `#t`).

### Array operations

```lua
table.insert(t, value)              -- append to end
table.insert(t, pos, value)         -- insert at position, shifting subsequent elements
table.remove(t, pos?) -> any        -- remove at position (default: last), shifting elements back
table.sort(t, comp?)                -- in-place sort; comp(a, b) returns true if a < b
table.concat(t, sep?, i?, j?) -> string  -- join elements [i..j] with separator
table.unpack(t, i?, j?) -> ...      -- return elements [i..j] as multiple values
table.pack(...) -> table            -- pack arguments into table with field `n`
table.move(src, a, b, t, dst?) -> table  -- copy src[a..b] to dst starting at index t
```

### Luau extensions

```lua
table.create(count, value?) -> table   -- preallocate array of count elements
table.find(t, value, init?) -> int?    -- linear search; returns index or nil
table.clear(t)                         -- set all keys to nil, preserve capacity
table.clone(t) -> table               -- shallow copy with metatable; always unfrozen
table.freeze(t) -> table              -- make table read-only (shallow)
table.isfrozen(t) -> boolean          -- check if table is frozen
```

### Deprecated (do not use)

```lua
table.foreach(t, fn)   -- use `for k, v in t do` instead
table.foreachi(t, fn)   -- use `for i, v in ipairs(t) do` instead
table.getn(t)           -- use `#t` instead
```

## Semantics

### `table.create(count, value?)`

Allocates a table with the array portion sized for `count` elements, optionally filled with `value`. Use this to avoid repeated resizing when the final size is known.

```lua
local t = table.create(1000)
for i = 1, 1000 do
    t[i] = compute(i)
end
```

### `table.find(t, value, init?)`

Linear search for `value` in the array portion starting from index `init` (default 1). Returns the index of the first match or `nil`.

```lua
local t = {"a", "b", "c", "d"}
table.find(t, "c")     --> 3
table.find(t, "z")     --> nil
table.find(t, "b", 3)  --> nil  (b is before index 3)
```

### `table.clear(t)`

Sets all keys to `nil` but preserves the internal allocated capacity. Use for table reuse in hot loops to avoid garbage collection.

```lua
local pool = table.create(100)
-- ... fill pool ...
table.clear(pool)
-- #pool is 0, but no reallocation needed when refilling
```

### `table.clone(t)`

Returns a **shallow** copy: all key-value pairs are copied, and the metatable is transferred. The clone is **never frozen**, even if the original was. Fails on tables with protected metatables.

For deep clones:
```lua
local function deepClone(original)
    local clone = table.clone(original)
    for key, value in original do
        if type(value) == "table" then
            clone[key] = deepClone(value)
        end
    end
    return clone
end
```

### `table.freeze(t)`

Makes the table read-only. Attempting to modify a frozen table throws `"attempt to modify a readonly table"`. Freezing is:
- **Shallow**: nested tables remain mutable unless also frozen
- **Permanent**: there is no unfreeze/thaw function
- Blocked if the metatable is locked

For deep freezes:
```lua
local function deepFreeze(t)
    table.freeze(t)
    for _, v in t do
        if type(v) == "table" and not table.isfrozen(v) then
            deepFreeze(v)
        end
    end
end
```

### `table.move(src, a, b, t, dst?)`

Copies elements `src[a]` through `src[b]` into `dst` (default: `src`) starting at index `t`. Overlapping regions are handled correctly. Returns `dst`.

```lua
local source = {4, 5}
local dest = {1, 2, 3}
table.move(source, 1, #source, #dest + 1, dest)
-- dest = {1, 2, 3, 4, 5}
```

### `table.sort(t, comp?)`

Sorts the array portion in-place. The comparator `comp(a, b)` must return `true` when `a` should come before `b`. The error `"invalid order function for sorting"` is thrown if both `comp(a, b)` and `comp(b, a)` return `true`.

### `table.pack(...)` / `table.unpack(t, i?, j?)`

`pack` wraps variadic arguments into a table with a `n` field indicating the count (handles nil holes). `unpack` is the inverse. `unpack` is also available as the global `unpack()`.

## Examples

### Preallocated array for performance

```lua
local CHUNK_SIZE = 256

local function generateChunk(): {number}
    local chunk = table.create(CHUNK_SIZE)
    for i = 1, CHUNK_SIZE do
        chunk[i] = math.noise(i * 0.1, 0, 0)
    end
    return chunk
end
```

### Efficient string building with table.concat

```lua
-- BAD: O(n^2) due to string immutability
local s = ""
for i = 1, 1000 do
    s = s .. tostring(i) .. ","
end

-- GOOD: O(n) with table.concat
local parts = table.create(1000)
for i = 1, 1000 do
    parts[i] = tostring(i)
end
local s = table.concat(parts, ",")
```

### Frozen configuration tables

```lua
local Config = table.freeze({
    MaxPlayers = 12,
    RoundTime = 300,
    Maps = table.freeze({"Arena", "Forest", "Volcano"}),
})

Config.MaxPlayers = 20  -- ERROR: attempt to modify a readonly table
```

## Pitfalls

- **`table.insert` at position is O(n).** Inserting at the beginning of a large array shifts every element. Append to the end when possible.
- **`table.remove` in forward iteration breaks indices.** Iterate in reverse when removing elements during iteration.
- **`table.sort` comparator must be a strict weak ordering.** If `comp(a, b)` and `comp(b, a)` both return true, a runtime error is thrown.
- **`table.clone` is shallow.** Nested tables are shared between the original and clone. Mutating a nested table affects both.
- **`table.freeze` is shallow.** Nested tables remain mutable. Use a recursive freeze for full immutability.
- **`table.clear` does not reset the metatable.** The metatable persists; only key-value pairs are removed.
- **`table.maxn` counts non-contiguous numeric keys.** It returns the highest numeric key even if there are gaps; `#t` returns the length of the contiguous array portion.

## Related

- [[string-library]]
- [[math-library]]
- [[buffer-type]]
- [[metatables]]

## Sources

- [Roblox Creator Docs: table Library](../raw/roblox-creator-docs/luau/table-library.md)
- [Roblox Creator Docs: Tables](../raw/roblox-creator-docs/luau/tables.md)
- [Luau Standard Library Reference](../raw/luau-spec/library/standard-library.md)
- [RFC: table.clone](../raw/luau-spec/rfcs/function-table-clone.md)
- [RFC: table.freeze and table.isfrozen](../raw/luau-spec/rfcs/function-table-freeze.md)
