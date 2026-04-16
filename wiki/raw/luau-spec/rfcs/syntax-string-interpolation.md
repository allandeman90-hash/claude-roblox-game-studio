---
title: "RFC: String Interpolation"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-string-interpolation.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, syntax, strings, interpolation]
---

# RFC: String Interpolation

## Summary

Introduce new string interpolation syntax using backticks and braces to replace the limitations of `string.format()`.

## Motivation

The RFC identifies six core problems with `string.format`:

1. **Type precision issues**: `%d` truncates numbers to `long long`; `%f` defaults to six decimal places; `%g` converts large numbers to scientific notation.
2. **Limited type support**: Requires exact type matching, losing precision with `%d` or forcing `%s` for strings despite type checker assumptions.
3. **Boolean handling**: Booleans require `%s` plus explicit `tostring()` calls.
4. **Metamethod limitations**: Values with `__tostring` metamethods aren't automatically converted.
5. **Percent escaping**: `"Your health is %d% so you need to heal up."` causes runtime errors.
6. **Syntax awkwardness**: Method calls on string literals require parentheses.

## Design

Backtick-delimited literals with `{}` brace expressions:

```lua
local world = "world"
print(`Hello {world}!`)
--> Hello world!
```

**Key features:**
- Expressions within `{}` braces are interpolated
- Backslash escapes backticks, braces, and itself
- Pairs must be on the same line unless escaped
- `{{` is explicitly rejected to prevent C#/Rust-style confusion
- Newlines are permitted between expression braces

**Extended `string.format` support:**

The new `%*` token applies `tostring()` automatically: `string.format("%* %*", 1, 2)` produces `"1 2"`.

**Grammar:**
```
stringinterp ::= <INTERP_BEGIN> exp {<INTERP_MID> exp} <INTERP_END>
```

## Examples

```lua
local combo = {5, 2, 8, 9}
print(`The lock combinations are: {table.concat(combo, ", ")}`)
--> The lock combinations are: 5, 2, 8, 9

print(`Some example escaping the braces \{like so}`)
--> Some example escaping the braces {like so}

print(`Some text that also includes \`...`)
--> Some text that also includes `...

local name = "Luau"
print(`Welcome to {
    name
}!`)
--> Welcome to Luau!
```

## Drawbacks

1. Future syntax conflicts — backticks may limit future language features
2. Percent character handling requires auto-escape
3. Interpolated strings cannot appear in type annotations

## Alternatives Considered

| Language | Syntax | Status |
|---|---|---|
| Python | `f'Hello {name}'` | Rejected — ambiguous with function calls |
| Swift | `"Hello \(name)"` | Rejected — changes existing string meaning |
| Ruby | `"Hello #{name}"` | Rejected — changes existing string meaning |
| JavaScript | `` `Hello ${name}` `` | Viable if backticks remain unused |
| C# | `$"Hello {name}"` | Viable |

Backticks were selected to avoid stacking complexity in the lexer while maintaining backward compatibility.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-string-interpolation.md
- Captured: 2026-04-16
