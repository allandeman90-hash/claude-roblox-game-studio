---
title: "Simplest Way To Make Your GUI Fit To All Devices"
source_type: devforum-tutorial
url: https://devforum.roblox.com/t/simplest-way-to-make-your-gui-fit-to-all-devices/1413727
captured: 2026-04-15
tags: [responsive-ui, scale, offset, UIAspectRatioConstraint, mobile, cross-device]
---

# Responsive GUI Design for All Devices

## Scale vs Offset

- **Scale**: Proportional to screen dimensions (0-1 range, like percentages). A Y Scale of 0.333 positions elements at one-third screen height.
- **Offset**: Fixed pixel values that remain constant regardless of resolution.

Combining both creates responsive layouts that work on mobile and desktop.

## Three-Step Process (Using AutoScale Lite Plugin)

**Step 1: Configure the Base Frame**
Set the AnchorPoint property to 0.5, 0.5 on your ScreenGui and contained elements. This centers the component.

**Step 2: Apply Scaling**
Convert both position and size to relative (scale-based) measurements rather than fixed pixels.

**Step 3: Preserve Aspect Ratio (Optional)**
Apply UIAspectRatioConstraint. This maintains proportions across devices. For example, a 2:1 ratio element becomes 131x65 pixels on iPhone instead of distorting to 131x90.

## Common Challenges
Users reported positioning inconsistencies on mobile despite proper scaling. Solutions included using offset values for consistent gaps between elements rather than relying entirely on scale-based positioning.

## Best Practices
- Use Scale for sizes and positions (responsive)
- Use Offset for consistent padding/margins (predictable gaps)
- Add UIAspectRatioConstraint for elements that must not distort
- Test on multiple device emulators in Studio
