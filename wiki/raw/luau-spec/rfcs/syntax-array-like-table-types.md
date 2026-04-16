---
title: "RFC: Array-like Table Types"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-array-like-table-types.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, tables, syntax]
---

# RFC: Array-like Table Types

**Status:** Implemented

## Syntax

Introduces `{T}` as syntactic sugar for array-like table types, "exactly equivalent to `{ [number]: T }`."

## Motivation

Luau users frequently work with array-like tables (integer keys), since standard library functions like `table.insert`, `table.find`, and `ipairs` operate on them. The existing `{ [number]: ValueType }` syntax is verbose.

## Examples

- **Verbose**: `{ [number]: ValueType }`
- **New shorthand**: `{T}`

## Ambiguity Handling

While `{ number, string }` represents a two-element table, the proposal handles single-element cases by reserving `{ number, }` (with trailing comma) for one-element tables versus `{ number }` for number arrays.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-array-like-table-types.md
- Captured: 2026-04-16
