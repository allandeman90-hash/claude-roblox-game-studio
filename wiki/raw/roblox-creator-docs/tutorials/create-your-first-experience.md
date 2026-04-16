---
title: Create Your First Experience
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/first-experience
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, studio-basics, data-model, baseplate, parts, workspace, replicatedstorage, serverscriptservice, publishing]
difficulty: beginner
---

# Create Your First Experience

After you complete the onboarding tour and are familiar with Roblox Studio's user interface, you're ready to start creating experiences on the platform.

Using a sample catapult asset pack, this tutorial walks you through creating an experience in which players launch projectiles toward targets on floating platforms. You'll learn:
- Building and organizing a data model for a single place using a project template
- Customizing primitive and complex 3D objects with unique properties
- Organizing scripts in their proper locations
- Playtesting and publishing

## Steps

### Create a project

A **project** is a collection of assets, settings, and other resources that together represent an experience. All projects start with a single **place** that players load into when they join. A place's object hierarchy is its **data model**.

**Project templates** provide default objects in the starting place's data model that you can use to build experiences for different genres.

This tutorial uses the **Baseplate** template because it includes:
- **SpawnLocation**: Where player characters appear and respawn
- **Baseplate**: A floor with a 4x4 grid texture (studs ≈ 28cm each)

To open a project:
1. Open **Roblox Studio**.
2. Select the **Baseplate** template tile.

### Get asset pack

Studio represents 3D objects as `BasePart` objects that render with physical simulation. The most common types:
- **Parts**: `Part` objects — primitive shapes (ball, block, cylinder, wedge, corner wedge)
- **Meshes**: `MeshPart` objects — custom vertices/edges/faces from third-party modeling tools

The **Creator Store** (in the Toolbox) features assets from Roblox and the community.

To insert the catapult asset pack:
1. From Window menu or Home tab, open the **Toolbox**.
2. Click the **Inventory** tab.
3. Click the asset pack tile. The assets display in your viewport.

### Customize targets

When you select an object in the **Explorer**, Studio updates the **Properties** window with customizable fields.

To customize targets:
1. Expand the **IntroToStudioCatapult** folder in Explorer.
2. Select a target part.
3. In Properties, set:
   - **BrickColor** — part tint
   - **Size** — scale along X, Y, Z
   - **CFrame.Position** — location
   - **CFrame.Orientation** — rotation

### Organize scripts

The Roblox Engine expects certain objects to be in specific **container services** for simulation to work properly.

- **Workspace**: Objects that render in the 3D world
- **ReplicatedStorage**: Content and logic that replicates between server and client
- **ServerScriptService**: Server-side only scripts and logic
- **StarterPlayer / StarterCharacterScripts**: Client-side player/character scripts

Script types:
- **Script**: Runs based on `RunContext` (Legacy, Server, or Client)
- **ModuleScript**: Reusable, required via `require()`

To organize folders:
1. Expand **ReplicatedStorage** and **ServerScriptService** folders.
2. Drag children from ReplicatedStorage folder into the **ReplicatedStorage** service.
3. Drag children from ServerScriptService folder into the **ServerScriptService** service.
4. Delete the empty folders.
5. Playtest to verify the catapult works.

### Customize projectiles

Each projectile has a unique **material** that emulates real-world physical characteristics (density, elasticity, friction). According to Newton's second law, projectile acceleration depends on applied force and mass.

To customize projectile materials:
1. In Explorer, expand **ProjectileMaterials** folder.
2. Select a projectile.
3. In Properties, set **Material** to a real-world material.

### Publish experience

Almost everything in Roblox is represented as a cloud-based asset with an ID in the form `rbxassetid://[ID]`. Published experiences get a `UniverseId` and each place gets a `PlaceId`.

To publish:
1. Click **File** → **Publish to Roblox**.
2. Fill in Name, Description, Genre, and enabled Devices.
3. Click **Create**.
4. On the Creator Dashboard, hover the experience tile → **...** → **Make Public**.

## Key Concepts

- **Project**: Collection of assets, settings, resources representing an experience
- **Place**: A single world within an experience with its own data model
- **Data Model**: Hierarchy of objects describing everything in a place
- **Template**: Pre-configured starting place (Baseplate, Racing, Modern City, etc.)
- **Workspace**: Container for rendered 3D objects
- **ReplicatedStorage**: Shared between client and server
- **ServerScriptService**: Server-only scripts
- **RunContext**: Controls whether a script runs on server, client, or by parent (legacy)
- **BasePart**: Base class for 3D objects (Part, MeshPart, etc.)
- **Studs**: Roblox length unit (~28cm)
- **UniverseId**: Experience-wide cloud ID
- **PlaceId**: Individual place cloud ID

## Notes

- Every experience needs a SpawnLocation
- Scripts must go into correct container services or behavior breaks
- Use Explorer to navigate the data model
- Use Properties to customize objects without scripts
- Publish experiences to get them on Roblox cloud and make them playable

## Source

Original URL: https://create.roblox.com/docs/tutorials/first-experience
Captured: 2026-04-16
