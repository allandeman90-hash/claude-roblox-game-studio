---
title: draw-call-optimization
type: performance
category: performance
subcategory: rendering
owner: technical-artist
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/rendering/optimization-guide-draw-calls.md
related:
  - "[[object-pooling]]"
  - "[[streaming-enabled]]"
tags: [performance, rendering]
---

# Draw Call Optimization

**Status:** stub

## Summary

**Target: < 500 draw calls per frame**. Each unique mesh + material combination is a draw call. Reducing count via mesh ID reuse, texture atlasing, and mesh instancing is key for mobile performance.

## TODO

- Draw call measurement (Developer Console rendering stats)
- Mesh ID deduplication (instancing)
- Texture atlas strategy
- Material reuse
- Union / mesh part trade-offs
- Transparency overdraw cost

## Related

- [[object-pooling]]
- [[streaming-enabled]]

## Sources

- [wiki/raw/community/performance/rendering/optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)
