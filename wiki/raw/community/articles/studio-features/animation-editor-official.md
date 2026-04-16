---
title: "Animation Editor — Roblox Creator Documentation"
type: raw-source
source_url: https://create.roblox.com/docs/animation/editor
source_type: official-docs
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: studio-features
tags: [animation, editor, keyframe, rig, easing, IK]
---

# Roblox Animation Editor

## Accessing the Editor

Open via Studio's Avatar tab or Window > Avatar menu. Enables custom animations for rigs (objects with sections connected by joints).

## Interface Components

### Media and Playback Controls
- Animation name field
- File menu: Load, Save, Save As, Import, Export, Create New, Set Animation Priority
- Navigation: first/previous/next/last keyframe buttons
- Playback: preview reverse, pause, preview forward
- Loop toggle
- Position indicator: seconds:frames format

### Timeline
- Scrubber bar marking current frame
- Time units for precise positioning
- Options: Timeline Unit, Frame Rate (30fps default), Animation Events, Snap To Keys
- Expand/contract controls

### Track List
- Rig name display
- Manage IK button
- Add tracks menu
- Individual part tracks: name, position, rotation
- Track options: Add Keyframe, Delete Track

## Creating Animations

### Prerequisites
Require a rig — use the Rig Generator tool for pre-built rigs.

### Steps
1. Avatar > Animation from toolbar
2. Select target rig
3. Enter animation name
4. Click Create

### Building Poses
Poses = specific position/orientation of bones or mesh parts. Multiple poses at different timeline positions = smooth interpolation.

1. Expand rig in Explorer to access bones/meshes
2. Position scrubber at desired frame (seconds:frames at 30fps)
3. Select bones/meshes in viewport (or + icon to add all)
4. Move/rotate parts (R key toggles Move/Rotate)
5. Preview with Play or Spacebar

Default duration: 1 second (30 frames); final keyframe determines actual duration.

## Keyframe Management

### Adding
- Single part: Track list > ... > Add Keyframe
- Multiple: Right-click dark region above tracks > Add Keyframe Here
- Auto-created when adjusting positions/rotations

### Moving
- Single: select gray keyframe, drag
- Multiple: select white keyframe in dark region, drag set

### Duplicating
Select, Ctrl+C, move scrubber, Ctrl+V

### Deleting
Select, press Delete or Backspace

### Optimization
**Automatic:** Removes intermediary keyframes when 3+ consecutive share identical values; eliminates tracks with only default values.
**On-demand:** ... > Optimize Keyframes, use slider to adjust count while previewing.

## Easing Settings

### Styles
- Linear: constant speed
- Constant: no interpolation, snaps between frames
- Cubic: smooth cubic interpolation
- Elastic: rubber band motion
- Bounce: bouncy start/end

### Directions
- Out: faster beginning, slower ending
- InOut: In at start, Out at midpoint
- In: slower beginning, faster ending

Apply: Select keyframe(s), right-click, Easing Style/Direction.

## Animation Properties

### Looping
Click Looping button. Duplicate first keyframes as final keyframes for smooth loops.

### Priority (Enum.AnimationPriority, highest to lowest)
1. Action4
2. Action3
3. Action2
4. Action
5. Movement
6. Idle
7. Core

Set via ... > Set Animation Priority.

## Saving
Animations save as KeyframeSequence in ServerStorage with rig reference.
Access: `local myAnim = myRig.AnimSaves.Value.myAnimation`
Move to ReplicatedStorage for client access.

## Exporting / Publishing
1. Rename final keyframe to "End" (case-sensitive) for default character animations
2. ... > Publish to Roblox
3. Complete Asset Configuration
4. Submit

Access via Toolbox > Creations > Animations. Right-click > Copy Asset ID.
