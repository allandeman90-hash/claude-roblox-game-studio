---
title: "RFC: New Non-Strict Mode"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/new-nonstrict.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, nonstrict, type-checking]
---

# RFC: New Non-Strict Mode

## Core Motivation

Unify type inference between strict and non-strict modes. Currently, they use separate inference engines, creating confusion and unexpected behaviors when switching module modes. Non-strict mode produces overly coarse types (all local variables as `any`), making it unsuitable for type-driven tooling.

## Key Design Principles

The redesigned non-strict mode focuses on minimizing false positives by reporting only high-confidence code defects:

- **Runtime errors**: Invalid operations like `"hi" + 5` or `math.abs("hi")`
- **Guaranteed nil values**: Accessing properties that definitely don't exist
- **Unread writes**: Properties written but never accessed
- **Implicit coercions**: Type mismatches requiring conversions

## Technical Approach

Both modes share the local type inference engine. Non-strict mode uses an error-reporting pass generating constraint contexts showing when runtime errors occur.

Example: a function using `math.abs(x)` and `string.lower(x)` generates `x : ~number | ~string` (equivalent to `unknown`), triggering a warning since any call guarantees failure.

The system generates contexts through:
- Sequential blocks via disjunction (either path could fail)
- Conditional branches via conjunction (both paths must fail)
- Expressions and function calls with negated type constraints

## Proposed Ergonomic Enhancement

A `@checked` annotation could simplify function type presentation:

```
@checked (number) -> number
```

This automatically expands to include error-producing overloads for non-matching inputs.

## Breaking Change

Non-strict mode becomes stricter, issuing more errors than previously.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/new-nonstrict.md
- Captured: 2026-04-16
