---
title: Using Janitor to Combat Memory Leaks
type: raw-source
source_url: https://devforum.roblox.com/t/using-janitor-to-combat-memory-leaks/1601710
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: LucasMZ_RBX
post_date: 2021-12-25
tags: [janitor, maid, cleanup, memory-leaks, connections, oop]
---

# Using Janitor to Combat Memory Leaks

**Author:** LucasMZ_RBX
**Posted:** December 25, 2021

## Overview

Janitor is a reference management library designed to prevent memory leaks by tracking objects requiring cleanup. The author describes it as superior to Maid due to "better type checking" and improved developer experience.

## Core Purpose

The primary use case involves storing `RBXScriptConnection`s to disconnect them when no longer needed, preventing "functions, instances from never being collected."

## Creating a Janitor Instance

```lua
local janitor = Janitor.new()
```

## Adding Objects to Janitor

**RBXScriptConnections:**
```lua
janitor:Add(
    BindableEvent.Event:Connect(function()
        print("Fired")
    end)
)
```

**Instances:**
```lua
janitor:Add(part, "Destroy")
```

**Custom Objects:**
```lua
janitor:Add(
    GoodSignal.new(), "DisconnectAll"
)
```

**Functions:**
```lua
janitor:Add(function()
    print("Called during cleanup")
end)
```

## Cleanup Methods

- **`:Cleanup()`** — Destroys all tracked objects and clears references
- **`:Destroy()`** — Calls Cleanup and renders the Janitor unusable
- **`:LinkToInstance(part)`** — Auto-cleanup when an Instance is destroyed

## Removing Objects Prematurely

Objects require an index to be removable before full cleanup:

```lua
janitor:Add(Signal, "Destroy", "SomeEventThatHandlesSomething")
janitor:Remove("SomeEventThatHandlesSomething")
```

## Class Integration Pattern

```lua
function Timer.new(goal: number)
    local self = setmetatable({
        TimePassed = 0,
        GoalReached = Signal.new(),
        _goal = goal,
        _janitor = Janitor.new()
    }, Timer)

    self._janitor:Add(self.GoalReached, "Destroy")
    return self
end

function Timer:Destroy()
    local janitor = self._janitor
    if janitor then
        janitor:Destroy()
        self._janitor = nil
    end
end
```

## Notable Feature

`:Add()` returns the passed object, enabling inline construction and method chaining.

## Source

Original URL: https://devforum.roblox.com/t/using-janitor-to-combat-memory-leaks/1601710
Captured: 2026-04-16
