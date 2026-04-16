---
title: Luau Generics and Polymorphism
type: raw-source
source_url: https://luau.org/types/generics
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, generics, polymorphism]
---

# Generics and Polymorphism in Luau

## Overview

> "A generic is simply a type parameter in which another type could be slotted in."

This feature enables the type inference engine to preserve actual type information, offering advantages over using `any`.

## Generic Functions

Luau supports generic functions that accept type parameters alongside regular data parameters. A practical example is a function reversing arrays while maintaining element type consistency.

### Explicit Type Declaration

Developers can explicitly declare type parameters using syntax like `<T>` to specify generic constraints:

```lua
function id<T>(x: T): T
    return x
end
```

When invoking generic functions, Luau automatically infers appropriate type arguments from context.

### Built-in Examples

The standard library demonstrates generics extensively. For instance, the two-argument `table.insert` function has the type signature `<T>({T}, T) -> ()`, illustrating how generics work with core functionality.

### Limitations

- Functions don't support having defaults assigned to generics — developers cannot provide fallback type values for unspecified parameters.
- No turbofish syntax for explicit type argument instantiation (see RFC `generic-function-subtyping` and `explicit-type-parameter-instantiation`).

## Key Takeaway

Generics enable type-safe, reusable functions without sacrificing type information — a significant advantage over treating values as `any` type.

## Source

- Original URL: https://luau.org/types/generics
- Captured: 2026-04-16
