---
title: Create a Score Bar
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/ui/create-a-score-bar
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, ui, screengui, frame, imagelabel, textlabel, uilistlayout, uisizeconstraint, device-emulator]
difficulty: beginner
---

# Create a Score Bar

A **score bar** is a UI element that displays player information that is important for your experience's gameplay, such as their leveling up statistics, currency count, or power-up items in their inventory. By displaying score bars directly on the player's screen, you can keep their attention on what they need in order to accomplish various goals within your experience.

Using the Gold Rush `.rbxl` file as a reference, this tutorial shows you how to create a score bar that tracks the amount of gold players collect, including guidance on:

- Creating a frame in the top-center of the screen.
- Adding a crown icon that communicates what the score bar is tracking without any textual guidance.
- Inserting score text that records the amount of gold the player collects.
- Testing your UI design on multiple emulated devices to review its appearance on different screens and aspect ratios.

## Steps

### Create the frame

To display UI elements on every player's screen, you can create a `ScreenGui` object in the `StarterGui` service. `ScreenGui` objects are the primary containers for on-screen UI, and the `StarterGui` service copies its contents to each player's `PlayerGui` container as they enter an experience.

After you create a `ScreenGui` object, you can create and customize its child `GuiObjects` according to each container's purpose.

To recreate the frame container:

1. Create a `ScreenGui` object to contain your on-screen UI.
   1. In the **Explorer** window, hover over **StarterGui** and click the ⊕ icon.
   2. Insert a **ScreenGui**.
2. Create a container for the entire score bar UI component.
   1. Insert a **Frame** into the **ScreenGui** object.
   2. Select the new **Frame**, then in the **Properties** window:
      - Set **AnchorPoint** to `0.5, 0` to set the frame's origin point in the top-middle of itself.
      - Set **BackgroundColor** to `0.6` to make the frame's background black.
      - Set **BackgroundTransparency** to `0.6` to make the frame's background semi-transparent.
      - Set **Position** to `{0.5, 0},{0.01, 0}` (50% from the left, 1% from the top).
      - Set **Size** to `{0.25, 0},{0.08, 0}` (25% horizontally, 8% vertically).
      - Set **Name** to **ScoreBarFrame**.
3. Add a constraint to the frame so that its contents are always legible on small screen sizes.
   1. Insert a **UISizeConstraint** object into **ScoreBarFrame**.
   2. Select it and set **MinSize** to `0, 40` to ensure the frame never shrinks to less than 40 pixels vertically.
4. Add a layout object to the frame so that its contents arrange from left-to-right and vertically center within the frame's perimeter.
   1. Insert a **UIListLayout** object into **ScoreBarFrame**.
   2. Set **FillDirection** to **Horizontal**.
   3. Set **VerticalAlignment** to **Center**.

### Add an icon

An icon is a symbol that represents an action, object, or concept in an experience. Using icons that are simple and intuitive allows players to easily recognize what you're communicating with your UI without using text.

1. Insert an **ImageLabel** object into **ScoreBarFrame**.
2. Select the new label, then in the **Properties** window:
   - Set **Image** to `rbxassetid://5673786644` to make the icon a crown.
   - Set **BackgroundTransparency** to `1`.
   - Set **LayoutOrder** to `1`. This ensures the icon remains first in the frame from left-to-right.
   - Set **Size** to `{1.25,0},{1,0}`.
   - Set **SizeConstraint** to **RelativeYY** to preserve the icon's aspect ratio by scaling with the height of the parent frame.

### Insert score text

Score text records the player's score within an experience. It's important that all UI text is both clear and easy to read.

1. Insert a **TextLabel** object into **ScoreBarFrame**.
2. Select the new label, then in the **Properties** window:
   - Set **BackgroundTransparency** to `1`.
   - Set **Size** to `{1,0},{1,0}`.
   - Set **SizeConstraint** to **RelativeYY**.
   - Set **Font** to **GothamSSm**.
   - Set **Text** to `0` to start the score from zero.
   - Set **TextColor3** to `255, 200, 100` to tint the text gold.
   - Set **TextSize** to `30`.
   - Set **TextXAlignment** to **Left** to ensure the score text remains left-aligned near the crown icon regardless of score digits.

### Test the design

Studio's Device Emulator allows you to test how players will see and interact with your UI on various devices. This tool is a vital part of designing UI because the aspect ratio of your viewport in Studio doesn't necessarily reflect the aspect ratio of the screens players use to access your experience.

To emulate your UI on various screen sizes:

1. From Studio's **Test** menu, toggle on **Device Emulator**.
2. In the resolution dropdown, select **Actual Resolution**.
3. In the device dropdown, select at least one device within the **Phone**, **Tablet**, **Desktop**, and **Console** sections.

## Key Concepts

- **ScreenGui**: Primary container for on-screen UI, placed in StarterGui
- **StarterGui**: Service that copies its contents to each player's PlayerGui on join
- **Frame**: Container GuiObject for grouping child elements
- **ImageLabel**: Displays an image asset using `rbxassetid://`
- **TextLabel**: Displays styled text
- **AnchorPoint**: The origin point within a GuiObject (0-1 for X and Y)
- **Position/Size**: Use UDim2 `{scale, offset}` pairs for responsive sizing
- **UIListLayout**: Auto-arranges children horizontally or vertically
- **UISizeConstraint**: Enforces min/max pixel size regardless of scale
- **SizeConstraint RelativeYY**: Scales uniformly with parent's Y axis (preserves aspect ratio)
- **Device Emulator**: Tests UI across phone, tablet, desktop, console form factors

## Notes

- Always test UI on multiple aspect ratios
- Use `SizeConstraint = RelativeYY` to preserve icon aspect ratios
- `LayoutOrder` controls children ordering inside UIListLayout
- Prefer scale values (0-1) over offset pixels for responsive design

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/ui/create-a-score-bar
Captured: 2026-04-16
