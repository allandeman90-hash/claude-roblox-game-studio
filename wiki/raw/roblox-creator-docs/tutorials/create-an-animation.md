---
title: Create Character Animations
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/create-an-animation
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, animation, rig, keyframes, animation-editor, walk-cycle, publishing]
difficulty: intermediate
---

# Create Character Animations

**Character animations** include a series of key poses that programmatically flow together to make your characters appear as if they're moving in their environment.

This tutorial shows you how to create a walk cycle character animation from start to finish, including:
- Adding a pre-built character rig to the 3D space
- Breaking down a reference image to guide your animation decisions
- Looping the animation to test how it looks at different speeds, angles, and easing styles
- Publishing the animation to get a reusable asset ID

## Steps

### Add rig

**Rigs**, or collections of parts connected by joints like `Bone` or `Motor6D` objects, are necessary to create character animations because they include the internal structure you need to move and rotate body parts into different poses. Studio provides several pre-built rigs through the Rig Generator tool.

To add a pre-built rig:
1. From the toolbar's **Home** or **Avatar** tab, click **Character**.
2. Select a rig type (e.g., **R15**), body shape (e.g., **masculine**), and avatar option (e.g., **Rthro Avatar**).
3. The rig displays in the viewport.

### Pose rig

Every animation is made up of a sequence of key poses at different frames. Studio programmatically **interpolates** (tweens or inbetweens) the in-between frames to create smooth movement.

Walk cycles for humanoid characters typically have **4 key poses** that repeat for each foot's step:

- **Contact** — One foot touches the ground in front, the other is about to lift off behind. Both feet support the character's weight.
- **Low** — The front foot fully supports the character's weight, and the back leg lifts off the ground.
- **Passing** — The back leg passes the front leg, weight begins shifting from one foot to the other.
- **High** — The character lifts their body up onto the newly back foot; the newly front foot is about to touch the ground.

### Left step pose sequence

The first course of action for a walk cycle is to create the four key poses for the left step:

1. **Contact pose** (frame 0):
   - Open the Animation Editor from the **Avatar** tab.
   - Input an animation name and click Create.
   - Optionally set the timeline to 24 fps.
   - Click the **+** button → Add All Body, then right-click the top bar → Add Keyframe.
   - Rotate UpperTorso slightly forward; rotate Head to look forward.
   - Pose left leg bent with foot slightly raised; right leg bent with toes skimming ground.
   - Pose left arm behind body, right arm in front.
   - Save the animation.

2. **Low pose** (frame 3):
   - Drag scrubber to 3rd frame.
   - Rotate UpperTorso significantly forward; rotate Head toward ground.
   - Pose left leg bent at ~90° with foot flat; right leg straight behind with foot angled up.
   - Move LowerTorso down until left foot is on ground.
   - Bring both arms closer to waist.
   - Save.

3. **Passing pose** (frame 6):
   - Drag scrubber to 6th frame.
   - Pose UpperTorso ~90° with ground; Head looking forward.
   - Left leg nearly straight with foot flat; right leg bent 45° with toe angled down.
   - Move LowerTorso up to ground level.
   - Arms straight on either side of waist.
   - Save.

4. **High pose** (frame 9):
   - Drag scrubber to 9th frame.
   - Angle UpperTorso slightly backward; Head toward sky.
   - Left leg nearly straight with foot perpendicular to ground; right leg bent ~90° in front.
   - Move LowerTorso slightly up until toes touch ground.
   - Swing arms further from waist.
   - Save.

### Right step pose sequence

Repeat the four-pose process for the right step at frames 12, 15, 18, and 21, mirroring the left step positions.

### Test animation

1. Click the looping button in the playback tools to repeat indefinitely.
2. Click play to start.
3. Review and adjust:
   - Slow playback (0.25x or 0.5x) via the gear icon.
   - Use View Selector to evaluate from multiple angles.
   - Adjust until animation matches personality.

### Publish animation

To play the animation outside the local place file:

1. In the upper-left corner of the Animation Editor, click the ellipsis button.
2. Select **Publish to Roblox**.
3. Fill out all applicable fields and click **Save**.
4. Copy the asset ID for use in scripts.

## Key Concepts

- **Rig**: Collection of parts connected by Bone/Motor6D joints
- **Animation Editor**: Studio's built-in keyframe animation tool
- **Keyframe**: A snapshot of body part positions at a specific frame
- **Interpolation (tweening)**: Studio automatically fills frames between keyframes
- **Walk cycle 4 poses**: Contact → Low → Passing → High
- **Frame rate**: Commonly 24 fps for character animation
- **Publish to Roblox**: Uploads the animation and returns an asset ID
- **`rbxassetid://`**: URI format for the published asset ID

## Notes

- Saving is NOT publishing — saving only stores locally; publishing uploads to the cloud
- Every character has a specific personality that influences animation style
- Exaggerate poses on energetic characters; keep subtle on reserved ones
- View animations from multiple angles before publishing
- Use 24 fps timeline for smoother playback
- Find published animations in **Creator Dashboard → Development Items → Animations**

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/create-an-animation
Captured: 2026-04-16
