---
title: Fusion
type: library
category: libraries
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/fusion-readme.md
  - wiki/raw/community/devforum/fusion-possiblyoutlives-scopes.md
related: [[[Trove]], [[Knit]], [[GoodSignal]]]
tags: [library, ui, reactive, state-management, declarative]
---

# Fusion

> Reactive UI library for Roblox/Luau with declarative instance construction, scope-based cleanup, computed state objects, and built-in animation primitives.

## Summary

Fusion is a modern reactive UI library by Daniel Fox (dphfox / Elttob), built specifically for Roblox and Luau. It replaces the imperative "create instance, set properties, connect events" workflow with a declarative model: define state objects, bind them to Instance properties, and Fusion keeps the UI in sync automatically. It is the leading community alternative to Roact and is used in many shipped games.

**Maintainer:** dphfox (Elttob)
**Status:** Active, pre-1.0. Breaking changes between versions are common and sweeping. Pin your version.
**License:** MIT

## Installation

### Wally

```toml
[dependencies]
Fusion = "dphfox/fusion@0.3"
```

Pin a specific version -- Fusion's pre-1.0 releases have had substantial breaking changes (0.1, 0.2, 0.3).

## Quick Start

```lua
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local scope = Fusion:scoped()
local peek = Fusion.peek
local Children = Fusion.Children

-- Reactive state
local health = scope:Value(100)
local maxHealth = scope:Value(100)
local healthRatio = scope:Computed(function(use)
    return use(health) / use(maxHealth)
end)

-- Declarative UI bound to state
local ui = scope:New "ScreenGui" {
    Parent = game.Players.LocalPlayer.PlayerGui,
    [Children] = {
        scope:New "Frame" {
            Size = UDim2.fromScale(0.3, 0.05),
            BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
            [Children] = {
                scope:New "Frame" {
                    Size = scope:Computed(function(use)
                        return UDim2.fromScale(use(healthRatio), 1)
                    end),
                    BackgroundColor3 = Color3.new(0, 1, 0),
                },
            },
        },
    },
}

-- Update state; UI updates automatically
health:set(50) -- health bar shrinks to 50%

-- Cleanup everything
scope:doCleanup()
```

## Key API

| Symbol | Description |
|--------|-------------|
| `Fusion:scoped()` | Creates a scope that owns reactive objects. Cleanup via `scope:doCleanup()`. |
| `scope:Value(initial)` | Creates a readable/writable state object. Read with `peek()`, write with `:set()`. |
| `scope:Computed(fn)` | Derives a value from dependencies. Re-evaluates when any `use()`d dependency changes. |
| `scope:Observer(state)` | Runs side effects when a state object changes. |
| `scope:New "ClassName" { props }` | Declarative instance construction. State objects as property values auto-bind. |
| `scope:Hydrate(instance) { props }` | Binds reactive properties to an existing instance. |
| `[Children]` | Special key for declaring child instances in a property table. |
| `scope:ForValues(state, mapper)` | Incrementally maps a reactive list to instances. |
| `scope:Spring(target, speed, damping)` | Animated state object using spring physics. |
| `scope:Tween(target, tweenInfo)` | Animated state object using TweenService curves. |
| `peek(state)` | Reads the current value of any state object without creating a dependency. |
| `use(state)` | Inside a Computed: reads and subscribes to a state object. |

## When to Use / When Not to Use

**Use when:**
- Building reactive UI where state drives the display
- You want declarative instance construction instead of imperative property setting
- The project needs animation primitives tightly integrated with state
- Pairing with any framework ([[Knit]] + Fusion, [[Flamework]] + Fusion, [[Matter]] + Fusion are all common)

**Do not use when:**
- You need a stable API with no breaking changes (Fusion is pre-1.0)
- Simple static UI that rarely updates (overkill)
- The team is unfamiliar with reactive programming concepts

## Alternatives

| Library | Trade-off |
|---------|-----------|
| Roact | React port with virtual DOM diff. Frozen but stable. Heavier re-render model. |
| Native ScreenGui | No abstraction overhead. Manual property management and cleanup. |
| React-lua | Roblox's official React binding. Still maturing in the ecosystem. |

## Related

- [[Trove]] -- scope-based cleanup (Fusion scopes solve the same problem)
- [[Knit]] -- commonly paired for game logic while Fusion handles UI
- [[GoodSignal]] -- Fusion's observer primitives use a similar dispatch pattern

## Sources

- [Fusion README](wiki/raw/community/articles/library-readmes/fusion-readme.md)
- [DevForum: Fusion possiblyOutlives, scopes and you](wiki/raw/community/devforum/fusion-possiblyoutlives-scopes.md)
- GitHub: https://github.com/dphfox/Fusion
- Docs: https://elttob.uk/Fusion/
- Tutorials: https://elttob.uk/Fusion/0.3/tutorials/
