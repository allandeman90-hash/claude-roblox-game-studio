---
title: streaming-enabled
type: concept
category: concepts
subcategory: performance
owner: level-designer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/network/streaming-enabled-guide.md
related:
  - "[[Workspace]]"
  - "[[level-design]]"
  - "[[module-lazy-loading]]"
tags: [concept, performance]
---

# StreamingEnabled

**Status: stub** — needs full elaboration from `wiki/raw/community/performance/network/streaming-enabled-guide.md` and official docs.

## Summary

`workspace.StreamingEnabled = true` makes Roblox dynamically load and unload workspace instances on each client based on distance from the player. Required for large maps; saves memory and improves client performance, but complicates code that assumes instances always exist.

Default radii: `StreamingMinRadius = 64`, `StreamingTargetRadius = 1024` studs.

## TODO

- Full properties reference (StreamingMinRadius, StreamingTargetRadius, StreamingIntegrityMode, StreamingMode)
- Model.LevelOfDetail and Model.StreamingMode
- Persistent marking
- Effect on LocalScripts: instances may not exist when referenced
- `WaitForChild` patterns for streamed content
- Performance benchmarks
- When to enable, when to skip

## Related

- [[Workspace]]
- [[level-design]]
- [[module-lazy-loading]]

## Sources

- [wiki/raw/community/performance/network/streaming-enabled-guide.md](../raw/community/performance/network/streaming-enabled-guide.md)
- [Roblox docs: Instance streaming](https://create.roblox.com/docs/projects/streaming)
