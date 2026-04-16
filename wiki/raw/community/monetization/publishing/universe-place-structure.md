---
title: Universe vs Place Structure and Publishing Workflow
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/publishing/publish-experiences-and-places.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: publishing
subcategory: deployment
tags: [universe, place, publishing, start-place, version, rollout]
---

# Universe vs Place Structure and Publishing Workflow

Roblox separates **experiences (universes)** from **places**. An
experience is the whole game as it appears on the Discover page. A
place is one rbxl/rbxlx file inside it. Players enter via the
**start place** and can be teleported between additional places via
TeleportService.

## Terminology

| Term | Meaning |
|------|---------|
| Experience / Universe | Top-level game; what shows on Discover |
| Place | Individual rbxl file; a "room" of the universe |
| Start Place | The place new players join by default |
| UniverseId | Integer id for the experience (used in Open Cloud) |
| PlaceId | Integer id for a single place (used in teleports, `game.PlaceId`) |

## Decision: one big place or many small places

- **One large place**: simpler publishing, shared ServerStorage, player
  data lives on one DataStore universe. Easier to manage.
- **Many small places**: lets you scale specific zones independently,
  run different game modes in different places, isolate risky
  experimental content. More publish complexity (packages help).

Roblox's own position: "mostly personal preference."

## Initial publish flow

1. Studio → **File** → **Publish to Roblox**
2. Fill in Name, Description, Creator, supported Devices
3. Click **Create**
4. The experience starts as **private**, accessible only to the creator
   and users with Edit or Playtest permission
5. A `.rblx` file is stored in Roblox cloud storage

## Adding a place to an existing universe

1. Open or create a new rbxl
2. **File** → **Publish to Roblox As…**
3. Click the tile for your existing experience
4. Select **Add as a new place**
5. **Create**

## Changing the start place

The start place cannot be instantly swapped, but can be overwritten:

1. Save your candidate new start place
2. Creator Dashboard → **Configure** → **Places**
3. Open the intended new start place in Studio
4. **File** → **Publish to Roblox As…** → select the current start
   place → **Overwrite**
5. If the game is live, **restart servers** so users load the new
   start place

## Making an experience public

Requirements before publishing publicly:

- Account at least **48 hours old**
- Complete the **content maturity questionnaire**
- Either **ID-verified** account OR a **purchase since 2025-01-01**
- **Max 5 private experiences** can be made public per account per day

## Beta mode — safer rollouts

A public experience can **opt in to Beta mode**, which excludes it from
the "Recommended for You" algorithmic surface. Use this to:

- Soft-launch without burning your algorithmic first impression
- Test live-ops systems on organic searchers before going wide
- Stage monetization changes to a subset of users
- Run longer A/B experiments before accepting algorithm judgment

## Audience access control

After public publish, access can be restricted to:

- **Public** — all Roblox users
- **Friends** — creator's friends only
- **Community members** — group members only (for group experiences)

## Metadata best practices

- **Names**: keep stable so the algorithm and players can find you.
  Avoid keyword spam and emoji décor.
- **Description**: summarize the experience in the first sentence;
  include relevant keywords but don't stuff.
- **Thumbnail/description match**: mismatches get deranked by the
  Discover algorithm.

## Version history and rollback

Roblox Studio stores version history per place. You can roll back:

1. **File** → **Game Settings** → **Version History** (or Creator Hub
   → the place → Versions)
2. Select a prior version
3. Click **Revert**

Version history works per-place, not per-universe, so a universe-wide
rollback means rolling back each place separately. For CI/CD pipelines,
track the Roblox-returned `versionNumber` from the Open Cloud publish
API so you can automate rollback.

## Publishing via Open Cloud API (CI/CD)

```
POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions
     ?versionType=Published
Headers:
  x-api-key: <key with universe-places:Write>
  Content-Type: application/octet-stream   (for .rbxl)
  # or application/xml                     (for .rbxlx)
```

Response: `{ "versionNumber": 7 }`.

**Caveat:** the API does NOT update certain instance types —
`EditableImage`, `EditableMesh`, `PartOperation`, `SurfaceAppearance`,
`BaseWrap`. If your place contains any of these and they've changed,
you must publish from Studio at least once. This is a common gotcha
for CI/CD setups.

## Concrete Numbers / Examples

- Account age to publish public: **48 hours**
- Daily private→public limit: **5 per day**
- Required: **ID-verify** OR **post-2025-01-01 purchase**
- Open Cloud publish permission: **universe-places:Write**
- Instance types that block API publish: `EditableImage`, `EditableMesh`,
  `PartOperation`, `SurfaceAppearance`, `BaseWrap`

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/publishing/publish-experiences-and-places.md
Related: https://create.roblox.com/docs/cloud/guides/usage-place-publishing
Captured: 2026-04-16
