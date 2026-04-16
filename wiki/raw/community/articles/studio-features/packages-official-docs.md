---
title: "Packages — Roblox Creator Documentation"
type: raw-source
source_url: https://create.roblox.com/docs/studio/packages
source_type: official-docs
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: studio-features
tags: [packages, version-control, reusable-instances, collaboration]
---

# Packages — Official Roblox Documentation

Packages enable teams to organize and reuse instances and asset hierarchies across projects. Key benefits include streamlined updates, consistency, deduplication, collaboration features, and version management capabilities.

## Core Features

- **Update Management:** Users can update all package copies to the latest version or selectively update specific instances. Packages support automatic updating when new versions become available.
- **Access Control:** Collaborators receive either "Edit" or "Use" permissions for package contents, with full version history tracking, comparison tools, and restoration capabilities.
- **Efficient Workflow:** Create packages, share with team members, enable automatic updates. Placeholder assets in early development stages automatically refresh as detailed versions publish.

## Creating Packages

Objects must be converted through the Explorer window or 3D viewport using the "Convert to Package" option. Single objects require wrapping in a Model grouping first to allow future modifications without breaking functionality.

**Critical Requirements:**
- Ownership must be assigned appropriately during creation
- Ownership transfers remain unsupported, requiring careful consideration
- A PackageLink object appears after conversion; deletion reverts the package to normal status

**Optional Configuration:** The PackageLink object's AutoUpdate property enables automatic version synchronization.

## Insertion Process

Initial package insertion requires the Toolbox:
- Personal packages via "Inventory > My Packages"
- Group packages via "Creations > Group Packages"

Once inserted into published places, packages appear in the Asset Manager permanently, regardless of later deletion.

**Security Note:** Be careful when inserting assets; they can contain malicious scripts.

## Package Modification

Editing packages disables auto-update until changes publish or revert. Certain modifications don't flag packages as changed: root node name/position/rotation, GuiObject Enabled properties, and external Weld references.

**Attribute Configurations:** Instance attributes at the package root customize behavior. Default values set during publication can be individually modified per instance, with changes indicated through bold italics. Modified configuration values preserve during updates while other attributes synchronize to latest defaults.

**Nested Packages:** Complex hierarchies support nesting, though nested package changes must publish before parent package publication.

**Script Handling:** Unmodified packages maintain read-only scripts with unlock hyperlinks; modification flags the entire package while removing notifications from other scripts.

## Publishing Changes

Publishing creates new versions accessible throughout the place and across experiences. Places don't require published packages before saving, as modified versions save locally for iteration.

**Process:**
1. Right-click modified copies and select "Publish to Package"
2. Auto-update copies immediately pull changes; others display update indicators
3. Optional version descriptions add context through "Package Details > Versions > Add"

## Update Strategies

**Individual Updates:** Outdated copies display download symbols; right-click to "Get Latest Package" or select multiple for batch updating.

**Mass Updates:**
- Close other Studio instances to prevent overwrites
- Right-click packages and select "Update All"
- Choose specific places or all places in the experience
- Automatically saves selected places without publishing
- Does not affect modified package versions

**Automatic Updates:** Enable through PackageLink's AutoUpdate property; updates occur when opening places. Disabled for modified instances; nested packages only update at highest-level parent.

## Access Permissions

**Collaborator Permissions:**
- "Use & View": Access and view current/previous versions without editing; revoked access prevents reinsertion but doesn't remove existing copies
- "Edit": Full access including usage, viewing, and publishing modifications

**Experience Permissions:** Requires editable experiences; configure through Creator Dashboard's Development Items > Models & Packages > Permissions, supporting multiple universe IDs separated by commas.

## Reverting Changes

**Unpublished Modifications:** Right-click modified copies showing dot indicators and select "Undo Changes to Package" or batch-revert multiple packages.

**Published Versions:** Access through "Package Options > Package Details > Versions"; select checkmarks next to target versions and submit.

**Configuration Reset:** Use the Attributes section's options menu to individually reset attributes to defaults.

## Version Comparison

The diff viewer displays added, removed, or modified instances across versions with three comparison modes:

- **Visual Overview:** 3D rendering differences for model root objects; synchronized pan, rotate, and zoom controls with F-key recentering
- **Properties:** Property and attribute changes across all instances
- **Script:** Line-by-line script differences; notes indicate local versus published comparisons without change attribution

Access through "Package Options > Compare Package Versions" or "View Script Changes."

## Security Considerations

Creating or sharing packages with restricted assets that users lack explicit permission to access remains possible; restricted assets simply become invisible/inaudible at runtime unless the experience holds proper permissions.

The system prevents deleting or moving PackageLink objects to preserve package capabilities.
