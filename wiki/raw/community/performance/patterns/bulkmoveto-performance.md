---
title: BulkMoveTo vs CFrame Performance
type: raw-source
source_url: https://devforum.roblox.com/t/bulkmoveto-vs-normal-cframe-ing/1278502
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: patterns
tags: [bulk-move-to, cframe, part-movement, performance]
---

# BulkMoveTo vs CFrame Performance

## Performance Threshold

**BulkMoveTo becomes faster than individual CFraming at approximately 30 parts.**

Testing shows crossover points:
- Some tests: 30 parts
- Others: 40-50 parts threshold
- Below 30 parts: individual CFrame assignments are competitive

## Benchmark Data

Results from 100,000 test runs:

| Method | Time (50 parts) |
|--------|-----------------|
| **BulkMoveTo** | 0.00000584 seconds |
| **Individual CFraming** | 0.00000640 seconds |

Only marginal gains at 50 parts (~9% difference). The difference grows with part count.

## Why BulkMoveTo Wins at Scale

The main benefit: "It is handled in C++, speeding up iterations quite a bit."

BulkMoveTo bypasses per-call Lua->C++ boundary overhead, batching all moves into one native call.

## Implementation

### Basic Usage
```lua
workspace:BulkMoveTo(
    parts,           -- {BasePart}
    cframes,         -- {CFrame}
    Enum.BulkMoveMode.FireCFrameChanged  -- event firing mode
)
```

### Bulk Move Modes
- `Enum.BulkMoveMode.FireCFrameChanged` - fires only CFrameChanged
- `Enum.BulkMoveMode.FireAllEvents` - fires all property events (slower)

Using `FireCFrameChanged` mode prevents unnecessary event firing and optimizes performance.

## When to Use

| Part Count | Recommendation |
|------------|----------------|
| 1-29 parts | Individual CFrame |
| 30+ parts | BulkMoveTo |
| 100+ parts | BulkMoveTo required |
| 1000+ parts | BulkMoveTo essential |

## Real-World Use Cases

- Physics simulated bone movement (e.g., cape with 30+ bones)
- Rain/snow particle simulation with many parts
- Tile-based terrain updates
- Skeletal animation on non-Humanoid rigs
- Debris field movement

## Extensions Requested

- `BulkPivotTo()` for PivotTo semantics (works on Models)
- `BulkTransformTo` for Motor6D/Bone Transform properties
- Such extensions could "enable processing at least 20% more bones for the same computation"

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Threshold for BulkMoveTo win | ~30 parts |
| Gain at 50 parts | ~9% |
| Time per 50 parts (BulkMoveTo) | 0.0000058 s |
| Time per 50 parts (individual) | 0.0000064 s |

## Source

Original URL: https://devforum.roblox.com/t/bulkmoveto-vs-normal-cframe-ing/1278502
Captured: 2026-04-16
