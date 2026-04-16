---
title: UI Framework Comparison
type: pattern
category: patterns
subcategory: ui
owner: ui-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/ui-frameworks/fusion-vs-react-lua-devforum.md
  - wiki/raw/community/articles/ui-frameworks/use-case-for-frameworks-devforum.md
  - wiki/raw/community/articles/ui-frameworks/roact-crash-course-devforum.md
related:
  - "[[responsive-design]]"
  - "[[camera-modes]]"
tags: [ui, framework, roact, fusion, react-lua, native, declarative]
---

# UI Framework Comparison

> Roblox offers three UI paradigms: native Instance manipulation, React-lua (successor to Roact), and Fusion. Each suits different project scales and team compositions.

## What It Is

A decision framework for choosing between Roblox UI approaches. The choice affects code organization, team workflow, debugging experience, and long-term maintenance cost.

## The Three Approaches

### Native Instance Manipulation

Direct creation and modification of Roblox UI instances (ScreenGui, Frame, TextLabel, etc.) via script or Studio editor.

```lua
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.1, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = playerGui.ScreenGui

local label = Instance.new("TextLabel")
label.Text = "Health: " .. tostring(health)
label.Size = UDim2.fromScale(1, 1)
label.Parent = frame

-- Manual update when state changes
healthChangedSignal:Connect(function(newHealth)
    label.Text = "Health: " .. tostring(newHealth)
end)
```

**Strengths:**
- Zero dependencies, zero build step
- Studio visual editor works directly
- Lowest learning curve
- CollectionService + Attributes provide lightweight reactivity

**Weaknesses:**
- State-to-UI synchronization is manual and error-prone
- Reusability requires discipline (templates, cloning patterns)
- Complex UIs become hard to maintain (spaghetti connections)
- No component lifecycle management

**Best for:** Small projects, simple UIs, beginners, rapid prototyping.

### React-lua (successor to Roact)

Declarative component-based UI inspired by React. Functional components, hooks, reconciliation. Maintained by the Roblox open-source community (jsdotlua/react-lua).

```lua
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local function HealthBar(props)
    return React.createElement("Frame", {
        Size = UDim2.new(0.3, 0, 0.1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
    }, {
        Label = React.createElement("TextLabel", {
            Text = "Health: " .. tostring(props.health),
            Size = UDim2.fromScale(1, 1),
        }),
    })
end
```

**Strengths:**
- Mature ecosystem (docs, tutorials, videos)
- Transferable skills from web React
- Functional components + hooks (useState, useEffect, useContext)
- Strong community support
- Stable, production-tested at scale (2200+ components in shipped games)

**Weaknesses:**
- Steeper learning curve than native
- Requires package manager (Wally) and Rojo/Argon workflow
- Virtual DOM overhead for simple UIs
- Not a complete UI solution on its own (needs styling approach)

**Best for:** Teams with web experience, large projects, complex state-driven UIs, Git-based workflows.

### Fusion

Reactive UI library built specifically for Luau. Uses State objects, Computed values, and automatic dependency tracking instead of a virtual DOM.

```lua
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Value = Fusion.Value
local Computed = Fusion.Computed

local health = Value(100)

local ui = New "Frame" {
    Size = UDim2.new(0.3, 0, 0.1, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    [Children] = {
        New "TextLabel" {
            Text = Computed(function(use)
                return "Health: " .. tostring(use(health))
            end),
            Size = UDim2.fromScale(1, 1),
        },
    },
}
```

**Strengths:**
- Built for Luau (no web baggage)
- More concise than React-lua
- Reactive state objects with automatic dependency tracking
- Built-in animation (Spring, Tween on state objects)
- Integrated scope-based memory management (v0.3+)

**Weaknesses:**
- Pre-1.0 software (v0.3 as of 2024), stability concerns
- Smaller ecosystem, fewer tutorials
- Breaking changes between versions
- Less transferable to other platforms

**Best for:** Luau-native teams, developers who prefer reactive over component paradigms, projects that need built-in animation reactivity.

## Decision Matrix

| Criterion | Native | React-lua | Fusion |
|-----------|--------|-----------|--------|
| Learning curve | Low | High | Medium |
| Ecosystem maturity | N/A (built-in) | High | Low |
| State management | Manual | Hooks/context | Reactive objects |
| Version control fit | Poor (Studio editor) | Excellent | Excellent |
| Team scalability | Low | High | Medium |
| Performance (simple UI) | Best | Overhead | Low overhead |
| Performance (complex UI) | Degrades | Good | Good |
| Animation support | Manual TweenService | External | Built-in |
| Production stability | Guaranteed | Stable | Pre-1.0 |

## When to Use Each

1. **Use Native** when the UI is simple (< 20 interactive elements), the team is small, and there is no Rojo/Git workflow.
2. **Use React-lua** when the team has web experience, the project has complex state-driven UI, and long-term maintainability matters.
3. **Use Fusion** when the team is Luau-native, values concise reactive code, and accepts pre-1.0 risk.

## Pitfalls

- Adopting a framework for a simple inventory screen adds unnecessary complexity.
- Mixing frameworks in one project fragments knowledge and increases onboarding cost.
- Fusion's pre-1.0 status means API breakage between versions; pin your dependency version.
- React-lua requires understanding reconciliation -- stale closures and unnecessary re-renders are common beginner bugs.
- Native UI at scale becomes unmaintainable without strict conventions (naming, folder structure, signal management).

## Related

- [[responsive-design]]
- [[camera-modes]]

## Sources

- [Fusion vs React-lua DevForum Discussion](wiki/raw/community/articles/ui-frameworks/fusion-vs-react-lua-devforum.md)
- [Use Case for Fusion / React / Native](wiki/raw/community/articles/ui-frameworks/use-case-for-frameworks-devforum.md)
- [Roact Crash Course (Deprecated)](wiki/raw/community/articles/ui-frameworks/roact-crash-course-devforum.md)
