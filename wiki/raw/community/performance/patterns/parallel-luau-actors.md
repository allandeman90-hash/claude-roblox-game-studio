---
title: Parallel Luau V2 - Actors and SharedTable
type: raw-source
source_url: https://devforum.roblox.com/t/parallel-luau-version-2-release/2399970
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: patterns
tags: [parallel-luau, actors, shared-table, multithreading, performance]
---

# Parallel Luau V2 - Actors and SharedTable

## Key Features

### Actor Messaging API

Asynchronous message passing between scripts and Actors using "topics" to categorize messages. Only scripts descended from Actors can receive messages; any script may send them.

**Sender:**
```lua
workerActor:SendMessage("Greeting", "Hello World!")
```

**Receiver:**
```lua
local actor = script:GetActor()
actor:BindToMessageParallel("Greeting", function(msg)
    print(msg)
end)
```

### SharedTable

A data structure allowing efficient data sharing across multiple Actors without copying.

**Features:**
- Supports **string and non-negative integer keys only**
- Inexpensive cloning via structural sharing
- Access pattern mirrors standard Luau tables: `st[k] = v`, `v = st[k]`
- Global `SharedTableRegistry` for sharing across the DataModel

**Basic usage:**
```lua
local st = SharedTable.new()
st.a = 100
local clone = SharedTable.clone(st)

-- Share across DataModel
SharedTableRegistry:SetSharedTable("mykey", st)
local retrieved = SharedTableRegistry:GetSharedTable("mykey")
```

## Scheduling & Behavior Changes

- Parallel scripts now resume at consistent "resumption points" with deferred threads
- `ConnectParallel` callbacks execute during their engine phase
- `task.defer()`, `task.delay()`, and `task.wait()` maintain calling context (serial/parallel)
- `task.synchronize()` and `task.desynchronize()` restricted to Actor descendants

## Thread-Safe APIs Added

Over 20 APIs made accessible to parallel scripts:
- Instance methods: `GetActor()`, `GetPivot()`
- Physics: `BasePart:CanCollideWith()`, workspace throttling queries
- Utilities: `HTTPService` JSON functions, `RunService` checks

## Thread Limits

- **Client**: 3-thread limit (recent)
- **Server**: More threads based on player count

## Performance Caveats

Passing data back from an actor VM to the original VM using a bindable event causes significant bottlenecks, often resulting in slower performance than serial execution due to deferred signal behavior.

**Key insight**: Actor communication overhead can eliminate parallel gains if messages cross VMs frequently. Design for coarse-grained work batches, not fine-grained.

## When to Use

**Good fits:**
- Large chunk-based terrain generation
- Per-Actor AI simulation
- Physics solver distribution
- Independent compute-heavy tasks

**Bad fits:**
- Tasks requiring frequent cross-actor communication
- UI work (always main thread)
- Code that relies on shared mutable state

## Availability

Roblox 576 and later; mobile and console platforms updated progressively.

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Client thread limit | 3 threads |
| Server thread limit | Scales with player count |
| Safe SharedTable keys | string, non-negative integer |

## Source

Original URL: https://devforum.roblox.com/t/parallel-luau-version-2-release/2399970
Captured: 2026-04-16
