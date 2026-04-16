---
title: Module Scripts
type: luau-feature
category: luau
subcategory: language
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/module-scripts.md
related:
  - "[[export-type]]"
  - "[[metatables]]"
tags: [luau, modules, require, code-reuse]
---

# Module Scripts

**Status:** stub

## Summary

`ModuleScript` is Roblox's code-reuse primitive. A ModuleScript returns a single value (typically a table of functions) via a `return` statement. Other scripts load it with `require(moduleInstance)`, which executes the module body once and caches the result. Subsequent `require` calls return the cached reference.

```lua
-- ReplicatedStorage/MyModule.lua
local M = {}
function M.greet(name: string)
    print(`Hello {name}`)
end
return M

-- Any other script
local MyModule = require(game.ReplicatedStorage.MyModule)
MyModule.greet("Player1")
```

Key properties:
- **Caching**: module body runs once per environment (server and client have separate caches)
- **Shared state**: all scripts requiring the same module share the returned reference
- **Circular dependencies**: cause recursion errors; extract shared code to a third module
- **Client scripts**: use `WaitForChild` for replication safety

## TODO

- Module organization patterns (service modules, config modules, type-only modules)
- `require` semantics in detail (caching, error propagation, execution order)
- Circular dependency detection and resolution strategies
- Server vs client module environments
- Hot-reloading behavior in Studio
- `require` by string path (new Luau feature)

## Related

- [[export-type]]
- [[metatables]]

## Sources

- [Roblox Creator Docs: Module Scripts](../raw/roblox-creator-docs/luau/module-scripts.md)
