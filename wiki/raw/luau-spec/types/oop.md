---
title: Luau Object-Oriented Programming Types
type: raw-source
source_url: https://luau.org/types/object-oriented-programs
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: types
tags: [luau, types, oop, self]
---

# Luau OOP Type Support

## Overview

Adding types for faux object-oriented programs in Luau.

## The Core Problem

Luau struggles with type inference in object-oriented patterns because "the type of `self` is not shared across methods of `Account`" due to Lua's flexibility in passing different values as `self` through explicit method calls.

## The Solution Pattern

The documentation recommends a two-step annotation approach:

1. Define the data type for your class
2. Use `setmetatable` (via `typeof` or the New Type Solver's `setmetatable` type function) to establish the class type
3. Explicitly annotate each method's `self` parameter with the class type

## Future Development

Luau plans to "restrict the types of all functions defined with `:` syntax to share their self types," which would eventually enable this pattern without explicit annotations. See the RFC `shared-self-types`.

## Source

- Original URL: https://luau.org/types/object-oriented-programs
- Captured: 2026-04-16
