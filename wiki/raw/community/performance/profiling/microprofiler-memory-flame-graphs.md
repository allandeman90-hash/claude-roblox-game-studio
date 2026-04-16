---
title: MicroProfiler Memory Profiling, Flame Graphs, and Diffs
type: raw-source
source_url: https://devforum.roblox.com/t/microprofiler-memory-profiling-flame-graphs-diffs-and-much-more/3226801
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: profiling
tags: [microprofiler, memory-profiling, flame-graphs, profiling-tools]
---

# MicroProfiler Memory Profiling, Flame Graphs, and Diffs

New MicroProfiler features that add memory profiling, flame graphs, and dump diff comparison.

## Enabling MicroProfiler

- **Location**: Main Menu -> Settings -> Micro Profiler -> On
- **Keyboard Shortcut**: `Ctrl+F6` (Windows/Mac)
- **Modes**: Real-time overlay or browser dump (32-512 frames)

## X-Ray Mode (Memory Profiling)

**Activation**: Press `X` key or select X-Ray -> Main View

### Features
- Gray overlay shows memory allocation intensity across frames
- Upper bar: overall frame allocation intensity
- Lower bar: allocation intensity within specific frame sections
- Displays allocation count or total size (toggle with `C` key)

### Customization Options
- Mode toggle: "#Count" vs "sum Sum" (allocation count vs. bytes)
- Events filter: allocations only, deallocations only, or both
- Sensitivity adjustment: Shift + scroll wheel, or X-Ray -> Thresholds (0-99 range)

## Summary FlameGraphs

### CPU Flamegraph
- Aggregates all call stacks across threads and frames
- Color corresponds to detailed view colors
- Interactive zoom and search functionality
- Top Down/Bottom Up view toggle
- Displays: total CPU time, percentage of root, average time per entry

### Memory Flamegraph
- Shows allocation count or total size in bytes
- Same interface as CPU version
- "Per 1 frame" averaging displayed

**Access**: Export -> CPU Flamegraph or Memory Flamegraph

## Diff FlameGraphs

**Comparison Method**: Drag-and-drop HTML files or use Export -> Diff/Combine

### Visual Indicators
- **Green**: left/first dump uses more resources
- **Blue**: right/second dump uses more resources
- **Brightness**: indicates magnitude of difference

### Comparison Modes
- Relative: percentage-based sensitivity range
- Absolute: milliseconds (CPU) or bytes (memory)

### Combo Feature
Combine multiple dumps from same side for averaged metrics.

**Compatibility**: Dumps from approximately July 2024 onward.

## Search & Navigation

### Keyboard Shortcuts
- `Ctrl+F` (Windows) / `Cmd+F` (Mac): Search by scope name
- `F3` or `Cmd+G` (Mac): Find next instance
- Left/Right arrows: Navigate between instances within thread
- `Esc`: Close search box

### Additional Navigation
- Reference frame time adjustment: Hover over frame bars and scroll wheel
- Search bar in Flamegraph views (upper right)

## Frame Performance Categories

### Color-Coded Classifications
- **Orange**: CPU-heavy (optimize scripts, physics, object count)
- **Red**: GPU-heavy (reduce texture size, visual effects, render complexity)
- **Blue**: Render-heavy (check object movement, light changes, render count)

### Tooltip Metrics
- Render Wall Time
- GPU Wait Time
- Jobs Wall Time
- GPU time (mp and dev variants)

## Mobile Profiling

- **Access**: `IP:port` in browser (example: `192.168.1.1:1338`)
- **Frame Count Specification**: `IP:port/number_of_frames` (example: `192.168.1.1:1338/64`)

## Additional Features

- **Re-capture Button**: Fresh capture without browser cache issues
- **Save to File Button**: Preserves full filename with timestamp
- **Scope Information Displayed**: Timer Index and group category (e.g., Render, Physics)

## Measurements / Numbers

| Setting | Value |
|---------|-------|
| Dump frame range | 32-512 frames |
| Mobile default port | 1338 |
| Sensitivity range | 0-99 |
| Dump diff compatibility | July 2024+ |

## Source

Original URL: https://devforum.roblox.com/t/microprofiler-memory-profiling-flame-graphs-diffs-and-much-more/3226801
Captured: 2026-04-16
