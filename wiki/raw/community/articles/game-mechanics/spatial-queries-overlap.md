# Spatial Queries and OverlapParams

**Source:** https://devforum.roblox.com/t/introducing-overlapparams-new-spatial-query-api/1435720
**Captured:** 2026-04-15

## New Spatial Query Functions (Replacing Region3)

### GetPartBoundsInBox(cframe, size, overlapParams)

Returns all BaseParts whose bounding boxes overlap the given oriented box.
Orientation IS taken into account.

### GetPartBoundsInRadius(position, radius, overlapParams)

Returns BaseParts overlapping a spherical region using bounding box overlap.

### GetPartsInPart(part, overlapParams)

Returns BaseParts overlapping a given part instance. Full geometry collision check — more accurate than bounding box methods.

## OverlapParams Configuration

- FilterDescendantsInstances: Array of objects for filtering
- FilterType: RaycastFilterType.Whitelist or .Blacklist
- MaxParts: Maximum results (0 = unlimited)
- CollisionGroup: Target collision group ("Default" by default)

## Deprecated Region3 Functions

- Workspace:FindPartsInRegion3
- Workspace:FindPartsInRegion3WithIgnoreList
- Workspace:FindPartsInRegion3WithWhiteList
- Workspace:IsRegion3Empty
- Workspace:IsRegion3EmptyWithIgnoreList

## Usage in Combat

For melee/AoE hit detection:
- GetPartBoundsInBox: Oriented hitbox in front of character
- GetPartBoundsInRadius: Radial AoE damage zones
- GetPartsInPart: Precise collision for irregular shapes

Each returns a table of parts. Filter for Humanoid parents to find damageable entities.
