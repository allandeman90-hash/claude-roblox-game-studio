---
title: Roblox Server Memory Limits
type: raw-source
source_url: https://devforum.roblox.com/t/increasing-server-memory-experiments/3105354
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: memory
tags: [server-memory, memory-limit, budget, memory-cap]
---

# Roblox Server Memory Limits

## Current Server Memory Cap

- **Base server memory cap: 6.4 GB**
- Dynamic scaling formula: **6.4 GB + 100 MB * (Peak Number of Players)** (reported by community)
- 700-player servers: 6.5 GB (reduced from 12.5 GB in 2024)

## Historical Context

- Earlier discussions mention an older **~3.5 GB limit** that has since been raised
- Roblox ran experiments "Increasing Server Memory Experiments" to dynamically scale memory
- P90 server memory usage in Creator Hub dashboards may increase (expected)

## What Counts as Server Memory

Server memory is consumed by:
- Instance tree (parts, meshes, models)
- Script code and runtime state
- Script heap (tables, closures, strings)
- Loaded textures and meshes (some categories)
- Physics simulation state
- Asset streaming cache
- Replication queues

## Managing Server Memory

### Monitoring Tools
- Creator Hub dashboard: P50/P90 memory usage metrics
- F9 Developer Console: Memory tab with per-category breakdown
- `game:GetService("Stats"):GetTotalMemoryUsageMb()` for programmatic access

### Reduction Strategies
- Move maps from ReplicatedStorage to ServerStorage (reduces client memory)
- Use Streaming Enabled for large worlds
- Clean up unused instances with `:Destroy()`
- Disconnect event connections properly
- Use `buffer` type instead of large tables for binary data
- Compress DataStore entries

## Developer Questions Around the Cap

Community members have asked about:
- Whether dynamic formula guarantees memory won't drop below 6.4 GB
- Cost implications for high memory usage
- Methods to view server RAM allocation
- Enhanced debugging tools for memory leak identification

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Server memory cap (base) | 6.4 GB |
| Scaling formula | 6.4 GB + 100 MB/player (peak) |
| 700-player server cap (2024) | 6.5 GB (down from 12.5 GB) |
| Older cap (historical) | ~3.5 GB |

## Source

Original URL: https://devforum.roblox.com/t/increasing-server-memory-experiments/3105354
Captured: 2026-04-16
