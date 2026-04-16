---
title: Session Locking Explained (Datastore)
type: raw-source
source_url: https://devforum.roblox.com/t/session-locking-explained-datastore/846799
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: ArtFoundation
post_date: 2020-10-30
tags: [datastore, session-locking, data-persistence, race-conditions, updateasync]
---

# Session Locking Explained (Datastore)

**Author:** ArtFoundation
**Posted:** October 30, 2020

## Core Concept

Session locking is a mechanism for preventing data regression and item duplication in Roblox games. It ensures sequential load-save operations by using a unique server identifier (JobId) to temporarily "lock" player data during loading, preventing simultaneous access from multiple servers.

## Key Problem Addressed

Race conditions can cause item duplication when players rejoin before data saves complete. Session locking eliminates this by marking data with the current server's JobId during the load operation. Without session locking, two servers might read the same data, make changes, and overwrite each other.

## Why UpdateAsync Only?

The tutorial emphasizes using only `UpdateAsync` because it provides atomic read-and-write operations. Unlike `GetAsync` (which caches for 4 seconds) and `SetAsync` (which cannot read current values), `UpdateAsync` retrieves the latest data while preventing overwrites.

## Implementation Overview

**Loading sequence:**
- Check if `SessionJobId` is nil or matches current server
- Set `SessionJobId` to current `JobId`
- Extract data for use
- Return updated data to datastore

**Saving sequence:**
- Verify session matches current server
- Set `SessionJobId` to nil to release lock

## Critical Edge Cases

- **Lock expiration:** Implement "leases" with timestamp checks (~30 minutes) to handle server crashes
- **Rapid rejoin:** Players rejoining the same server before initial load completes require queue systems
- **Cross-server handoff:** Use polling with exponential backoff or force-load mechanics after lease expiry

## Key Takeaway

Per the author:

> "Session locking is a more definitive answer to item duplication because it is irrelevant to timestamping, it keeps the save/load process sequential."

The tutorial recommends using **ProfileService** (or its successor **ProfileStore**) for production unless custom requirements exist.

## Source

Original URL: https://devforum.roblox.com/t/session-locking-explained-datastore/846799
Captured: 2026-04-16
