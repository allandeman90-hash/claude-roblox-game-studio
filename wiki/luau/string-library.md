---
title: string Library
type: luau-feature
category: luau
subcategory: stdlib
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/string-library.md
  - wiki/raw/roblox-creator-docs/luau/strings.md
  - wiki/raw/luau-spec/library/standard-library.md
  - wiki/raw/luau-spec/rfcs/syntax-string-interpolation.md
related:
  - "[[table-library]]"
  - "[[math-library]]"
  - "[[string-interpolation]]"
tags: [luau, stdlib, string, patterns]
---

# `string` Library

> Standard library for string manipulation. Luau extends Lua 5.1 with `string.split` and string interpolation via backtick syntax. Strings are immutable byte sequences; all operations return new strings.

## Syntax

All functions are accessible via the global `string` variable or as methods on string values (e.g., `s:find(...)`).

### Core functions

```lua
string.len(s) -> number                          -- byte length (same as #s)
string.sub(s, i, j?) -> string                   -- substring [i..j]; negative indices count from end
string.rep(s, n) -> string                       -- repeat s n times
string.reverse(s) -> string                      -- reverse byte order
string.upper(s) -> string                        -- ASCII uppercase
string.lower(s) -> string                        -- ASCII lowercase
string.byte(s, i?, j?) -> ...number              -- numeric byte codes of s[i..j]
string.char(...number) -> string                 -- string from byte codes
```

### Pattern matching

```lua
string.find(s, pattern, init?, plain?) -> (number, number, ...string)
string.match(s, pattern, init?) -> ...string?
string.gmatch(s, pattern) -> () -> ...string     -- iterator
string.gsub(s, pattern, repl, n?) -> (string, number)
```

### Formatting

```lua
string.format(fmt, ...) -> string                -- printf-style formatting
```

### Binary packing (Lua 5.3 compatible)

```lua
string.pack(fmt, ...) -> string
string.unpack(fmt, data, pos?) -> (...any, number)
string.packsize(fmt) -> number
```

### Luau extension

```lua
string.split(s, separator?) -> {string}          -- split by separator (default ",")
```

## Semantics

### Pattern language

Luau uses Lua's pattern language (not regex). Key elements:

| Pattern | Matches |
|---|---|
| `.` | Any character |
| `%a` / `%A` | Letter / non-letter |
| `%d` / `%D` | Digit / non-digit |
| `%w` / `%W` | Alphanumeric / non-alphanumeric |
| `%s` / `%S` | Whitespace / non-whitespace |
| `%p` / `%P` | Punctuation / non-punctuation |
| `%l` / `%u` | Lowercase / uppercase |

Quantifiers: `+` (1+), `*` (0+), `-` (0+, lazy), `?` (0 or 1).

Anchors: `^` (start), `$` (end).

Magic characters requiring `%` escape: `$ % ^ * ( ) . [ ] + - ?`

Captures use `()` and are returned as additional values from `match`/`find`/`gmatch`.

### `string.find(s, pattern, init?, plain?)`

Returns start and end indices of the first match, plus any captures. If `plain` is `true`, the pattern is treated as a literal string (no pattern matching). `init` defaults to 1 and supports negative indices.

```lua
local s = "Hello, world!"
local i, j = string.find(s, "world")  --> 8, 12
```

### `string.gsub(s, pattern, repl, n?)`

The replacement `repl` can be:
- **string**: direct substitution; `%1`..`%9` reference captures
- **table**: matched string is looked up as a key; value replaces the match
- **function**: called with the match; return value replaces the match

Returns the result string and the count of substitutions made.

```lua
string.gsub("I love tacos!", "tacos", "Roblox")          --> "I love Roblox!", 1
string.gsub("I play Roblox.", "%w+", {I="Je", play="joue"}) --> "Je joue Roblox.", 3
string.gsub("I have 2 cats.", "%d+", function(n)
    return tonumber(n) * 12
end)                                                       --> "I have 24 cats.", 1
```

### `string.split(s, separator?)`

Splits `s` at each occurrence of `separator` (default `","`). Returns a table of strings. Empty slices produce empty strings.

```lua
string.split("a,b,,c", ",")  --> {"a", "b", "", "c"}
string.split(",", ",")       --> {"", ""}
```

Whitespace is preserved. The separator is a literal string, not a pattern.

### `string.format` specifiers

| Specifier | Accepts | Output |
|---|---|---|
| `%d` / `%i` | integer | Decimal |
| `%f` | float | Fixed-point |
| `%e` / `%E` | float | Scientific notation |
| `%g` / `%G` | float | Shorter of `%e` and `%f` |
| `%s` | string | String |
| `%q` | string | Quoted, escaped for Luau |
| `%x` / `%X` | integer | Hexadecimal |
| `%o` | integer | Octal |
| `%*` | any | Calls `tostring()` automatically (Luau extension) |
| `%%` | -- | Literal `%` |

Flags: `-` (left-align), `+` (force sign), `0` (zero-pad), ` ` (space before positive), `#` (alt form for `%o`/`%x`).

### `string.pack` / `string.unpack`

Binary encoding/decoding following Lua 5.3 format strings. Useful for custom binary protocols and DataStore serialization. See the Lua 5.3 manual for format options. Fixed sizes in Luau: short=16 bits, long=64 bits, int=32 bits, size_t=32 bits.

## Examples

### Pattern matching to parse key-value pairs

```lua
local input = "Health = 100"
local key, val = string.match(input, "(%a+)%s*=%s*(%d+)")
print(key, val) --> Health, 100
```

### Iterating all words

```lua
for word in string.gmatch("The quick brown fox", "%a+") do
    print(word)
end
--> The, quick, brown, fox
```

### Efficient string building

```lua
-- Prefer table.concat over repeated .. in loops
local parts = {}
for i = 1, 100 do
    parts[i] = string.format("item_%03d", i)
end
local result = table.concat(parts, ", ")
```

### String interpolation (backtick syntax)

```lua
local name = "Player1"
local score = 42
print(`{name} scored {score} points!`) --> Player1 scored 42 points!
print(`Result: {score * 2}`)            --> Result: 84
```

Escape backticks and braces with `\`:

```lua
print(`Use \`backticks\` and \{braces\}`) --> Use `backticks` and {braces}
```

## Pitfalls

- **String concatenation in loops is O(n^2).** Strings are immutable; each `..` allocates a new string. Use `table.concat` or string interpolation for building large strings.
- **Patterns are not regex.** No alternation (`|`), no non-greedy quantifiers except `-`, no lookahead/lookbehind. For complex parsing, use multiple `match`/`find` calls.
- **`string.len` counts bytes, not characters.** Multi-byte UTF-8 characters (e.g., emoji) report more bytes than visual characters. Use the `utf8` library for codepoint counting.
- **`string.split` is not pattern-based.** The separator is a literal string. To split by a pattern, use `string.gmatch` instead.
- **`%d` in `string.format` truncates to integer range.** Large numbers lose precision. Use `%f` or `%g` for full numeric precision.
- **Empty captures `()` return positions, not strings.** An empty capture group returns the numeric position in the string, which can be surprising.

## Related

- [[table-library]]
- [[math-library]]
- [[string-interpolation]]

## Sources

- [Roblox Creator Docs: string Library](../raw/roblox-creator-docs/luau/string-library.md)
- [Roblox Creator Docs: Strings](../raw/roblox-creator-docs/luau/strings.md)
- [Luau Standard Library Reference](../raw/luau-spec/library/standard-library.md)
- [RFC: String Interpolation](../raw/luau-spec/rfcs/syntax-string-interpolation.md)
