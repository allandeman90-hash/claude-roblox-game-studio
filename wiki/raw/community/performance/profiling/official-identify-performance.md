---
title: Official Roblox - Identifying Performance Issues
type: raw-source
source_url: https://create.roblox.com/docs/performance-optimization/identify
source_type: official-docs
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: profiling
tags: [official-docs, frame-rate, memory, profiling, diagnostic-tools]
---

# Official Roblox - Identifying Performance Issues

## Three Core Performance Categories

Developers should focus on:
1. **Frame rate (compute)**
2. **Memory**
3. **Load time**

## FPS Targets

| Metric | Value |
|--------|-------|
| Server heartbeat | **Capped at 60 FPS** (lower = problem) |
| Client frame rate default cap | 60 FPS |
| Windows users max | 240 FPS |
| Frame threshold | **16.67 ms max** per frame |

## Memory Targets

| Metric | Value |
|--------|-------|
| Server memory budget | **<50% of total capacity** |
| Server memory formula | **6.25 GiB + (100 MiB * max_connected_players)** |
| Example: 30-player server | ~9.18 GiB total allocation |
| Client crash threshold | Investigate if crash rate > 2-3% |

## Key Diagnostic Tools

| Tool | Access | Shortcut |
|------|--------|----------|
| Developer Console | Studio/in-game | **F9** |
| MicroProfiler | Studio/in-game | **Ctrl+Alt+F6** |
| Performance Stats bar | In-game | **Ctrl+Alt+F7** |
| Debug Stats | Studio/in-game | **Shift+Ctrl+F1-F5** |
| Performance Dashboard | Creator Dashboard | N/A |

## Ping Measurements

- **Network ping**: Round-trip time for echo packets; primarily network-dependent
- **Data ping**: "Round-trip time measured from when the client sends data reliably through the replication system"
- Data ping >= network ping due to queueing and retransmissions

## Measurements / Numbers

Critical budget summary:

| Budget | Value |
|--------|-------|
| Frame time | 16.67 ms (60 FPS) |
| Server heartbeat | 60 Hz |
| Server memory formula | 6.25 GiB + 100 MiB/player |
| Client crash alarm | >2-3% |

## Source

Original URL: https://create.roblox.com/docs/performance-optimization/identify
Captured: 2026-04-16
