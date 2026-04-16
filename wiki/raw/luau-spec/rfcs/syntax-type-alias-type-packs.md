---
title: "RFC: Type Alias Type Packs"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-type-alias-type-packs.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, type-packs, generics]
---

# RFC: Type Alias Type Packs

## Overview

Enables referencing type packs within type alias declarations, allowing generic type pack parameters to be used in alias bodies and instantiations.

## Core Problem

Previously, type pack placeholders couldn't be referenced in type alias bodies:
```lua
type X<A...> = () -> A...            -- previously invalid
type Y = X<number, string>            -- previously incorrect argument count
```

## Basic Type Pack Syntax

Type packs can now be instantiated with zero or more types:
```lua
type X<T...> = --
type A = X<>                          -- T... = ()
type B = X<number>                    -- T... = (number)
type C = X<number, string>            -- T... = (number, string)
```

## Variadic Type Assignment

```lua
type D = X<...number>                 -- T... = (...number)
```

## Multiple Type Pack Parameters

When declaring multiple type pack parameters, unmatched types combine into the first pack. Subsequent parameters must be type packs:
```lua
type Y<T..., U...> = --
type E<S...> = Y<...string, S...>     -- T... = (...string), U... = S...
```

## Explicit Type Pack Syntax

Parenthesized syntax provides explicit type pack control:
```lua
type Y<T..., U...> = (T...) -> (U...)
type F1 = Y<(number, string), (boolean)>
```

## Limitations

- Type packs cannot be extracted or returned as results
- Type aliases cannot generate type packs themselves
- Immediate instantiation prevents pack content inspection during definition

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-type-alias-type-packs.md
- Captured: 2026-04-16
