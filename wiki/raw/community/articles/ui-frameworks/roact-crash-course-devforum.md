---
title: "Roact UI Framework Crash Course (Deprecated)"
source_type: devforum-tutorial
url: https://devforum.roblox.com/t/roact-ui-framework-crash-course-deprecated/796618
captured: 2026-04-15
tags: [roact, react-lua, ui-framework, declarative-ui, components, deprecated]
---

# Roact UI Framework Crash Course

**Note: Roact is deprecated as of 2025. Superseded by React-lua (functional components, hooks, closer to mainline React). Captured for historical context.**

## What is Roact?

Roact is "a declarative Lua UI library similar to Facebook's React." Developers programmatically construct a tree of components that Roact mounts and reconciles with the player's display.

### Advantages of Declarative UI
- **Reusability**: Components encapsulate both appearance and functionality
- **Version control**: Code-based UI integrates cleanly with Git and Rojo workflows
- **Maintainability**: Larger projects benefit from standardized component structure

## Core Concepts

### Elements
Created via `Roact.createElement()`. Accept:
1. Element type (string for Roblox classes or custom components)
2. Properties dictionary
3. Children dictionary (optional)

```lua
local interface = Roact.createElement("ScreenGui", {Name = "Interface"}, {
    Label = Roact.createElement("TextLabel", {Text = "Hello, Roact!"})
})
Roact.mount(interface, playerGui)
```

### Components (Three Types)

**Host Components**: Standard Roblox classes (ScreenGui, TextLabel, etc.)

**Function Components**: Functions receiving props and returning elements
```lua
function Interface(props)
    return Roact.createElement("ScreenGui", {}, {
        Label = Roact.createElement("TextLabel", props)
    })
end
```

**Stateful Components**: Classes extending `Roact.Component` with lifecycle methods and state
```lua
local Greeting = Roact.Component:extend("Greeting")
function Greeting:render()
    return Roact.createElement("ScreenGui", {}, {
        [self.props.name] = Roact.createElement("TextLabel", {...})
    })
end
```

## Key Features

### Events and Change Detection
```lua
[Roact.Event.Activated] = function(object, inputObject, clickCount)
    print(clickCount)
end

[Roact.Change.Text] = function(object)
    print(object.Text)
end
```

### Bindings (dynamic values without re-render)
```lua
function Button:init()
    self.clickCount, self.updateClickCount = Roact.createBinding(0)
end
```

### State (triggers full re-render)
```lua
function Button:init()
    self:setState({elementFlag = true})
end
```

### Refs, Portals, Fragments, Context
- Refs provide access to underlying Roblox instances
- Portals render children outside the component tree
- Fragments return multiple elements without a wrapper
- Context shares values across component trees

### Lifecycle Methods
- `init()`: Runs when component mounts
- `didMount()`: Called after mounting; refs have valid values
- `willUnmount()`: Cleanup before removal

## Scale Reference
The tutorial author used ~2200 components in Fishing Simulator: 87 buttons, 25 modals, 18 close buttons, 13 viewports.
