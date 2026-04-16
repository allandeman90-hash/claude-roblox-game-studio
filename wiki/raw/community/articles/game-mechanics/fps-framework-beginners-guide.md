---
title: "Designing an FPS Framework: Beginner's Guide"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/designing-an-fps-framework-beginners-guide/1198208
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [fps-framework, beginner, viewmodel, module-scripts, projectile]
---

# Designing an FPS Framework: Beginner's Guide

Non-OOP, module-script-based FPS framework tutorial for beginners.

## Architecture

- LocalScript handler in StarterPlayerScripts
- Centralized MainModule in ReplicatedStorage
- Event-driven updates via RenderStepped

## Module Functions

- module.update(viewmodel, dt) -- syncs viewmodel to camera each frame
- module.weldgun(gun) -- creates Motor6D connections between gun parts
- module.equip(viewmodel, gun, hold) -- parents gun, plays holding animation
- module.cast(gun, endposition, velocity) -- spawns and trajectories projectiles

## Viewmodel Requirements

- CameraBone part
- Motor6D: HumanoidRootPart to CameraBone
- AnimationController (replaces Humanoid)
- Motor6D named Handle: Part0=HumanoidRootPart, Part1=nil (set on equip)

## Weapon Config

- GunComponents folder: Barrel, Handle, Sight
- Handle as primary weld anchor
- All parts Motor6D relative to Handle

## Projectile System

- Creates anchored Part at barrel position
- CFrame.new(barrel.Position, endposition) for direction
- Movement: Bullet.CFrame *= CFrame.new(0, 0, -velocity * dt)
- Destroys after 1000 studs

## Notes

- Guard against re-welding main handle during iteration
- Velocity * dt for frame-rate independence
- Part 1 only: no reload, hit detection, or server replication
