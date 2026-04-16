---
title: CollectionService Tags
type: studio
category: studio
subcategory: patterns
owner: roblox-studio-specialist
status: draft
created: 2026-04-16
updated: 2026-04-15
sources:
  - wiki/raw/community/reddit/collectionservice-tags-pattern.md
  - wiki/raw/roblox-creator-docs/services/CollectionService.md
related:
  - "[[CollectionService]]"
  - "[[attributes]]"
  - "[[trove-maid-cleanup]]"
  - "[[connection-leaks]]"
tags: [studio, patterns, collectionservice, tags, binder]
---

# CollectionService Tags

> CollectionService is a global tag index on Instances. The Binder pattern uses it to attach behavior to every Instance with a given tag, decoupling logic from naming conventions or folder structure.

## Summary

`CollectionService` manages groups (collections) of Instances via string tags. Tags replicate from server to client and are serialized when places are saved. The primary use case is to register Instances with specific tags and then run centralized behavior for all tagged Instances -- the "Binder" pattern.

Tags can be applied in Studio via the **Tag Editor** (Properties panel > Instance Tags section) or programmatically at runtime.

## API Surface

### Methods

| Method | Signature | Description |
|---|---|---|
| `AddTag` | `(instance: Instance, tag: string) -> ()` | Apply a tag to an Instance |
| `RemoveTag` | `(instance: Instance, tag: string) -> ()` | Remove a tag from an Instance |
| `GetTagged` | `(tag: string) -> {Instance}` | All Instances with the tag (no ordering guarantee) |
| `HasTag` | `(instance: Instance, tag: string) -> boolean` | Check if an Instance has a tag |
| `GetTags` | `(instance: Instance) -> {string}` | All tags on an Instance |
| `GetAllTags` | `() -> {string}` | All tags in the experience |
| `GetInstanceAddedSignal` | `(tag: string) -> RBXScriptSignal` | Fires when the tag is added to an Instance in the DataModel |
| `GetInstanceRemovedSignal` | `(tag: string) -> RBXScriptSignal` | Fires when the tag is removed or the Instance leaves the DataModel |

### Events

| Event | Description |
|---|---|
| `TagAdded(tag: string)` | Fires when a tag appears in the place for the first time |
| `TagRemoved(tag: string)` | Fires when the last Instance with a tag is untagged |

## The Binder Pattern

The canonical way to attach behavior to "every Instance with tag X" covers three cases:

```lua
local CollectionService = game:GetService("CollectionService")
local Trove = require(game.ReplicatedStorage.Packages.Trove)

local TAG = "Explodable"
local troves: {[Instance]: any} = {}

local function onAdded(instance: Instance)
    local trove = Trove.new()
    troves[instance] = trove

    trove:Add(instance.Touched:Connect(function(hit)
        -- boom logic
    end))
end

local function onRemoved(instance: Instance)
    local trove = troves[instance]
    if trove then
        trove:Clean()
        troves[instance] = nil
    end
end

-- 1. Handle Instances that already have the tag at script start.
for _, instance in CollectionService:GetTagged(TAG) do
    onAdded(instance)
end

-- 2. Handle Instances that receive the tag later.
CollectionService:GetInstanceAddedSignal(TAG):Connect(onAdded)

-- 3. Handle Instances that lose the tag (or get destroyed).
CollectionService:GetInstanceRemovedSignal(TAG):Connect(onRemoved)
```

### Why all three cases?

- **Only step 2** misses Instances already tagged before the script runs.
- **Only step 1** misses Instances tagged at runtime (e.g., spawned enemies).
- **Without step 3**, event connections from `onAdded` keep references alive, causing memory leaks (see [[connection-leaks]]).

## Why Tags Instead of Alternatives

| Alternative | Problem |
|---|---|
| Parent to a specific folder | Couples data structure to code structure. Tags are orthogonal -- a part can be in `workspace.City.Buildings` and still be tagged `Explodable` and `Lit`. |
| Script inside each part | 100 scripts for 100 parts instead of one coordinator. No shared state. Refactoring means editing every script. |
| Check `Instance.Name` | Names are unique within a parent and can conflict. Multiple tags can coexist on a single Instance; names cannot. |

## Practical Uses

- **Doors:** Tag = `Door`. Binder sets up ProximityPrompt + open/close animation + state.
- **Enemies:** Tag = `Enemy`. Binder creates humanoid AI, pathfinding, health bar.
- **Pickups:** Tag = `Pickup`. Binder connects `Touched`, gives item, destroys.
- **Spawners:** Tag = `Spawner`. Binder starts a spawn loop on each Instance.
- **UI anchors:** Tag = `HoverText`. Binder creates a BillboardGui on each tagged part.

## Replication Caveats

- All tags on an Instance replicate as a set. If the client adds tag A and the server later adds/removes tag B on the same Instance, the client's local tags are overwritten.
- In `StreamingEnabled` places, Instances that leave the streamed area and re-enter will have their tags re-synchronized from the server, overwriting any client-side changes.

## Pitfalls

- **Memory leaks.** Always pair `GetInstanceAddedSignal` with `GetInstanceRemovedSignal`. Use a [[trove-maid-cleanup]] helper to collect per-Instance connections and clean them up when the tag is removed.
- **No ordering guarantee.** `GetTagged` returns Instances in arbitrary order. Do not rely on iteration order.
- **Deprecated methods.** `GetCollection`, `ItemAdded`, `ItemRemoved` are deprecated. Use `GetTagged` and the tag-specific signals instead.

## Related

- [[CollectionService]]
- [[attributes]]
- [[trove-maid-cleanup]]
- [[connection-leaks]]

## Sources

- [CollectionService tags pattern (Reddit)](../raw/community/reddit/collectionservice-tags-pattern.md)
- [CollectionService API reference](../raw/roblox-creator-docs/services/CollectionService.md)
- Official docs: https://create.roblox.com/docs/reference/engine/classes/CollectionService
