---
title: "RFC: Function Attributes"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-attributes-functions.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, syntax, attributes, native, deprecated]
---

# RFC: Function Attributes

## Overview

Adds a `@name` syntax for function attributes to control compiler, analyzer, and runtime behavior in Luau.

## Proposed Attributes

1. **`@native`** — Directs the compiler to use native codegen for a function
2. **`@inline`** — Suggests the compiler should inline a function at call sites
3. **`@deprecated`** — Marks a function as deprecated for analyzer warnings

## Syntax

```
attribute = '@' NAME
```

### Valid Placements

Named functions:
```lua
@native
function foo()
end
```

Anonymous functions:
```lua
foo = @native function() end
```

Method declarations:
```lua
@deprecated
function foo:bar()
end
```

Multiple attributes on one declaration:
```lua
@native @inline @deprecated
local function example()
end
```

## Key Design Decisions

- **Compiler-defined only** — User-defined attributes are excluded as "incompatible with Luau's goals"
- **No parameters** — Parameterized attributes deferred to future work
- **Functions-first approach** — Initially limited to functions, with potential future expansion to loops and variables

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-attributes-functions.md
- Captured: 2026-04-16
