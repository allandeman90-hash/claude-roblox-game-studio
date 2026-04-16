---
title: object-pooling
type: performance
category: performance
subcategory: patterns
owner: performance-analyst
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/patterns/object-pooling.md
related:
  - "[[trove-maid-cleanup]]"
  - "[[draw-call-optimization]]"
tags: [performance, patterns]
---

# Object Pooling

**Status:** stub

## Summary

Reuse Instances (Parts, Sounds, particle emitters) instead of creating and destroying them. Reduces allocation cost, eliminates GC pressure, avoids Instance creation overhead.

Canonical implementation: [PartCache](https://devforum.roblox.com/t/partcache-for-all-your-quick-part-creation-needs/246641) (CloneTrooper1019).

## TODO

- Full PartCache pattern
- Sound pooling for high-frequency SFX
- ParticleEmitter pooling
- Trade-offs (memory vs CPU)
- When pooling is unnecessary

## Related

- [[trove-maid-cleanup]]
- [[draw-call-optimization]]

## Sources

- [wiki/raw/community/performance/patterns/object-pooling.md](../raw/community/performance/patterns/object-pooling.md)
