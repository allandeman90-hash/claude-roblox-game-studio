---
title: Packages
type: studio
category: studio
subcategory: asset-management
owner: roblox-studio-specialist
status: draft
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/studio-features/packages-official-docs.md
  - wiki/raw/community/articles/studio-features/packages-devforum-guide.md
  - wiki/raw/roblox-creator-docs/best-practices/assets/packages.md
related:
  - "[[wally-packages]]"
  - "[[team-create]]"
  - "[[rojo-mapping]]"
tags: [studio, packages, version-control, collaboration, reusable-assets]
---

# Packages

> Reusable instance hierarchies with built-in version control, analogous to Prefabs in Unity or Blueprints in Unreal.

## Summary

Packages allow teams to convert any Model, Part, or instance hierarchy into a shared, versioned asset. All copies of a package share the same underlying data: publish an update to one copy and every other instance (across places and experiences) can pull the latest version automatically. This makes packages the primary mechanism for asset reuse and consistency in multi-place Roblox projects.

## Workflow

### Creating a Package

1. Select one or more instances in the Explorer or 3D viewport.
2. Right-click and choose **Convert to Package**.
3. Assign ownership (user or group). Ownership cannot be transferred after creation.
4. A `PackageLink` object is inserted as a child; deleting it reverts the instance to a normal object.

Single objects should be wrapped in a `Model` first so that additional children can be added later without breaking the package structure.

### Inserting Packages

- Personal packages: Toolbox > Inventory > My Packages
- Group packages: Toolbox > Creations > Group Packages
- Once inserted into a published place, the package appears permanently in the Asset Manager.

### Modifying and Publishing

Editing any part of a package disables auto-update for that copy until changes are published or reverted. Certain edits are ignored: root node name/position/rotation, `GuiObject.Enabled`, and external `Weld` references.

1. Make edits to the package contents.
2. Right-click the modified copy and select **Publish to Package**.
3. Auto-update copies pull changes immediately; manual-update copies show a download indicator.

### Updating Copies

| Strategy | How |
|----------|-----|
| Individual | Right-click > Get Latest Package |
| Batch | Select multiple > Get Latest Package |
| Mass (all places) | Right-click > Update All > choose places |
| Automatic | Set `PackageLink.AutoUpdate = true` |

Mass update automatically saves affected places but does not publish them. Close other Studio instances first to prevent overwrites.

## Nested Packages

Packages can contain other packages. A `SurfaceAppearance` package nested inside a `MeshPart` package allows texture and geometry to update independently. Nested package changes must be published before the parent package can be published.

## Version Control

- **Compare versions:** Right-click > Compare Package Versions. Visual diff shows 3D rendering, properties, and script diffs.
- **Restore version:** Package Options > Package Details > Versions > select version > Restore.
- **Version descriptions:** Package Details > Versions > Add.

Three diff modes: Visual Overview (3D), Properties (attribute/property deltas), Script (line-by-line).

## Attribute Configurations

Instance attributes on the package root serve as per-instance configuration. Default attribute values are set at publish time. Individual copies can override defaults (shown in bold italics in Properties). Overridden values survive package updates; non-overridden attributes sync to latest defaults.

## Access Permissions

| Permission | Capabilities |
|------------|-------------|
| Use & View | Insert, view current/previous versions. Cannot edit or publish. |
| Edit | Full access: use, view, modify, and publish. |

Configure via Creator Dashboard > Development Items > Models & Packages > Permissions. Multiple universe IDs supported (comma-separated).

## Pitfalls

- Ownership is permanent; plan group vs. personal ownership before creation.
- Nested packages require bottom-up publishing (child before parent).
- Packages sometimes display "modified" indicator without actual changes (known engine quirk).
- No Cloud API for CI/CD automation yet (planned).
- Inserting third-party packages carries script injection risk; review before use.

## Related

- [[wally-packages]] -- Wally is for Luau code packages (modules); Studio Packages are for instance hierarchies (models, UI, maps).
- [[team-create]] -- Packages work alongside Team Create for collaborative workflows.
- [[rojo-mapping]] -- External sync tools like Rojo handle code; Studio Packages handle non-code assets.

## Sources

- [Packages official docs](wiki/raw/community/articles/studio-features/packages-official-docs.md)
- [DevForum staff post: YOU Should use Packages](wiki/raw/community/articles/studio-features/packages-devforum-guide.md)
- [Roblox Creator Docs: assets/packages](wiki/raw/roblox-creator-docs/best-practices/assets/packages.md)
