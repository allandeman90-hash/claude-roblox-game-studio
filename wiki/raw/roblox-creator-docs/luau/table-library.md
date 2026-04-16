---
title: table Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/table
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, table, library, insert, remove, sort, concat, freeze, clone]
---

# table Library

This library provides generic functions for table/array manipulation, providing all its functions inside the global `table` variable. Most functions in the `table` library assume that the table represents an array or a list. For these functions, the "length" of a table means the result of the length operator.

## Functions

### table.clear

```
table.clear(table: table): ()
```

Sets the value for all keys within the given table to `nil`. This causes the `#` operator to return `0` for the given table. The allocated capacity of the table's array portion is maintained, which allows for efficient re-use of the space.

```lua
local grades = {95, 82, 71, 92, 100, 60}
print(grades[4], #grades) --> 92, 6
table.clear(grades)
print(grades[4], #grades) --> nil, 0
-- If grades is filled again with the same number of entries,
-- no potentially expensive array resizing will occur
-- because the capacity was maintained by table.clear.
```

This function does not delete/destroy the table provided to it. This function is meant to be used specifically for tables that are to be re-used.

### table.clone

```
table.clone(t: table): table
```

Returns an unfrozen shallow copy of the provided table.

```lua
local original = {
	key = "value",
	engine = "Roblox",
	playerID = 505306092
}

local clone = table.clone(original)
```

### table.concat

```
table.concat(t: Array, sep: string = "", i: int = 1, j: int = #t): string
```

Given an array where all elements are strings or numbers, returns the string `t[i] ... sep ... t[i+1] ... sep ... t[j]`. The default value for `sep` is an empty string, the default for `i` is 1, and the default for `j` is `#t`. If `i` is greater than `j`, returns the empty string.

### table.create

```
table.create(count: number, value: Variant): table
```

Creates a table with the array portion allocated to the given `number` of elements, optionally filled with the given `value`.

```lua
local t = table.create(3, "Roblox")
print(table.concat(t)) --> RobloxRobloxRoblox
```

If you are inserting into large array-like tables and are certain of a reasonable upper limit to the number of elements, it's recommended to use this function to initialize the table. This ensures the table's array portion of its memory is sufficiently sized, as resizing it can be expensive.

### table.find

```
table.find(haystack: table, needle: Variant, init: number): Variant
```

Within the given array-like table `haystack`, find the first occurrence of value `needle`, starting from index `init` or the beginning if not provided. If the value is not found, `nil` is returned.

A linear search algorithm is performed.

```lua
local t = {"a", "b", "c", "d", "e"}
print(table.find(t, "d")) --> 4
print(table.find(t, "z")) --> nil, because z is not in the table
print(table.find(t, "b", 3)) --> nil, because b appears before index 3
```

### table.foreach (Deprecated)

```
table.foreach(t: table, f: function): ()
```

**DEPRECATED.** Iterates over the provided table, passing the key and value of each iteration over to the provided function. Use a `for` loop instead in new code.

### table.foreachi (Deprecated)

```
table.foreachi(t: Array, f: function): ()
```

**DEPRECATED.** Similar to `table.foreach()` except that index-value pairs are passed, not key-value pairs. Use a `for` loop instead in new code.

### table.freeze

```
table.freeze(t: table): table
```

Makes the given table read-only, effectively "freezing" it in its current state. Attempting to modify a frozen table throws an error.

This freezing effect is **shallow**, which means that you can write to a table within a frozen table. To deep freeze a table, call this function recursively on all of the descending tables.

### table.getn (Deprecated)

```
table.getn(t: Array): number
```

**DEPRECATED.** Returns the number of elements in the table passed. Use `#t` instead.

### table.insert

```
table.insert(t: Array, value: Variant): ()
table.insert(t: Array, pos: number, value: Variant): ()
```

Inserts the provided value to the end of the array, or at the target position of the array.

### table.isfrozen

```
table.isfrozen(t: table): bool
```

Returns `true` if the given table is frozen and `false` if it isn't frozen. You can freeze tables using `table.freeze()`.

### table.maxn

```
table.maxn(t: table): number
```

Returns the maximum numeric key of the provided table, or zero if the table has no numeric keys. Gaps in the table are ignored.

### table.move

```
table.move(src: table, a: number, b: number, t: number, dst: table = src): table
```

Copies elements in table `src` from `src[a]` up to `src[b]` into table `dst` starting at index `t`. Equivalent to the assignment statement `dst[t], ..., dst[t + (b - a)] = src[a], ..., src[b]`.

The default for `dst` is `src`. The destination range may overlap with the source range. Returns `dst` for convenience.

```lua
local sourceTable = {4, 5} -- Table of data to copy from
local destTable = {1, 2, 3} -- Table to add copied data to

table.move(
	sourceTable, -- Source table
	1, -- Index to start from in source table
	#sourceTable, -- Index up to (and including) from source table
	#destTable + 1, -- Index within destination table to move data into
	destTable -- Destination table
)
print(destTable) --> {1, 2, 3, 4, 5}
```

### table.pack

```
table.pack(...: Variant): Variant
```

Returns a new table with all arguments stored into keys 1, 2, etc. and with a field `"n"` with the total number of arguments. Note that the resulting table may not be a sequence.

```lua
local t = table.pack(1, 2, 3)
print(table.concat(t, ", ")) --> 1, 2, 3
```

### table.remove

```
table.remove(t: Array, pos: number): Variant
```

Removes from array `t` the element at position `pos`, returning the value of the removed element. When `pos` is an integer between `1` and `#t`, it shifts down the elements `t[pos+1], t[pos+2], ..., t[#t]` and erases element `t[#t]`. If the `pos` parameter is not provided, `pos` defaults to the length of the table removing the last element.

### table.sort

```
table.sort(t: Array, comp: function = nil): ()
```

Sorts elements of array `t` in a given order, from `t[1]` to `t[#t]`. If `comp` is given, then it must be a function that receives two elements and returns `true` when the first element must come before the second in the final order.

The error `invalid order function for sorting` is thrown if both `comp(a, b)` and `comp(b, a)` return `true`.

If `comp` is not given, then the standard Luau operator `<` is used instead.

### table.unpack

```
table.unpack(list: table, i: number = 1, j: number = #list): Tuple
```

Returns the elements from the given list. By default, `i` is 1 and `j` is the length of `list`.

Note that this same functionality is also provided by the global `unpack()` function.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/table
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/table.yaml
Captured: 2026-04-16
