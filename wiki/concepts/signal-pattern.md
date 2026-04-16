---
title: signal-pattern
type: concept
category: concepts
subcategory: event-handling
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/devforum/goodsignal-lua-signal-comparison.md
related:
  - "[[trove-maid-cleanup]]"
  - "[[BindableEvent]]"
  - "[[RemoteEvent]]"
tags: [concept, event-handling]
---

# Signal Pattern

**Status: stub** — needs flesh-out from GoodSignal and FastSignal docs during next `/wiki-ingest`.

## Summary

Custom event/signal libraries like GoodSignal (stravant) and FastSignal (LucasMZ) offer a pub/sub pattern with `:Connect`, `:Fire`, and `:Wait` semantics but without the network-replication overhead of `BindableEvent`. Used for intra-server event coordination.

## TODO

- Contrast GoodSignal vs FastSignal vs BindableEvent
- Show the standard API (`:Connect`, `:Fire`, `:Wait`, `:Once`, `:DisconnectAll`)
- Why prefer signals over BindableEvent (no yielding across boundaries, cleaner API)
- Integration with Trove/Maid for cleanup
- Example: event-driven system decoupling

## Related

- [[trove-maid-cleanup]]
- [[BindableEvent]]
- [[RemoteEvent]]

## Sources

- [wiki/raw/community/devforum/goodsignal-lua-signal-comparison.md](../raw/community/devforum/goodsignal-lua-signal-comparison.md)
