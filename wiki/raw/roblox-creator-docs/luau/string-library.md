---
title: string Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/string
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, string, library, format, gsub, match, split, find, pack]
---

# string Library

The string library provides generic functions to manipulate strings, such as to extract substrings or match patterns. You can access the string library by the global `string` library.

See [String pattern reference](./strings.md) for details on using `string.match()`, `string.gmatch()`, and `string.gsub()` to find (and replace) substrings.

## Functions

### string.byte

```
string.byte(s: string, i: number = 1, j: number = i): int
```

Returns the internal numerical codes of the characters `s[i], s[i+1], ..., s[j]`. The default value for `i` is 1; the default value for `j` is `i`. These indices are corrected following the same rules of function `string.sub()`.

### string.char

```
string.char(...: int): string
```

Receives zero or more integers and returns a string with length equal to the number of arguments, in which each character has the internal numerical code equal to its corresponding argument.

### string.find

```
string.find(s: string, pattern: string, init: number = 1, plain: bool = false): (number, number)
```

Searches for the first occurrence of a pattern in a string and returns the start and end indices of the match. If no match is found, it returns `nil`. You can specify where to start the search using the optional `init` parameter which defaults to 1 and can be negative. An optional `plain` parameter turns off pattern matching, so the function performs a plain substring search; note that if you use `plain`, you must also provide `init`.

```lua
-- Example 1: Basic usage
local s = "Hello, world!"
local pattern = "world"
local start_index, end_index = string.find(s, pattern)
print(start_index, end_index)  -- Output: 8 12
```

```lua
-- Example 2: Using init parameter
local s = "Hello, world! Hello, Roblox!"
local pattern = "Hello"
local start_index, end_index = string.find(s, pattern, 10)
print(start_index, end_index)  -- Output: 15 19
```

```lua
-- Example 3: Using plain parameter
local s = "Hello, world! (Hello)"
local pattern = "(Hello)"
local start_index, end_index = string.find(s, pattern, 1, true)
print(start_index, end_index)  -- Output: 14 20
```

```lua
-- Example 4: No Pattern found
local s = "Hello, world!"
local pattern = "Roblox"
local start_index, end_index = string.find(s, pattern)
print(start_index, end_index)  -- Output: nil
```

### string.format

```
string.format(formatstring: string, ...: string): string
```

Returns a formatted version of its variable number of arguments following the description given in its first argument, which must be a string.

Format: `%[flags][width].[precision][specifier]`

#### Specifiers

| Specifier | Accepts | Outputs | Example Output |
|---|---|---|---|
| `c` | integer | | 3 |
| `d` or `i` | integer | Decimal representation. | 321 |
| `e` or `E` | float | Scientific notation using `e` or `E`. | 3.296e2 / 3.296E2 |
| `f` | float | | 3231.1231 |
| `g` or `G` | float | The shorter of `e`/`E` and `f`. | 3E14 / 3e14 |
| `o` | integer | Octal representation. | 610 |
| `q` | string | String in a form suitable to be safely read back by the Luau interpreter. | `"print(\"Hi\")"` |
| `s` | string | | Hello world! |
| `u` | integer | Decimal representation. | 3131 |
| `x` or `X` | integer | Hexadecimal representation. | 7fa / 7FA |
| `*` | any | Equivalent to `s` but accepts any variable by converting it to a string using `tostring()`. | table: 0x0123456789abcdef |
| `%` | | `%` followed by another `%` will return the `%` sign itself. | % |

```lua
local str = "The magic word is %s"
print(string.format(str, "Roblox"))
-- The magic word is Roblox

local str = "The magic word is %q"
print(string.format(str, "Roblox"))
-- The magic word is "Roblox"
```

#### Flags

| Flag | Description |
|---|---|
| `-` | Left-justify the given field width. |
| `+` | Forces a "+" sign to precede a number. |
| (space) | One blank space is inserted before a positive number. |
| `#` | When used with `o` and `x`/`X`, writes a 0 (octal) or 0x/0X (hex) before values other than zero. |
| `0` | Left-pads the number with zeros instead of empty spaces. |

```lua
local str = "%-10d"
print(string.format(str, 300) .. "]")
-- 300       ]

local str = "%+i versus %+i"
print(string.format(str, 300, -300)) -- +300 versus -300
```

#### Width

Minimum number of characters to return. If the number of characters to be formatted is less than this number, the result is padded with blank spaces.

```lua
local str = "%012i"
print("Score: " .. string.format(str, 15000))
-- Output: Score: 000000015000
```

#### Precision

The default precision is 1. If you give a period without a value, the default is 0.

```lua
-- Add decimal with precision of 2 for a currency output
local str = "$%.2f"
print(string.format(str, 300)) -- Output: $300.00

-- Return first 6 letters of a string
local str = "%.6s"
print(string.format(str, "Robloxian")) -- Output: Roblox
```

### string.gmatch

```
string.gmatch(s: string, pattern: string): function
```

Returns an iterator function that returns the next captures from pattern over the string `s` each time it's called.

### string.gsub

```
string.gsub(s: string, pattern: string, replacement: Variant, replacements: number): (string, number)
```

Short for global substitution. Returns a copy of `s` in which all (or the first `n`, if given) occurrences of the pattern are substituted (replaced) with the given `replacement`. The second value returned is the total number of substitutions made.

The `replacement` can be one of several types:
- **string**: The pattern is replaced with the string directly
- **table**: The string that matched the pattern is looked up in the table as a key, and the value (string) is what replaces it, if it exists.
- **function**: Called with the string that matched the pattern, should return the string to replace the matched pattern.

```lua
-- Basic replacement
string.gsub("I love tacos!", "tacos", "Roblox") --> I love Roblox! 1
-- Replacement with a pattern
string.gsub("I like red!", "%w+", "word") --> word word word! 3
-- Replacement table
string.gsub("I play Roblox.", "%w+", {I="Je", play="joue à"}) --> Je joue à Roblox. 3
-- Replacement function
string.gsub("I have 2 cats.", "%d+", function(n) return tonumber(n) * 12 end) --> I have 24 cats. 1
-- Replace only twice
string.gsub("aaa", "a", "b", 2) --> bba 2
-- Replacement with capture groups (maximum of nine)
string.gsub("love2play Roblox", "(%w+)(%d+)(%w+)%s+(%w+)", "I %1 %2 %3 %4!") --> I love 2 play Roblox! 1
```

### string.len

```
string.len(s: string): int
```

Returns the length of a string.

### string.lower

```
string.lower(s: string): string
```

Returns a copy of a string with all uppercase letters changed to lowercase.

### string.match

```
string.match(s: string, pattern: string, init: number = 1): string
```

Looks for the first match of pattern in the string `s`. If a match is found, it is returned; otherwise, it returns `nil`. A third, optional numerical argument, `init`, specifies where to start the search; its default value is 1 and can be negative.

### string.pack

```
string.pack(format: string, ...: Variant): string
```

Returns a binary string containing the provided arguments. The first argument, `format`, determines the way the remaining arguments are packed; see [Lua 5.3 manual](https://www.lua.org/manual/5.3/manual.html#6.4.2) for options.

### string.packsize

```
string.packsize(format: string): number
```

Returns the size in bytes of any string packed with a given description. The sole argument, `format`, determines the way the remaining arguments are packed, but you cannot use `s` and `z` because they have variable lengths.

### string.rep

```
string.rep(s: string, n: int): string
```

Returns a string that is the concatenation of `n` copies of the string `s`.

### string.reverse

```
string.reverse(s: string): string
```

Returns a string that is the string `s` reversed.

### string.split

```
string.split(s: string, separator: string = ","): table
```

Splits a string into parts based on the defined separator character(s), returning a table of ordered results.

If an empty "slice" is located, that part will be returned as an empty string. For instance `string.split("abc||def", "|")` will return a table with three strings: `"abc"`, `""`, and `"def"`.

```lua
local values = input:split(",")
print(values[1], values[2], values[3])
```

Whitespace from the original string will be preserved. By default, the separator character is `,` but you can specify an alternative character or series of characters.

**Corner Cases:**

```lua
-- Empty String
"" --> ""

-- Empty Slices
"foo,,bar" --> "foo", "", "bar"
",foo" --> "", "foo"
"foo," --> "foo", ""
"," --> "", ""
",," --> "", "", ""

-- Whitespace Preserved
"   whitespace   " --> "   whitespace   "
"foo , bar" --> "foo ", " bar"

-- Unicode
"，" --> U+FF0C FULLWIDTH COMMA
"我很高兴，你呢？" --> "我很高兴", "你呢？"
"•" --> U+2022 BULLET
"hello•world" --> "hello", "world"
```

### string.sub

```
string.sub(s: string, i: int = 1, j: int = -1): string
```

Returns the substring of `s` that starts at `i` and continues until and including `j`. `i` and `j` can be negative.

### string.unpack

```
string.unpack(format: string, data: string, readStart: string = 1): Tuple
```

Extracts the values packed in the provided binary string based on the first argument, `format`, which should match the one originally used to pack the string. The optional third parameter determines the byte at which the reading starts. Returns the values plus the index of the first unread byte.

### string.upper

```
string.upper(s: string): string
```

Returns a copy of a string with all lowercase letters changed to uppercase.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/string
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/string.yaml
Captured: 2026-04-16
