---
title: CollectionService
type: service
category: services
subcategory: patterns
owner: roblox-studio-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/CollectionService.md
related:
  - "[[collection-service-tags]]"
  - "[[attributes]]"
tags: [roblox-class, patterns]
---

# CollectionService

> Manages instance collections using assigned tags. [[collection-service-tags]]

## Summary

CollectionService manages groups (collections) of instances using **tags** -- string identifiers applied to instances. Tags replicate from the server to the client and are serialized when places are saved. The primary use is to register instances with specific tags to extend their behavior without per-instance scripts.

If you find yourself adding the same script to many different instances, a script that uses CollectionService is almost always better. Tags can be added or removed through API methods (`AddTag`, `RemoveTag`) or directly in Studio through the Tags section of an instance's properties panel.

This service is the foundation of the "Binder" pattern: tag instances in Studio, then have a single script iterate all tagged instances and attach behavior. This decouples instance identity from naming conventions and makes large-scale behavior management practical.

## API Surface

### Properties

_No public properties._

### Methods

- `:AddTag(instance: Instance, tag: string) -> ()` -- Applies a tag to an instance. Fires the signal from `GetInstanceAddedSignal()`.
- `:RemoveTag(instance: Instance, tag: string) -> ()` -- Removes a tag from an instance. Fires the signal from `GetInstanceRemovedSignal()`.
- `:GetTagged(tag: string) -> {Instance}` -- Returns all instances in the DataModel with the given tag. No ordering guarantee.
- `:GetTags(instance: Instance) -> {string}` -- Returns all tags applied to a given instance.
- `:HasTag(instance: Instance, tag: string) -> boolean` -- Checks whether an instance has a given tag.
- `:GetAllTags() -> {string}` -- Returns an array of all tags in the experience.
- `:GetInstanceAddedSignal(tag: string) -> RBXScriptSignal` -- Returns a signal that fires when the given tag is added to an instance in the DataModel.
- `:GetInstanceRemovedSignal(tag: string) -> RBXScriptSignal` -- Returns a signal that fires when the given tag is removed from an instance in the DataModel.

### Events

- `.TagAdded:Connect(fn(tag: string))` -- Fires when a tag is added and it is the only occurrence of that tag in the place.
- `.TagRemoved:Connect(fn(tag: string))` -- Fires when a tag is removed and no other instances have that tag.

## Budgets and Limits

No explicit rate limits documented for tag operations. However:

- **Replication**: All tags on an instance replicate together. Setting a tag from the client, then having the server add/remove a different tag on the same instance, overwrites the client's local tags.
- **StreamingEnabled**: Instances that leave the streamed area lose local tag changes. Re-entering the area re-syncs from the server.

## Common Patterns

### Binder pattern -- attach behavior to tagged instances

```lua
-- ServerScriptService/DeadlyBricks.server.lua
local CollectionService = game:GetService("CollectionService")

local TAG = "DeadlyBrick"

local function setupBrick(brick: BasePart)
    brick.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(100)
        end
    end)
end

-- Handle existing tagged instances
for _, brick in CollectionService:GetTagged(TAG) do
    setupBrick(brick)
end

-- Handle future tagged instances
CollectionService:GetInstanceAddedSignal(TAG):Connect(setupBrick)
```

### Cleanup on tag removal

```lua
local connections: {[Instance]: RBXScriptConnection} = {}

CollectionService:GetInstanceAddedSignal("Pickup"):Connect(function(inst)
    connections[inst] = inst.Touched:Connect(function(hit)
        -- pickup logic
    end)
end)

CollectionService:GetInstanceRemovedSignal("Pickup"):Connect(function(inst)
    if connections[inst] then
        connections[inst]:Disconnect()
        connections[inst] = nil
    end
end)
```

## Pitfalls

- **Client tag overwrites**: Tags set client-side are lost when the server modifies any tag on the same instance (all tags replicate as a unit).
- **Memory leaks**: When a tag is removed or an instance is destroyed, clean up connections and tables. Use `GetInstanceRemovedSignal` for this.
- **No ordering**: `GetTagged()` does not guarantee order. Do not rely on iteration order.
- **Nil-parent instances**: Instances with a tag but `Parent = nil` are not returned by `GetTagged()`.
- **Deprecated methods**: `GetCollection()`, `ItemAdded`, `ItemRemoved` are deprecated. Use the tag-based API instead.

## Related

- [[collection-service-tags]] -- full pattern guide
- [[attributes]] -- complementary per-instance data

## Sources

- [wiki/raw/roblox-creator-docs/services/CollectionService.md](../raw/roblox-creator-docs/services/CollectionService.md)
