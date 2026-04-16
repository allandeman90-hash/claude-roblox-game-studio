---
title: "UDim2 & AnchorPoint: Making Sense of Positioning UI on Roblox"
source_type: devforum-tutorial
url: https://devforum.roblox.com/t/udim2-anchorpoint-making-sense-of-positioning-ui-on-roblox-hint-youre-using-scale-wrong/2999646
captured: 2026-04-15
tags: [UDim2, AnchorPoint, positioning, responsive-ui, scale, offset]
---

# UDim2 and AnchorPoint Positioning Guide

## Core Principle
UI elements are positioned based on their AnchorPoint, not always from the top-left corner. The AnchorPoint determines which point within an element serves as the reference for positioning.

## Key Rule
"If your AnchorPoint or Scale isn't 0, 0.5, or 1, you're probably doing it wrong." Avoid imprecise values like 0.449 and automatic scale plugins that produce them.

## Practical Example: Center-Bottom Button with Padding
- **Position Scale**: (0.5, 1) -- centers horizontally, anchors to bottom
- **Position Offset**: (0, -16) -- applies 16-pixel upward padding
- **AnchorPoint**: (0.5, 1) -- anchors the element's center-bottom point

## Common AnchorPoint Values

| Placement      | AnchorPoint |
|----------------|-------------|
| Top-Left       | (0, 0)      |
| Top-Center     | (0.5, 0)    |
| Top-Right      | (1, 0)      |
| Center-Left    | (0, 0.5)    |
| Center         | (0.5, 0.5)  |
| Center-Right   | (1, 0.5)    |
| Bottom-Left    | (0, 1)      |
| Bottom-Center  | (0.5, 1)    |
| Bottom-Right   | (1, 1)      |

## Scale vs Offset Summary
- **Scale (0-1)**: Percentage of parent. Responsive across devices.
- **Offset (pixels)**: Fixed distance. Good for padding, bad for positioning.
- Best practice: Use Scale for positioning and sizing, Offset only for small fixed padding.
