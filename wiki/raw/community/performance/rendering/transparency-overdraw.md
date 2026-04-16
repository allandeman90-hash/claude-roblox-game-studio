---
title: Transparency Overdraw and Invisible Parts Performance
type: raw-source
source_url: https://devforum.roblox.com/t/do-invisible-parts-boost-or-decrease-performance/1485308
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: rendering
tags: [transparency, overdraw, rendering, invisible-parts]
---

# Transparency Overdraw and Invisible Parts Performance

## Rendering Behavior

### Fully Transparent Parts (Transparency = 1)
- **Not rendered**: "Fully transparent parts do not go through rendering"
- Avoid rendering costs completely
- Does NOT significantly improve overall game performance (collision/physics still active)

### Semi-Transparent Parts (0 < Transparency < 1)
- Require **additional rendering pipeline processing** compared to opaque objects
- "Semi-transparent parts go through more rendering than usual which causes performance issues when used in great numbers"
- Process every visible transparent object regardless of overlap (unlike opaque which Z-buffer culls)

## Overdraw Cost

When semi-transparent surfaces overlap:
- Each layer must be rendered separately
- Back-to-front blending requires reading existing pixel + blending
- Cannot early-reject via depth test
- GPU does redundant work for areas hidden behind transparent layers

This is called "overdraw" and scales poorly:
- 10 overlapping transparent decals = 10x the fill-rate cost of 1 opaque part

## Collision Part Strategy

Using invisible parts for collision while disabling collisions on visible parts:
- Provides "gains on less intricate objects"
- But "nowhere near as much" as other optimization strategies
- Rarely worth the complexity

## Performance Recommendations

Rather than relying on invisible collision parts:
- Set complex shapes' `RenderFidelity` to "Automatic"
- Convert objects to MeshParts with **Box CollisionFidelity**
- Use transparent parts sparingly, especially semi-transparent
- Enable **StreamingEnabled** for large maps
- Remove unnecessary welds

## Transparency Performance Tiers

| Transparency | Render Cost | Recommendation |
|-------------|-------------|----------------|
| 0 (opaque) | Cheap | Preferred |
| 0.01-0.99 (semi) | Expensive | Minimize |
| 1 (fully invisible) | Free render | Collision-only parts OK |

## Key Takeaways

1. Invisible parts don't boost performance - they just avoid render cost
2. Semi-transparency is expensive due to overdraw
3. Avoid stacking transparent effects (particle emitters, decal layers)
4. Use opaque alternatives where visual effect permits
5. Consider LOD for transparent elements

## Source

Original URL: https://devforum.roblox.com/t/do-invisible-parts-boost-or-decrease-performance/1485308
Captured: 2026-04-16
