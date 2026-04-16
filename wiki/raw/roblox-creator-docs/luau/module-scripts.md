---
title: Module Scripts and require
type: raw-source
source_url: https://create.roblox.com/docs/scripting/module
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, modules, require, ModuleScript, code-reuse, caching]
---

# Module Scripts and require

Module scripts enable code reuse across different script locations in Roblox. When stored in `ReplicatedStorage`, a single module can be required from both server and client scripts.

> **Note:** This file was captured as a structured summary. For definitive details, see the source URL on create.roblox.com.

## Basic Structure

A `ModuleScript` returns a single value — typically a table, function, or table of functions:

```lua
local module = {}

function module.doSomething()
	print("Hello from the module")
end

return module
```

Every `ModuleScript` must end with a `return` statement that returns exactly one value.

## Loading Modules with require

Use the `require()` function to load a module script:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PickupManager = require(ReplicatedStorage:WaitForChild("PickupManager"))
```

### Module caching

**Calling `require()` on a `ModuleScript` runs once and returns a single item as a reference.** Subsequent `require()` calls on the same module return the cached value — the module body executes only once per environment.

This means tables and functions returned by a module are shared across all scripts that require it. Be careful with mutable state.

## Common Patterns

### Data Sharing

Store configuration values in module scripts for easy reuse across multiple objects rather than assigning individual attributes.

```lua
-- ConfigModule (in ReplicatedStorage)
local Config = {
	MaxPlayers = 12,
	RoundTime = 300,
	DefaultMap = "Arena",
}
return Config
```

```lua
-- Server or client script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.ConfigModule)

print(Config.MaxPlayers) --> 12
```

### Custom events

Combine `BindableEvent` objects with module scripts to enable script-to-script communication without cluttering code with event references.

### Encapsulation

Create abstraction layers around Roblox objects — like wrapping a single `RemoteEvent` with custom functions — to simplify complex networking or error handling logic.

## Important Considerations

- **Avoid circular module dependencies.** If module A requires module B and module B requires module A, Luau will raise a recursion error.
- **Use `WaitForChild()` in client scripts** as a safety measure for proper replication ordering. The server may not have finished replicating a ModuleScript when a LocalScript tries to require it.
- **Server and client caches are separate.** The same ModuleScript in `ReplicatedStorage` will execute once per context (once on server, once per client).

## Source

Original URL: https://create.roblox.com/docs/scripting/module
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/module.md
Captured: 2026-04-16
