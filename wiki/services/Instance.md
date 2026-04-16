---
title: Instance
type: service
category: services
subcategory: core
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources: [wiki/raw/roblox-creator-docs/services/Instance.md]
related:
  - "[[BasePart]]"
  - "[[Model]]"
  - "[[Player]]"
  - "[[CollectionService]]"
tags: [roblox-class, core, hierarchy, base-class]
---

# Instance

> The base class for all objects in the Roblox class hierarchy that can exist in the DataModel tree. [[BasePart]]

## Summary

Instance is the root of the Roblox object hierarchy. Every object in the DataModel -- Parts, Models, Scripts, GUI elements -- inherits from Instance. It cannot be created directly; instead, `Instance.new("ClassName")` creates objects of specific subclasses.

Instance provides the universal API surface shared by all Roblox objects: parenting (Parent, GetChildren, GetDescendants), naming (Name, GetFullName), cloning (Clone), destruction (Destroy), attribute storage (SetAttribute/GetAttribute), and tagging (AddTag/HasTag/GetTags). Understanding Instance is essential because every other class inherits these members.

The Parent property controls whether an object exists in the experience. Setting Parent to nil removes the object from the tree (though it persists if referenced). Calling Destroy() sets Parent to nil and locks it permanently.

## API Surface

### Properties
- `Archivable: boolean` -- Whether the instance can be cloned or saved/published
- `Name: string` -- Non-unique identifier (max 100 characters). Used for hierarchy access via dot notation
- `Parent: Instance?` -- Hierarchical parent. Setting to nil removes from tree; Destroy locks it
- `Capabilities: SecurityCapabilities` -- Sandbox capabilities for contained scripts (experimental)
- `Sandboxed: boolean` -- Whether scripts inside are sandboxed (experimental)
- `UniqueId: UniqueId` -- Internal unique identifier (not scriptable)

### Methods
- `:Clone() -> Instance?` -- Deep-copies the instance and descendants. Returns nil if Archivable is false
- `:Destroy() -> ()` -- Sets Parent to nil, locks it, disconnects all events. Irreversible
- `:GetChildren() -> {Instance}` -- Returns array of direct children (unsorted)
- `:GetDescendants() -> {Instance}` -- Returns array of all descendants (unsorted)
- `:FindFirstChild(name: string, recursive: boolean?) -> Instance?` -- Finds first child by name
- `:FindFirstChildOfClass(className: string) -> Instance?` -- Finds first child of exact class
- `:FindFirstChildWhichIsA(className: string, recursive: boolean?) -> Instance?` -- Finds first child that IsA given class
- `:FindFirstAncestor(name: string) -> Instance?` -- Searches up the hierarchy by name
- `:FindFirstAncestorOfClass(className: string) -> Instance?` -- Searches up by class
- `:FindFirstAncestorWhichIsA(className: string) -> Instance?` -- Searches up by IsA
- `:WaitForChild(name: string, timeout: number?) -> Instance?` -- Yields until child exists or timeout
- `:IsA(className: string) -> boolean` -- Returns true if instance is of the given class or a subclass
- `:IsDescendantOf(ancestor: Instance) -> boolean` -- Checks ancestry chain
- `:IsAncestorOf(descendant: Instance) -> boolean` -- Checks descendant chain
- `:GetFullName() -> string` -- Returns dot-separated ancestry string
- `:SetAttribute(name: string, value: Variant?) -> ()` -- Sets or clears a custom attribute
- `:GetAttribute(name: string) -> Variant?` -- Gets an attribute value
- `:GetAttributes() -> {[string]: Variant}` -- Gets all attributes as a dictionary
- `:GetAttributeChangedSignal(name: string) -> RBXScriptSignal` -- Signal for specific attribute change
- `:AddTag(tag: string) -> ()` -- Adds a tag to the instance
- `:RemoveTag(tag: string) -> ()` -- Removes a tag
- `:HasTag(tag: string) -> boolean` -- Checks for a tag
- `:GetTags() -> {string}` -- Gets all tags

### Events
- `.ChildAdded:Connect(fn(child: Instance))` -- Fires when a direct child is added
- `.ChildRemoved:Connect(fn(child: Instance))` -- Fires when a direct child is removed
- `.DescendantAdded:Connect(fn(descendant: Instance))` -- Fires for any descendant added
- `.DescendantRemoving:Connect(fn(descendant: Instance))` -- Fires just before a descendant is removed
- `.Destroying:Connect(fn())` -- Fires when Destroy() is called (timing depends on SignalBehavior)
- `.AttributeChanged:Connect(fn(attribute: string))` -- Fires when any attribute changes
- `.AncestryChanged:Connect(fn(child: Instance, parent: Instance?))` -- Fires when Parent or any ancestor's Parent changes

## Budgets and Limits

- **Name length**: Maximum 100 characters.
- **Attribute limits**: Attribute names and values have size restrictions. Total attribute data per instance is limited.
- **WaitForChild**: Yields indefinitely if no timeout is specified and the child never appears. Always provide a timeout in production code.

## Common Patterns

### Creating and parenting objects (set Parent last)

```lua
-- Set properties before parenting to avoid multiple replication events
local part = Instance.new("Part")
part.Size = Vector3.new(4, 1, 4)
part.Position = Vector3.new(0, 10, 0)
part.Parent = workspace  -- Parent LAST
```

### Safe child access with WaitForChild

```lua
-- On the client, server-created objects may not exist yet
local character = player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 5)
if humanoid then
    -- safe to use
end
```

### Using tags with CollectionService

```lua
local CollectionService = game:GetService("CollectionService")

local part = Instance.new("Part")
part:AddTag("Lava")
part.Parent = workspace

-- Elsewhere: find all tagged objects
for _, lava in CollectionService:GetTagged("Lava") do
    -- setup lava behavior
end
```

## Pitfalls

- **Parent last on creation**: Setting Parent before other properties causes partial replication. Always set Parent last when creating objects via `Instance.new()`.
- **WaitForChild without timeout**: Omitting the timeout parameter causes the thread to yield forever if the child never appears. Always specify a timeout.
- **Destroy is final**: Once Destroy() is called, the Parent is locked. The object cannot be reparented.
- **DescendantRemoving vs ChildRemoved**: DescendantRemoving fires before removal; ChildRemoved fires after. Do not try to reparent the descendant inside DescendantRemoving.
- **Clone and Archivable**: Clone() returns nil for objects with Archivable = false. This is silent -- no error is raised.
- **Name collisions**: If multiple siblings share a name, dot-access and FindFirstChild return only one (unpredictable which). Use unique names or structural access.

## Related

- [[BasePart]] -- the base class for physical objects, inherits from Instance
- [[Model]] -- container for groups of parts, inherits from Instance
- [[Player]] -- player objects are Instances in the Players service
- [[CollectionService]] -- service for working with Instance tags at scale

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/Instance.md)
