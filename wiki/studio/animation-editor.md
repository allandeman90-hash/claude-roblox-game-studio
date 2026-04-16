---
title: Animation Editor
type: studio
category: studio
subcategory: animation
owner: roblox-studio-specialist
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/studio-features/animation-editor-official.md
related:
  - "[[plugin-development]]"
tags: [studio, animation, keyframe, rig, easing, editor]
---

# Animation Editor

> Built-in Studio tool for creating keyframe-based animations on rigs (characters, creatures, mechanical objects).

## Summary

The Animation Editor is a visual timeline tool that allows developers to pose rig joints at specific frames and let the engine interpolate between them. It supports inverse kinematics (IK), multiple easing styles, animation priority levels, keyframe optimization, and export to Roblox's animation system for runtime playback via `Animator` and `AnimationTrack`.

## Opening the Editor

**Avatar tab > Animation** or **Window > Avatar**. Select a rig in the viewport, enter an animation name, and click **Create**.

A rig is any object hierarchy with joints (Motor6D, bones, or mesh deformation). Use the **Rig Generator** tool (Avatar tab) to create pre-built character rigs.

## Interface

| Section | Purpose |
|---------|---------|
| Media Controls | Play, pause, reverse, loop toggle, frame position (seconds:frames) |
| Timeline | Scrubber bar, time unit markers, keyframe diamonds, expand/contract |
| Track List | Per-part tracks with position/rotation values, Add/Delete track options |
| File Menu | Load, Save, Save As, Import, Export, Create New, Set Animation Priority |

Default timeline: 1 second (30 frames at 30 FPS). The final keyframe determines the actual animation duration.

## Creating Animations

### Building Poses

1. Position the scrubber at the desired frame.
2. Select bones or mesh parts in the viewport (or click the + icon to add all tracks).
3. Move or rotate parts (press **R** to toggle Move/Rotate modes).
4. A keyframe diamond appears automatically on the track.
5. Move scrubber to a new frame, adjust again.
6. Press **Space** or click Play to preview interpolation between poses.

### Keyframe Operations

| Operation | How |
|-----------|-----|
| Add (single part) | Track > ... > Add Keyframe |
| Add (all parts) | Right-click dark region above tracks > Add Keyframe Here |
| Move | Drag gray diamond (single) or white diamond (group) |
| Duplicate | Select, Ctrl+C, move scrubber, Ctrl+V |
| Delete | Select, press Delete |

### Keyframe Optimization

**Automatic:** Removes intermediary keyframes when 3+ consecutive share identical values; eliminates tracks containing only default values.

**Manual:** ... > Optimize Keyframes. Slider adjusts keyframe count while previewing the result.

## Easing

### Styles

| Style | Behavior |
|-------|----------|
| Linear | Constant speed between keyframes |
| Constant | No interpolation; snaps instantly |
| Cubic | Smooth acceleration/deceleration |
| Elastic | Rubber-band overshoot |
| Bounce | Bouncy landing effect |

### Directions

| Direction | Effect |
|-----------|--------|
| In | Slower start, faster end |
| Out | Faster start, slower end |
| InOut | In at start, Out at midpoint |

Apply by right-clicking a keyframe > Easing Style / Easing Direction.

## Animation Priority

`Enum.AnimationPriority` determines which animation wins when multiple play simultaneously. Highest to lowest:

1. Action4
2. Action3
3. Action2
4. Action
5. Movement
6. Idle
7. Core

Set via ... > **Set Animation Priority**. Higher-priority animations override lower-priority ones on the same tracks.

## Looping

Click the **Looping** toggle in playback controls. For smooth loops, duplicate the first keyframes as the final keyframes (the editor does not auto-interpolate back to the start).

## Saving and Exporting

### Saving Locally

Animations save as `KeyframeSequence` objects under `ServerStorage` with a rig reference. Access via:

```lua
local myAnim = myRig.AnimSaves.Value.myAnimation
```

Move to `ReplicatedStorage` if client access is needed.

### Publishing to Roblox

1. For default character animations, rename the final keyframe to **"End"** (case-sensitive).
2. ... > **Publish to Roblox**.
3. Complete Asset Configuration (name, description, creator).
4. Submit.

Retrieve the animation ID from Toolbox > Creations > Animations > right-click > Copy Asset ID. Use this ID with `Animator:LoadAnimation()` at runtime.

## Pitfalls

- The editor operates at 30 FPS by default; change via Timeline Options > Frame Rate.
- Local KeyframeSequence data does not replicate to clients; move to ReplicatedStorage if needed.
- IK constraints require proper rig setup; incorrect joint hierarchies produce unexpected results.
- Animation optimization can remove keyframes that look redundant but are intentionally placed for timing control.
- Legacy animations stored directly in rigs should be migrated using the built-in migration tool.

## Related

- [[plugin-development]] -- Custom animation tools can be built as plugins.

## Sources

- [Roblox Creator Docs: Animation Editor](wiki/raw/community/articles/studio-features/animation-editor-official.md)
- [Roblox Creator Docs: Use Animations](https://create.roblox.com/docs/animation/using)
- [Roblox Creator Docs: Create an Animation tutorial](https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/create-an-animation)
