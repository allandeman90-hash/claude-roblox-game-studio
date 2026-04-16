---
title: collection-service-tags
type: studio
category: studio
subcategory: patterns
owner: roblox-studio-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/reddit/collectionservice-tags-pattern.md
related:
  - "[[CollectionService]]"
  - "[[attributes]]"
tags: [studio, patterns]
---

# CollectionService Tags

**Status:** stub

## Summary

CollectionService lets you tag any `Instance` with a string and query all tagged instances later. The foundation of the "Binder" pattern — decoupling per-instance logic from naming conventions or direct references.

```lua
CollectionService:AddTag(part, "Interactive")
for _, obj in ipairs(CollectionService:GetTagged("Interactive")) do
    setupInteractive(obj)
end
CollectionService:GetInstanceAddedSignal("Interactive"):Connect(setupInteractive)
```

## Related

- [[CollectionService]]
- [[attributes]]

## Sources

- [wiki/raw/community/reddit/collectionservice-tags-pattern.md](../raw/community/reddit/collectionservice-tags-pattern.md)
