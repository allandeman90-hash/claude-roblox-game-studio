---
title: Luau Syntax Reference
type: raw-source
source_url: https://luau.org/syntax
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: language
tags: [luau, syntax]
---

# Luau Syntax Reference

Luau builds on the baseline syntax of Lua 5.1 while adding modern extensions. The language implements a single number type: a 64-bit IEEE754 double-precision float.

## String Literals

Luau supports hexadecimal, Unicode, and whitespace-skipping escape sequences:

```lua
local hex = "\xAB"           -- Character with code 0xAB
local unicode = "\u{ABC}"    -- UTF8 sequence for U+0ABC
local multiline = "line1\z
line2"                       -- \z ignores following whitespace
```

## Number Literals

Enhanced numeric formats include:

```lua
local hex = 0xABC            -- Hexadecimal
local binary = 0b01010101    -- Binary
local readable = 1_048_576   -- Decimal separators for clarity
local hex_sep = 0xFFFF_FFFF
local bin_sep = 0b_0101_0101
```

## Continue Statement

Loop control extension allowing skipped iterations:

```lua
for i = 1, 10 do
  if i == 5 then continue end
  print(i)
end
```

**Restriction**: Cannot skip local variable declarations used in loop conditions.

## Compound Assignments

Operators `+=`, `-=`, `*=`, `/=`, `//=`, `%=`, `^=`, `..=` available:

```lua
x += 5
y *= 2
z //= 3
```

Function calls on left-hand side evaluate only once.

## Type Annotations

Optional static typing for gradual adoption:

```lua
local x: number = 5
local function add(a: number, b: number): number
  return a + b
end

-- Type cast with ::
local y = x :: any
```

### Basic Types

Built-in types: `any`, `nil`, `boolean`, `number`, `string`, `thread`, `vector`, `buffer`

### Function Types

```lua
type Callback = (number, string) -> boolean
type NoReturn = () -> ()
type MultiReturn = () -> (number, string)
```

### Table Types

```lua
type Point = { x: number, y: number }
type StringArray = { string }       -- Array shorthand
type Dict = { [string]: number }    -- Indexer style
```

### Type Unions and Intersections

```lua
type Numeric = number | string
type Optional = number?             -- Shorthand for number | nil
type Overloaded = ((number) -> string) & ((boolean) -> string)
```

### Type Aliases

```lua
type UserId = number
export type Public = { id: number }
```

Exported types usable across modules via `require`.

## If-Then-Else Expressions

Conditional expressions (not statements) returning values:

```lua
local result = if x > 0 then "positive" else "non-positive"

local category = if x < 0 then "negative"
                 elseif x == 0 then "zero"
                 else "positive"
```

**Note**: Preferred over Lua's `a and b or c` idiom due to correct handling of falsy values.

## Generalized Iteration

Tables iterate directly without explicit iterators:

```lua
local t = {1, 2, 3}
for value in t do
  print(value)
end
```

Custom iteration via `__iter` metamethod:

```lua
local t = setmetatable({}, {
  __iter = function(self)
    return next, self
  end
})
```

Default order: consecutive elements `1..#t`, then unordered.

## String Interpolation

Backtick literals embed expressions:

```lua
local name = "Luau"
local result = `Hello, {name}!`

local x, y = 5, 10
local point = `Position: x={x}, y={y}`

-- Any expression works
local calc = `Result: {2 + 2}`
```

### Escaping

```lua
local escaped = `Escaped: \`, \\, \{`  -- Escapes for `, \, {
```

**Restrictions**:
- Double opening braces `{{` rejected with parse error
- Not supported in type annotations
- Requires parentheses in function calls: `print(`text`)`

## Floor Division

Integer division operator with three forms:

```lua
local result = 7 // 2          -- Equals 3 (math.floor(7 / 2))
x //= 2                         -- Compound assignment
```

Handles edge cases: produces `inf`, `-inf`, or `NaN` appropriately.

## Additional Notes

- Luau supports "string literal extensions" from later Lua versions but not other 5.x additions.
- See also the grammar reference at `/grammar` and the type system guide at `/types/`.

## Source

- Original URL: https://luau.org/syntax
- Captured: 2026-04-16
