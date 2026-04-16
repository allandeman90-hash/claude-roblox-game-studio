---
title: "RFC: @native Attribute"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-attribute-functions-native.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, native-codegen, attributes]
---

# RFC: @native Attribute

## Overview

Introduces a function-level `@native` attribute enabling individual functions to request native compilation in Luau, independent of script-level directives.

## Syntax and Usage

The attribute is syntactically simple with no parameters. It applies to both top-level and nested functions.

> "[It] does not apply recursively to the functions defined within the lexical scope of the attributed function."

**Non-recursive example:**
```lua
@native
function parent()
    function child()
        -- child is NOT natively compiled
    end
end
```

**Explicit nested attribution:**
```lua
@native
function parent()
    @native
    function child()
        -- both are natively compiled
    end
end
```

## Motivation

The native compiler currently enforces memory limits on generated code. This constraint "might force creators to break their code organization and move unrelated functions together to scripts marked `--!native`." The per-function attribute provides granular control without restructuring code.

## Related Directive

`--!native` at the file header enables native codegen for the entire script (see language directives).

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/syntax-attribute-functions-native.md
- Captured: 2026-04-16
