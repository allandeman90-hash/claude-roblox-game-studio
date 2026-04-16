---
title: Build a Ferris Wheel
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/build-a-ferris-wheel
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, physics, hingeconstraint, motor, constraints, actuator, radians]
difficulty: beginner
---

# Build a Ferris Wheel

Many contraptions in Roblox will use multiple constraints to build more complicated mechanisms. In particular, you can configure several constraints to be **actuated**, meaning they will move under their own power. This tutorial will show you how to actuate a `HingeConstraint` to be a **motor** in order to make a ferris wheel.

## Steps

### Ferris wheel setup

1. Add a ferris wheel into a place using the pre-built [FerrisWheel](https://www.roblox.com/library/6448931648/FerrisWheel) model.
2. To view constraints and attachments, toggle on **Show Constraint Details** from Studio's **View** menu.

### Add attachments

You will need to add attachments to the ferris wheel to determine where it will rotate.

1. Expand **FerrisWheel**, select the **MainSupport** model, and move it so you can see the side of the wheel axle as well as the side of the support axle.
2. Expand MainSupport and select **SupportAxle**. Insert an attachment and rename it **SupportAttachment**.
3. Move **SupportAttachment** so that it is on the inside edge of the **SupportAxle**.
4. In the FerrisWheel, select **WheelAxle** and add a new attachment named **WheelAttachment**.
5. Move the **WheelAttachment** to the edge of the axle. Make sure this is the side facing the support where you placed the **SupportAttachment**.
6. Hover over the attachments to see yellow and orange arrows. Make sure the yellow arrows for both attachments are pointing in the same direction. If they aren't, use the **Rotate** tool to align them.

### Create a HingeConstraint

1. In the SupportAxle, create a new **HingeConstraint** and name it **MainMotor**.
2. In the properties of **MainMotor**, set `Attachment0` to `SupportAttachment`, and `Attachment1` to `WheelAttachment`.
3. Select the **MainSupport** model and return it to its original position.

### Change to motor

By default, `HingeConstraints` will only turn if an outside force acts on them. To make a `HingeConstraint` turn on its own, we have to configure it to be a **Motor**, set our desired turn rate, and make sure the hinge has enough torque.

1. Select **MainMotor** and, in the properties, change **ActuatorType** to **Motor**.
2. Change **AngularVelocity** to `0.314`.

> The **AngularVelocity** property uses **radians per second** to set how fast its motor turns. Most radian values are based on pi (~3.14):
> - 1 revolution per second = 2 × pi = 6.28
> - ½ revolution per second = pi = 3.14
> - ¼ revolution per second = pi / 2 = 1.57
> - 1/10 revolution per second = pi / 10 = 0.314

3. Copy the `inf` value from **MotorMaxAcceleration** to **MotorMaxTorque** so that the wheel can handle any amount of weight.
4. Initiate a playtest to test your wheel turning behavior.

Notice that you only need the motor on one side of the wheel; you do not need motors on both sides. When building with contraptions, try using as few constraints as possible.

## Key Concepts

- **HingeConstraint with ActuatorType = Motor**: Turns under its own power
- **AngularVelocity**: Rotation speed in radians per second
- **MotorMaxTorque**: Max torque the motor can apply (use `inf` for any weight)
- **MotorMaxAcceleration**: Max acceleration the motor can reach
- **Radians per second**: 2π (~6.28) = 1 revolution per second
- **One motor per mechanism**: Fewer constraints = more stability

## Notes

- Ensure attachment yellow arrows both point the same way
- Use `inf` for MotorMaxTorque to handle any weight
- Only need ONE motor on ONE side of the wheel
- For precise speed: use pi-based values (pi/10 for 1/10 rev/sec)

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/physics/build-a-ferris-wheel
Captured: 2026-04-16
