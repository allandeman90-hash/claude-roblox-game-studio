---
title: Functional Programming in Luau — Immutable Data Libraries
type: raw-source
source_url: https://github.com/Roblox/cryo
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: architecture
tags: [functional-programming, immutable, cryo, sift, freeze, llama, state]
---

# Functional Programming in Luau — Immutable Data Libraries

**Sources:** `Roblox/cryo`, `cxmeel/sift`, `benbrimeyer/Freeze`, `freddylist/llama`, plus community writeups

## Why functional programming in Luau

Luau tables are mutable by default. For most gameplay code this is fine — you create a player state table and mutate it in place as the game runs. But for specific use cases, mutability becomes a liability:

1. **UI state with undo/redo** — mutating shared state directly makes history tracking impossible.
2. **Rodux / Redux-style stores** — the entire reducer pattern assumes that state transitions produce new state objects rather than mutating in place, so that `oldState !== newState` reliably indicates a change.
3. **React / Roact / Fusion rendering** — reactive systems detect changes by reference comparison. Mutating a table in place means the reference is the same and the framework misses the update.
4. **Avoiding aliasing bugs** — pass-by-reference semantics mean `table_a = table_b` shares storage. Functional patterns that return new tables avoid this entire class of bug.

The Roblox community's answer is a small family of "immutable data" libraries that expose operations like `merge`, `set`, `update`, `map`, `filter` — each of which takes a table and returns a *new* table with the requested change, leaving the input untouched.

## The libraries, in order of popularity

### Cryo (Roblox official)

Cryo is "a library that helps you write more terse code that deals with immutable data" and includes traditional FP list primitives like `map`, `filter`, `foldLeft`, as well as tools inspired by JavaScript like joining dictionaries. Roblox released it as the companion to their Roact/Rodux stack and it's the most historically established option.

```lua
local Cryo = require(ReplicatedStorage.Packages.Cryo)

local original = {name = "Alice", score = 10}
local updated = Cryo.Dictionary.join(original, {score = 20})
-- original is unchanged; updated is {name = "Alice", score = 20}

local list = {1, 2, 3, 4, 5}
local doubled = Cryo.List.map(list, function(x) return x * 2 end)
-- {2, 4, 6, 8, 10}

local filtered = Cryo.List.filter(list, function(x) return x > 2 end)
-- {3, 4, 5}
```

Cryo is now "read-only mirror" on GitHub — Roblox internally uses it but the public mirror is not actively developed. Still production-quality and functional.

### Llama (Freddy List)

Llama was the other early immutable library, written specifically to pair with Rodux. "Rodux requires your state to be immutable, so Llama is a great choice for manipulating it." API shape is similar to Cryo: `Dictionary.join`, `List.map`, etc.

### Sift (cxmeel)

Sift is "an immutable data library for Luau and roblox-ts, heavily based on Freddylist's Llama library." It's the modern active-development option — Sift has better strict-Luau type definitions than Cryo or Llama, which makes it the first choice for new TypeScript-flavored Luau projects.

### Freeze (benbrimeyer / duckarmor)

Freeze is another actively-maintained immutable library, "imperative for use with popular libraries such as React and Rodux." Slightly different API philosophy — closer to Immutable.js — with persistent data structures (lists, maps, sets) rather than plain Lua tables.

## The core operations

All four libraries expose roughly the same set of operations on dictionaries and lists. The names differ slightly but the semantics are the same:

### Dictionaries

| Operation | Cryo | Sift | Purpose |
|---|---|---|---|
| Shallow merge | `Cryo.Dictionary.join` | `Sift.Dictionary.merge` | Merge two dicts; right wins |
| Set one key | `Cryo.Dictionary.join(d, {k = v})` | `Sift.Dictionary.set` | Return new dict with one field changed |
| Remove one key | `Cryo.Dictionary.removeKey` | `Sift.Dictionary.removeKey` | Return new dict without a field |
| Deep equality | `Cryo.equals` | `Sift.Dictionary.equals` | Structural comparison |

### Lists

| Operation | Cryo | Sift | Purpose |
|---|---|---|---|
| Map | `Cryo.List.map` | `Sift.Array.map` | Transform each element |
| Filter | `Cryo.List.filter` | `Sift.Array.filter` | Keep elements matching predicate |
| Foldl/reduce | `Cryo.List.foldLeft` | `Sift.Array.reduce` | Aggregate |
| Append | `Cryo.List.join` | `Sift.Array.push` | Add an element to the end |
| Slice | `Cryo.List.getRange` | `Sift.Array.slice` | Take a subrange |

## Example: reducer pattern for player state

```lua
local Sift = require(ReplicatedStorage.Packages.Sift)

-- Initial state
local initial = {
    coins = 100,
    inventory = {"Sword"},
    health = 100,
}

-- Reducer: takes (state, action) and returns new state
local function reducer(state, action)
    if action.type == "ADD_COINS" then
        return Sift.Dictionary.set(state, "coins", state.coins + action.amount)
    elseif action.type == "ADD_ITEM" then
        return Sift.Dictionary.set(state, "inventory",
            Sift.Array.push(state.inventory, action.item))
    elseif action.type == "TAKE_DAMAGE" then
        return Sift.Dictionary.set(state, "health", math.max(0, state.health - action.amount))
    end
    return state
end

-- Usage
local state1 = reducer(initial, {type = "ADD_COINS", amount = 50})
-- state1.coins == 150, initial.coins still == 100

local state2 = reducer(state1, {type = "ADD_ITEM", item = "Shield"})
-- state2.inventory == {"Sword", "Shield"}, state1.inventory still == {"Sword"}

-- Change detection is trivial:
if state2 ~= state1 then
    updateUI(state2)
end
```

The last block is where the pattern pays for itself. Because every state transition produces a new table, reference comparison (`~=`) is a perfect "did anything change?" check. No need to deep-compare every field, no need to diff before and after — if you've received a new reference, something changed.

## When NOT to use immutable libraries

- **Hot loops over large arrays.** Creating a new table per update is GC pressure. If you're mutating a 10,000-entry array 60 times per second, mutable in-place is the right tool.
- **Simple scripts.** If your script doesn't need undo, reactive UI, or structural comparison, mutability is simpler and faster.
- **Memory-constrained code.** Immutable updates allocate; mutable updates don't.

Use immutable data libraries when the benefits (reactive rendering, undo/redo, predictable state transitions) matter, and use mutable tables everywhere else. Most codebases end up using both — immutable for UI/state, mutable for per-frame game logic.

## Sources

- https://github.com/Roblox/cryo
- https://github.com/cxmeel/sift
- https://github.com/benbrimeyer/Freeze
- https://github.com/freddylist/llama
- https://devforum.roblox.com/t/functional-programming-and-why/1383305
Captured: 2026-04-15
