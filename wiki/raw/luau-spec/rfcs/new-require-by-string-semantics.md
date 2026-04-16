---
title: "RFC: Require by String Semantics"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/new-require-by-string-semantics.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, require, modules]
---

# RFC: New Require-by-String Semantics

## Core Semantics

New require-by-string system where relative paths are resolved **relative to the requiring file's location**, not the current working directory. This enables Luau libraries to function consistently regardless of CLI launch context.

## Path Resolution Process

**File Extension Priority:**
1. `.luau` extension
2. `.lua` extension
3. All other extensions are invalid

**Directory Resolution:**
If a path resolves to a directory, the system searches for initialization files in this sequence:
1. `init.luau`
2. `init.lua`

Multiple matching files now trigger an **error** rather than following a priority list (per subsequent RFC).

## Relative Path Requirements

Relative paths must begin explicitly with `./` or `../`:
- `./` denotes the requiring file's directory
- `../` indicates the parent directory

**Example patterns:**

From `C:/MyLibrary/SubDirectory/SubModule.luau`:
```lua
require("../MyModule")
```

From `C:/MyOtherLibrary/MainModule.luau`:
```lua
require("../MyLibrary/MyModule")
```

## Special Cases

- **REPL contexts**: Relative paths in REPL prompts evaluate relative to a pseudo-file `stdin` located in the current working directory
- **Code without file context**: Using `loadstring` or similar mechanisms without file association causes relative-path requires to error

## Platform Consistency

The implementation automatically maps forward slashes (`/`) to backslashes (`\`), ensuring consistent cross-platform behavior.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/new-require-by-string-semantics.md
- Captured: 2026-04-16
