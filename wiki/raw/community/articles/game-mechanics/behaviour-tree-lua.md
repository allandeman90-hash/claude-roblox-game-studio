---
title: "BehaviourTree.lua - Lua Behavior Tree Library"
source_url: "https://github.com/tanema/behaviourtree.lua"
source_type: github-library
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# BehaviourTree.lua

Simple behaviour tree library for Lua (ported from JavaScript). Multiple Roblox forks exist (behaviortree.rbxlua).

## Node Types

### Task (Leaf Node)
```lua
local mytask = BehaviourTree.Task:new({
    start = function(task, obj)
        obj.isStarted = true
    end,
    finish = function(task, obj)
        obj.isStarted = false
    end,
    run = function(task, obj)
        task:success()
    end
})
```

Lifecycle: start() -> run() -> finish()
run() must call one of: success(), fail(), running()

### Sequence
Executes children sequentially. Fails if any child fails. Succeeds after all succeed.

```lua
local mysequence = BehaviourTree.Sequence:new({
    nodes = { task1, task2, task3 }
})
```

### Priority (Selector)
Executes children until one succeeds. Fails if all fail.

```lua
local myselector = BehaviourTree.Priority:new({
    nodes = { task1, task2, task3 }
})
```

### Random
Randomly selects one child to execute.

```lua
local myrandom = BehaviourTree.Random:new({
    nodes = { task1, task2 }
})
```

## Decorators

### InvertDecorator
Flips success/fail.

### AlwaysSucceedDecorator
Converts fail to success.

### AlwaysFailDecorator
Converts success to fail.

```lua
local decorated = BehaviourTree.InvertDecorator:new({
    node = mysequence
})
```

## Node Registration
```lua
BehaviourTree.register('testtask', mytask)

-- Or auto-register with name field:
BehaviourTree.Task:new({
    name = 'registered task',
    run = function(task, dog) task:success() end
})
```

## Tree Creation and Execution
```lua
local btree = BehaviourTree:new({
    tree = BehaviourTree.Sequence:new({
        nodes = {
            'bark',
            BehaviourTree.Task:new({
                run = function(task, dog)
                    dog:randomlyWalk()
                    task:success()
                end
            }),
        }
    })
})

btree:setObject(dog)
btree:run()  -- call each tick/frame
```

## Roblox Forks
- github.com/seyaidev/behaviortree.rbxlua
- github.com/howmanysmall/behaviortree.rbxlua
