---
title: Build a Hinged Door
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/build-a-hinged-door
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, physics, constraints, hingeconstraint, attachments, anchored]
difficulty: beginner
---

# Build a Hinged Door

Roblox's physics system allows you to construct moving mechanisms like doors, rotating platforms, and even vehicles using **constraints**. For instance, a swinging door can be built using the `HingeConstraint`.

## Steps

### Door setup

Start by creating parts for the door and its attachments. **Attachments** are where one object can connect to another. These attachments will later be used to connect the door to its frame with a hinge.

1. Create two parts with names like **Door** and **DoorFrame**.
2. Select **DoorFrame**. In the **Properties** window, enable **Anchored** so it won't move.
3. In the **Explorer**, hover over **DoorFrame** and add a new **Attachment**. Repeat the same to add an attachment to the **Door**.
4. Rename the attachments to indicate what they're attached to, such as **DoorAttachment** and **FrameAttachment**.

### Move the attachments

New attachments are created in the center of a part. So they can work with the door, the two attachments need to be moved to face each other.

1. To view constraints and attachments, toggle on **Show Constraint Details** from Studio's **View** menu.
2. In the **Explorer**, select **FrameAttachment**.
3. Press **F** to focus on the attachment and zoom in if needed. Then, use the **Move** tool to position the attachment on the surface of the door frame, facing the door.
4. Repeat the same to move **DoorAttachment**. Your attachments should be positioned on the surface facing their counterpart.

> It's best to position attachments so they're precisely aligned with one another. Misaligned attachments may cause the door to swing incorrectly. For precise positioning, use **Snap to Grid** with increments appropriate for the size of the part.

### Rotate the attachments

The orientation of an attachment affects how a constraint can move. For the door, both attachments must be rotated so the hinge swings left and right.

1. On the door frame, hover over **FrameAttachment**. Notice the **yellow arrow**. This arrow, the **axis**, determines the hinge's rotation.
2. For accurate rotation, turn on rotation snapping in Studio's toolbar by checking **Rotate** and setting the value to `90`.
3. Use the **Rotate** tool to orient **both** yellow attachments to point **upwards**.

### Add the constraint

Constraints are a way of connecting two attachments to move in a specific way. This door will use a `HingeConstraint`, a common constraint that rotates objects along the axes of two attachments.

1. Under **DoorFrame**, create a new **HingeConstraint**.
2. In the constraint's properties, find **Attachment0**. Click the empty box and then, in the **Explorer**, click **DoorAttachment**.
3. Repeat the same process by connecting **Attachment1** to **FrameAttachment**.
4. Test the project by walking into the door with your character.

> **Warning — Troubleshooting:**
> - **Parts not moving:** Make sure your door is not anchored. Make sure the door's motion isn't blocked by terrain or nearby parts.
> - **Door not swinging as expected:** Ensure the axis of each attachment is pointed up.

### Adjust the door

The door is currently able to swing past the door frame. This can be fixed by adjusting the hinge **limits**.

1. In the properties for **HingeConstraint**, find and toggle **LimitsEnabled**.
2. To make sure this is oriented correctly, select **DoorAttachment** and use the rotate tool so the orange arrow points **towards** the door frame.
3. Under the **Limits** section of the properties, set both **LowerAngle** and **UpperAngle** to -90 and 90, respectively.
4. Test the door and notice that the hinge is now limited.

> Remember that the yellow axis arrows affect the pivot of the hinge. Limits are affected by the orange axis arrows.

## Key Concepts

- **Constraints**: Physics objects that restrict how parts can move relative to each other
- **HingeConstraint**: Rotates one part around the shared axis of two attachments
- **Attachment**: A point on a part that can be used as a constraint endpoint
- **Attachment0 / Attachment1**: The two attachments a constraint connects
- **Yellow axis arrow**: The pivot axis of the hinge
- **Orange axis arrow**: The reference axis for measuring rotation limits
- **LimitsEnabled + LowerAngle / UpperAngle**: Restrict the hinge's rotation range
- **Anchored parts**: Won't move; the frame should be anchored, the door should NOT be
- **Snap to Grid / rotation snapping**: Essential for precise attachment positioning

## Notes

- The frame must be anchored; the door must NOT be anchored
- Both attachments' yellow arrows must point up for a vertical hinge
- The orange arrow must point toward the frame for limits to work correctly
- Door swinging wrong typically means incorrect attachment axis orientation
- HingeConstraint can also be used for trap doors, swinging axes, rotating platforms

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/build-a-hinged-door
Captured: 2026-04-16
