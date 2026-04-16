---
title: Fusion — Reactive UI Library for Roblox / Luau
type: raw-source
source_url: https://github.com/dphfox/Fusion
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: library
author: Daniel Fox (dphfox / Elttob)
tags: [fusion, ui, reactive, state, declarative, luau]
---

# Fusion — Reactive UI Library for Roblox / Luau

**Author:** Daniel Fox (dphfox / Elttob)
**Source:** GitHub — `dphfox/Fusion`
**Docs:** https://elttob.uk/Fusion/
**License:** MIT

## What it is

Fusion is a modern reactive UI library, built specifically for Roblox and Luau. It lets you build UI with declarative syntax and plug in live data through simple, flexible, truly reactive state management. It is the leading community alternative to Roblox's own Roact library, and is used in many shipped games for its cleaner API and more predictable update model.

> **Version caveat:** "Fusion is pre-1.0 software. Users should anticipate that upgrades will be frictionful, requiring code to be rethought" and that "breaking changes are common and sweeping." Pin your version and read release notes before upgrading.

## The core model

Fusion has three core primitives:

1. **Scopes** — cleanup lifetimes (conceptually like Trove)
2. **State objects** — reactive values (`Value`, `Computed`, `Observer`)
3. **Creation/hydration** — `New()` / `Hydrate()` that bind state objects to Instance properties

A typical Fusion script reads top-down: create a scope, define some state, create instances that bind to that state, and when the scope is cleaned, everything goes away.

## Scopes

Every reactive object is created inside a scope. When the scope is destroyed, all objects tied to it are cleaned up. This solves the same problem Trove solves — deterministic cleanup of observers, connections, and instances — but does it implicitly through the scope object rather than explicit `trove:Add` calls.

```lua
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local scope = Fusion:scoped()

-- ... create state and UI using scope ...

-- Later:
scope:doCleanup()
```

## Values

Values are Fusion's simplest state object. They hold a single value you can read and write reactively.

```lua
local health = scope:Value(100)

print(peek(health)) --> 100

health:set(25)
print(peek(health)) --> 25
```

Key notes:
- Create via `scope:Value(initial)` — the scope owns the lifetime.
- Read with the global `peek(stateObject)` function. `peek` works across any state object, not just Values.
- Write with `:set(newValue)`. `:set` returns the new value so you can chain: `newHP = health:set(old - damage)`.

## Computeds

A Computed derives a value from one or more other state objects. It re-evaluates automatically whenever any of its dependencies change:

```lua
local health = scope:Value(100)
local maxHealth = scope:Value(100)
local healthRatio = scope:Computed(function(use)
    return use(health) / use(maxHealth)
end)
```

Inside the Computed callback, you wrap reads with `use(stateObj)` instead of `peek(stateObj)`. This is how Fusion tracks dependencies — `use` tells Fusion "this computed depends on this state object." Fusion then subscribes the computed to changes on every `use`d dependency automatically.

## Observers

Observers run side effects when a state object changes:

```lua
local obs = scope:Observer(health):onChange(function()
    print("Health changed to", peek(health))
end)
```

Use observers for things like playing sounds, firing network events, or logging — anything that isn't a pure derived value.

## `New()` — declarative instance construction

The `New` function creates a new Instance, applies default properties, and hydrates it with a property table. This is Fusion's equivalent of React's JSX:

```lua
local instance = scope:New("Part")({
    Parent = workspace,
    Color = Color3.new(1, 0, 0),
})
```

With Luau's table-call sugar, the parentheses are optional when you use quoted class names and table literals:

```lua
local instance = scope:New "Part" {
    Parent = workspace,
    Color = Color3.new(1, 0, 0),
}
```

Fusion improves on Roblox's default property values — UI elements get `BorderSizePixel = 0`, `AutoButtonColor = false` on buttons, etc. — eliminating most of the boilerplate cleanup developers usually do.

## Binding state to properties

Any Fusion state object can be passed as a property value. Fusion subscribes and updates the instance whenever the state changes:

```lua
local message = scope:Value("Hello there!")

local ui = scope:New "TextLabel" {
    Name = "Greeting",
    Parent = PlayerGui.ScreenGui,
    Text = message,  -- Text updates automatically when message:set() is called
}
```

This is the reactive payoff: you describe the relationship once, and Fusion keeps the UI in sync without manual `instance.Text = ...` calls anywhere.

## `Children` — composition

The special `[Children]` key in a property table is a list of child instances. Fusion handles parenting, so you never set `.Parent` on children — you declare the tree:

```lua
local ui = scope:New "ScreenGui" {
    Parent = PlayerGui,
    [Children] = {
        scope:New "Frame" {
            Size = UDim2.fromScale(1, 1),
            [Children] = {
                scope:New "TextLabel" { Text = "Hello" },
            },
        },
    },
}
```

Children can also be lists of state objects or functions returning instances, enabling dynamic UI.

## `Hydrate()` — binding to existing instances

When you want to attach reactive behavior to an instance that already exists (e.g. created in Studio), use `Hydrate` instead of `New`:

```lua
scope:Hydrate(PlayerGui:WaitForChild("ExistingFrame")) {
    BackgroundColor3 = someStateObject,
}
```

Same semantics as `New` for binding state, but doesn't create the instance.

## Tables: `ForValues`, `ForKeys`, `ForPairs`

Mapping over a reactive list is a first-class concept. `ForValues` is the common case — given a state object containing a list, produce a new list by mapping each element:

```lua
local items = scope:Value({"Sword", "Shield", "Potion"})

local itemViews = scope:ForValues(items, function(use, scope, item)
    return scope:New "TextLabel" { Text = item }
end)
```

When `items:set` adds, removes, or changes entries, Fusion updates the mapped list incrementally — only the changed entries re-run the mapper.

## Animation: Tweens and Springs

Fusion has built-in animated state primitives:

```lua
local target = scope:Value(UDim2.fromScale(0.5, 0.5))
local position = scope:Spring(target, 25, 0.8)  -- speed, damping

-- Or tweening:
local tweened = scope:Tween(target, TweenInfo.new(0.3))
```

Bind these directly to properties and UI animates without any manual TweenService calls.

## Why Fusion vs. Roact

Roact is a React port — it uses a virtual DOM diff on each render, which matches React's semantics but feels heavy for Roblox. Fusion uses reactive state object subscriptions instead — updates propagate only along the dependency graph of the changed value, so there's no diff and no "re-render" concept. For most Roblox UIs this is both faster and easier to reason about.

The main trade-off: Fusion is pre-1.0 and has had breaking changes across versions (0.1 → 0.2 → 0.3 were substantial). Roact is frozen but stable.

## Source

Original URL: https://github.com/dphfox/Fusion
Docs: https://elttob.uk/Fusion/
Tutorials: https://elttob.uk/Fusion/0.3/tutorials/
Captured: 2026-04-15
