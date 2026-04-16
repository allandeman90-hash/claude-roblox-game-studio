---
title: "RFC: Vector Library"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/vector-library.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, vector, math]
---

# RFC: Vector Library

## Motivation

Currently, individual runtimes implement their own vector libraries inconsistently.

> "In cross-runtime code, this results in performance drawbacks & difficulty utilizing native vectors."

A standardized library resolves these compatibility issues.

## Core API

**Construction:**
- `vector.create(x, y, z)` — Creates 3D vectors (w=0 in 4-wide mode)
- `vector.create(x, y, z, w)` — Available in 4-wide mode only

**Mathematical Operations:**
- `vector.magnitude(vec)` — Vector length
- `vector.normalize(vec)` — Unit vector
- `vector.cross(vec1, vec2)` — 3D cross product
- `vector.dot(vec1, vec2)` — Dot product (uses all components)
- `vector.angle(vec1, vec2, axis?)` — Angle between vectors in radians

**Component-wise Functions:**
- `vector.floor()`, `vector.ceil()`, `vector.abs()`, `vector.sign()`
- `vector.clamp(vec, min, max)`
- `vector.max(...)`, `vector.min(...)`

**Constants:**
- `vector.zero` — (0,0,0,0?)
- `vector.one` — (1,1,1,1?)

## Configuration Modes

- **Default**: 3-component vectors (xyz)
- **4-wide mode**: 4-component vectors (xyzw) via `LUA_VECTOR_SIZE=4`

4-wide functions ignore the w component for operations like cross product and angle calculations.

## Type System

A new primitive `vector` type is added to Luau's type checker.

## Design Considerations

The proposal recommends setting the vector library as the default metatable, enabling ergonomic method calls like `vec:magnitude()`.

## Drawbacks

- Creates a global `vector` variable, conflicting with common naming conventions
- Introduces additional fastcall slots for performance-critical code
- Requires developer migration to gain improvements

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/vector-library.md
- Captured: 2026-04-16
