---
title: With DataStore v2.0 coming out, should I stop using the DataStore2 module?
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/p4ru66/with_datastore_v20_coming_out_should_i_stop_using/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [datastore, datastore2, profileservice, versioning, data-persistence]
---

# With DataStore v2.0 coming out, should I stop using the DataStore2 module?

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/p4ru66/

## Context

Roblox released DataStore v2.0 with native versioning and snapshots. This post asks whether it's still worth running the community `DataStore2` module on top of it.

## The Community Consensus

> "You never really needed DataStore 2 because actual data loss is extremely rare. But, now, DataStore 2 is pretty much useless because of the update."

Key points from the thread:

- **DataStore2** was a community module (by Kampfkarren) that used caching + a versioning pattern to guard against data loss in the old DataStoreService.
- **DataStore v2.0** is the official update that adds automatic version history to `DataStoreService`. It's fully backward compatible — your existing `:GetAsync` / `:SetAsync` code keeps working, and Roblox now keeps a version history of each key so you can roll back corrupted writes.
- With the native versioning, the main justification for DataStore2 (protection against data loss from failed writes) largely disappears.

## What to Use in 2025-2026

The thread + surrounding subreddit context recommend:

1. **For new projects**: Use `DataStoreService` directly **with session locking** (ProfileService or its modern successor ProfileStore).
2. **Never use raw SetAsync without pcall** and never rely on a single save — always retry on failure.
3. **Do not use DataStore2 for new code.** It still works, but it's legacy.
4. **ProfileService** is stable but no longer supported — **ProfileStore** is the community's current recommendation for serious projects.

## Why Session Locking Still Matters (Even With v2.0)

DataStore v2.0 fixes the "my write was lost" problem, but it does **not** fix the "two servers wrote to the same key and clobbered each other" problem (item duplication from teleport/join race conditions). That is what ProfileService / ProfileStore solve via profile session locking — they ensure only one Roblox server holds the "lock" on a user's data at a time.

So the modern stack looks like:

- `DataStoreService` (with v2.0 versioning)
- `+ ProfileStore` (session locking, auto-save, clean API)
- `+ pcall` and retry logic wrapped around every load/save

## Key Quotes Worth Remembering

- "Actual data loss [from DataStore bugs] is extremely rare."
- "DataStore 2 is pretty much useless because of the update."
- Native versioning ≠ session locking. You still need session locking to prevent duplication.

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/p4ru66/with_datastore_v20_coming_out_should_i_stop_using/
Captured: 2026-04-16

## Related Subreddit Threads

- How do I learn and understand data stores? — /r/robloxgamedev/comments/191w34l/
- What libraries do u guys use for data storage and remote events — /r/robloxgamedev/comments/1hhjnmz/
- How to create a global leaderboard using Profile Service — /r/robloxgamedev/comments/1gqrqlv/

## Notes

Content reconstructed from search snippets. The advice aligns with Roblox's own documentation updates and with ProfileStore's upgrade notes.
