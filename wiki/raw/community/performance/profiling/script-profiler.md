---
title: ScriptProfiler - Sampling Profiler for Scripts
type: raw-source
source_url: https://devforum.roblox.com/t/scriptprofiler-full-release/2025360
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: profiling
tags: [script-profiler, profiling, cpu, debug-profilebegin, sampling]
---

# ScriptProfiler - Sampling Profiler for Scripts

## Overview

ScriptProfiler is a sampling profiler that records call stacks of executing scripts at **1000 samples per second (1 kHz)**. It helps identify performance bottlenecks and scripts consuming the most CPU resources.

## Availability

- Released as Studio beta: October 2022
- Full release: November 30, 2022
- Now available in both Studio and the Roblox Client

## How to Enable

In Studio:
1. Navigate to **File -> Beta Features**
2. Select "Script Profiler"
3. Click Save and restart Studio

Access through the Developer Console (F9) as a tab.

## Core Features

### Data Organization
Organized by top-level categories including:
- Parallel execution phases
- Delayed/deferred threads
- Event-triggered sections (e.g., RenderStepped)

### Display Options
- Default view: CPU time in milliseconds
- Toggle via **Unit** button to display as percentages of total recording session

### Manual Profiling Regions

Use `debug.profilebegin()` and `debug.profileend()` to mark custom profiling sections that appear in both ScriptProfiler and MicroProfiler:

```lua
local function expensiveOperation()
    debug.profilebegin("MyExpensiveFunction")
    -- ... code to profile ...
    debug.profileend()
end
```

### Dual-Environment Support
Simultaneous client and server profiling available by switching between Client/Server tabs.

### Hover Information
Hovering over call tree nodes displays file and line information for specific functions.

## Limitations

- Standard library calls and primitive type operations (CFrame, etc.) are attributed to calling functions
- Sampling noise affects functions with minimal CPU contribution
- Sleeping/waiting threads don't consume measurable CPU resources
- Native functions display `<native>` annotation

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Sampling frequency | 1000 Hz (1 kHz) |

## Source

Original URL: https://devforum.roblox.com/t/scriptprofiler-full-release/2025360
Captured: 2026-04-16
