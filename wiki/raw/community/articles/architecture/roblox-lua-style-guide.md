---
title: Roblox Lua Style Guide — Canonical Formatting and Idioms
type: raw-source
source_url: https://roblox.github.io/lua-style-guide/
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: architecture
author: Roblox
tags: [style-guide, conventions, naming, formatting, idioms]
---

# Roblox Lua Style Guide — Canonical Formatting and Idioms

**Author:** Roblox
**Source:** https://roblox.github.io/lua-style-guide/

## What it is

This is Roblox's official style guide for Lua / Luau code in Roblox projects. It is the de-facto reference for what "idiomatic Roblox Luau" looks like — StyLua's defaults are based on it, Selene's lints are calibrated against it, and most Roblox OSS projects either follow it verbatim or diverge only in narrow ways.

## Core principles

The guide's stated philosophy:

- **Consistency over individual preference.** Every stylistic choice in the guide exists because a team once had a debate about it and picked one answer; the guide preserves that answer so future teams don't re-debate.
- **Optimize for reading, not writing.** Code is read far more than it is written, especially on teams.
- **Avoid "magical" code** that's hard to debug.
- **Follow idiomatic Lua patterns** where they don't conflict with clarity.

## Formatting rules

### Indentation and line length

- **Tabs for indentation.** Not spaces. (StyLua defaults match this.)
- **Keep lines under 100 columns**, assuming 4-column tabs.
- **Comments wrap at 80 columns** (narrower than code for readability).
- **No trailing whitespace.**

### Punctuation

- **Never use semicolons.** Lua doesn't require them and they add noise.
- **Single empty lines separate logical groups.** No blank lines at block starts.
- **One statement per line.** Put function bodies on new lines, not inlined.
- **Space around operators.** `x + y` not `x+y`.
- **Space after commas** in tables and function calls.
- **Opening braces stay inline** with declarations: `local t = {` not `local t =\n{`.

### Example of correct formatting

```lua
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local InventoryService = require(ServerScriptService.Services.InventoryService)
local ItemDefinitions = require(ServerScriptService.Shared.ItemDefinitions)

local MAX_INVENTORY_SIZE = 30

local function giveItem(player, itemId, quantity)
    assert(typeof(player) == "Instance", "player must be Instance")
    assert(typeof(itemId) == "string", "itemId must be string")

    local def = ItemDefinitions[itemId]
    if not def then
        return false, "Unknown item"
    end

    return InventoryService:Add(player, itemId, quantity or 1)
end

return giveItem
```

## File structure

Every module file should follow this order:

1. Optional block comment explaining the file's purpose
2. **Services** (via `game:GetService`)
3. **Module imports** (`require` calls), **alphabetically sorted**
4. **Module-level constants**
5. **Module-level variables and functions**
6. **The returned object**
7. **`return` statement**

The ordering isn't arbitrary — it mirrors what a reader needs to understand top-down. Services tell you "what Roblox systems does this file touch?" Requires tell you "what other modules?" Constants tell you "what magic numbers drive behavior?" By the time you reach the function bodies, you have the context to read them.

## Functions and classes

### Function declaration

- Use `local function name()` for named functions.
- Always declare local unless conditionally defining (e.g. in a branch).
- Avoid assigning anonymous functions to named locals: `local foo = function() end` is worse than `local function foo() end` — the latter lets recursion work naturally and gives better debug info.

### Classes via metatables

The guide recommends prototype-based classes with `__index` pointing to the class table:

```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(property: number): ClassType
    local self = {property = property}
    setmetatable(self, MyClass)
    return self
end

function MyClass:doThing()
    print(self.property)
end
```

Define methods using `.` notation with explicit `self` typing where type checking matters. Use `:` for instance methods from the outside (`obj:doThing()`).

### Static vs. instance

Differentiate with `.` for static methods (the class constructor) and `:` for instance methods (member functions). This gives readers an immediate cue: `MyClass.new()` is a constructor; `obj:method()` is an instance call.

## Naming conventions

- **`PascalCase`** — classes, enum-like objects, Roblox APIs
- **`camelCase`** — local variables, member values, functions
- **`LOUD_SNAKE_CASE`** — local constants
- **`_camelCase`** — private members (prefix underscore)

> "Spell out words fully! Abbreviations generally make code easier to write, but harder to read."

The one exception: well-known acronyms (RGB, URL, UI, HTTP, JSON) stay uppercase. But `idx` should be `index`, `pos` should be `position`, `msg` should be `message`.

## Error handling

The guide's recommendation is perhaps its most specific: **return `success, result` tuples instead of throwing**.

```lua
-- Preferred
local function loadData(key)
    local ok, data = pcall(DataStore.GetAsync, DataStore, key)
    if not ok then
        return false, "DataStore failure: " .. tostring(data)
    end
    return true, data
end

local ok, data = loadData("player_1")
if not ok then
    warn(data)
    return
end
-- use data
```

Throw errors only to validate correct API usage (precondition assertions). Wrap any third-party function that throws in `pcall`.

The rationale: Lua's error-raising mechanism unwinds the stack in a way that's hard to recover from cleanly in game code, where you almost always want to continue running even if one subsystem fails. Returning tuples gives every caller a chance to decide what to do about the failure without forcing a pcall wrapper at every call site.

## Tables and iteration

- **Don't mix list-like and dictionary-like keys** in the same table. Either `{1, 2, 3}` or `{name = "x", count = 1}`, never `{1, 2, name = "x"}`.
- **Use `ipairs` for lists**, `pairs` for dictionaries. (On Luau specifically, the builtin `ipairs`/`pairs` are fast; no need to avoid them for perf reasons.)
- **Trailing commas** in multi-line tables — they make diffs cleaner when you add rows later.

```lua
local items = {
    "Sword",
    "Shield",
    "Potion",  -- trailing comma
}
```

## Comments and documentation

- Comments should explain **why**, not what. The code itself says what.
- Block comments use `--[[ ... ]]` for multi-line, `--` for single line.
- Function docs use the `--[[ ]]` form right above the declaration with a brief description and the argument/return shape.

## Imports

- **All `require` calls at the top of the file**, below the `GetService` block.
- **Alphabetically sorted** — makes merges cleaner and reduces "where is this imported?" searches.
- **Don't conditionally require** inside functions except for truly optional modules (e.g., developer tools).

## Why the guide matters

Following a single canonical style across a codebase isn't about the style being objectively correct — it's about removing the question entirely so reviewers can focus on logic. A PR that spends three comments on bracket placement isn't reviewing the code; it's re-debating the style guide.

Running StyLua + Selene in CI enforces most of this automatically, so the guide's rules become lint errors rather than review nits. The combination of this style guide + StyLua + Selene is what lets a Roblox project feel like a normal software project instead of a free-for-all.

## Source

Original URL: https://roblox.github.io/lua-style-guide/
Captured: 2026-04-15
