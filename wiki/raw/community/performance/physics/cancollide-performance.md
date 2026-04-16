---
title: CanCollide Performance Impact
type: raw-source
source_url: https://devforum.roblox.com/t/does-cancollide-off-help-with-fixing-up-lag/168707
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: physics
tags: [physics, cancollide, collisions, anchored, performance]
---

# CanCollide Performance Impact

## Key Findings

Setting CanCollide to off provides a measurable performance improvement. Empirical testing shows disabling collisions reduced physics step time by approximately **22-30%** compared to enabled collisions.

## Specific Benchmark Results

Test conducted with **1,513 anchored parts**:

| Configuration | Step Time | Reduction |
|--------------|-----------|-----------|
| No collisions, with intersecting parts | 0.0129 ms | -30.27% |
| With collisions, with intersecting parts | 0.0185 ms | baseline |
| No collisions, no intersecting parts | 0.0152 ms | -22.84% |
| With collisions, no intersecting parts | 0.0197 ms | baseline |

## When It Actually Helps

The performance benefit primarily applies "if the region that the part is in is interactive." Disabling collisions in active gameplay areas yields meaningful optimization, but the effect may be negligible in non-interactive zones.

## Important Clarifications

- Disabling CanCollide removes a small computational cost per part
- It doesn't directly "fix lag" but eliminates a contributor to physics processing overhead
- The numerical differences are small per-part but compound with thousands of parts
- `.Touched` listeners still contribute overhead even when `CanCollide = false`

## Anchored vs Unanchored

- **Anchored = true**: Part is removed from dynamic physics simulation; minimal cost
- **Anchored = false + CanCollide = false**: Still in simulation, but collision checks skipped
- **Anchored = false + CanCollide = true**: Full physics + collision simulation

## Recommendations

1. Anchor every static part in your game; don't leave decorative props unanchored
2. Disable CanCollide on purely decorative parts that don't need collision
3. Disable CanCollide on interactive regions where collision overhead compounds
4. For 100K+ parts, Streaming is the correct solution, not just CanCollide

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| CanCollide off performance gain | 22-30% |
| Test part count | 1,513 anchored parts |
| Step time with collisions | 0.0185-0.0197 ms |
| Step time without collisions | 0.0129-0.0152 ms |

## Source

Original URL: https://devforum.roblox.com/t/does-cancollide-off-help-with-fixing-up-lag/168707
Captured: 2026-04-16
