---
title: "RFC: Deprecate table.getn, table.foreach, table.foreachi"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/deprecate-table-getn-foreach.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, deprecation, table]
---

# RFC: Deprecate table.getn / table.foreach / table.foreachi

**Status:** Implemented

## Overview

Marks three functions as deprecated in Luau: `table.getn`, `table.foreach`, and `table.foreachi`.

## Rationale

These functions were deprecated in Lua 5.1 and removed entirely in Lua 5.2. The RFC argues they provide no meaningful advantage over alternatives:

- `table.getn(x)` — replaced by the length operator (`#x`) or `rawlen(x)`, which are more idiomatic and performant
- `table.foreach` / `table.foreachi` — duplicate `for` loops with `pairs()` / `ipairs()`, which are significantly faster and allow function yielding

> "Both functions are significantly slower than equivalent `for` loop replacements, are more restrictive because the function can't yield."

## Implementation

Rather than removing these functions entirely, the change triggers **linter warnings** when they're used, maintaining backward compatibility.

## Justification

The deprecation encourages cleaner, more performant Luau code without breaking existing implementations, especially for developers from JavaScript backgrounds who might gravitate to these functions.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/deprecate-table-getn-foreach.md
- Captured: 2026-04-16
