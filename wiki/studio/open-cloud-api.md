---
title: Open Cloud API
type: studio
category: studio
subcategory: deployment
owner: devops-engineer
status: complete
created: 2026-04-16
updated: 2026-04-15
sources:
  - wiki/raw/community/monetization/open-cloud/datastore-api-v1-reference.md
  - wiki/raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md
  - wiki/raw/community/monetization/open-cloud/assets-api-upload.md
  - wiki/raw/community/monetization/open-cloud/messaging-service-api.md
  - wiki/raw/community/monetization/open-cloud/oauth2-authentication.md
  - wiki/raw/community/articles/tooling/github-actions-roblox-cicd.md
related:
  - "[[DataStoreService]]"
  - "[[MessagingService]]"
  - "[[rojo-mapping]]"
  - "[[github-actions-cicd]]"
tags: [studio, deployment, api, open-cloud, cicd]
---

# Open Cloud API

> REST APIs that let external tools interact with Roblox experiences without running inside the game: publish places, read/write DataStores, send messages, upload assets, and execute Luau remotely.

## Summary

Roblox Open Cloud is a set of HTTPS APIs for automating operations that previously required opening Studio or running a live server. The APIs cover place publishing, DataStore access, MessagingService publishing, asset uploading, and remote Luau execution. They are the foundation for CI/CD pipelines, external dashboards, customer support tools, and live-ops automation.

## Authentication

### API Keys

Generated via **Creator Dashboard > Credentials**. Each key is scoped to specific universes and operations.

```
x-api-key: <your-key>
```

Best practices:
- Scope keys to the minimum required permissions.
- Separate keys for staging vs. production.
- Set IP allowlists where possible (use `0.0.0.0/0` for GitHub Actions runners).
- Store as GitHub Actions secrets, never in code.

### OAuth 2.0

For third-party apps acting on behalf of multiple creators. Supports Authorization Code Flow with PKCE.

```
Authorization: Bearer <access_token>
```

Key scopes: `openid`, `profile`, `asset:read`, `asset:write`, `universe-messaging-service:publish`, `universe-datastores.objects:read`, `universe-datastores.objects:write`, `universe-places:write`.

OAuth registration requires a 13+ account and ID verification.

## APIs at a Glance

### Place Publishing

```
POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions
     ?versionType=Published
Content-Type: application/octet-stream
```

Uploads a `.rbxl` or `.rbxlx` file. Returns `{ "versionNumber": N }`.

Required permission: `universe-places:Write`.

```bash
curl -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @build/game.rbxlx \
  "https://apis.roblox.com/universes/v1/$UNIVERSE_ID/places/$PLACE_ID/versions?versionType=Published"
```

**Caveat:** The API does not upload `EditableImage`, `EditableMesh`, `PartOperation`, `SurfaceAppearance`, or `BaseWrap`. If your place contains these and they have changed, publish from Studio first.

### DataStore API v1

Base URL: `https://apis.roblox.com/datastores/v1/universes/{universeId}`

| Operation | Endpoint | Notes |
|---|---|---|
| List DataStores | `GET /standard-datastores` | Paginated |
| List entries | `GET /standard-datastores/datastore/entries` | By name, scope, prefix |
| Get entry | `GET /standard-datastores/datastore/entries/entry` | Returns value + metadata headers |
| Set entry | `POST /standard-datastores/datastore/entries/entry` | Requires `content-md5` header |
| Increment | `POST .../entry/increment` | Atomic increment |
| Delete entry | `DELETE .../entry` | Hard-deleted after 30 days |
| List versions | `GET .../entry/versions` | Time-filtered, paginated |
| Get version | `GET .../entry/versions/version` | By version id |

Rate limits per universe: **300 writes/min (10 MB)**, **300 reads/min (20 MB)**. Separate from in-game DataStore quotas.

`matchVersion` parameter enables optimistic concurrency (CAS). `exclusiveCreate=true` makes it create-only.

```bash
# Read a player's data
curl -sS \
  -H "x-api-key: $ROBLOX_API_KEY" \
  "https://apis.roblox.com/datastores/v1/universes/$UNIVERSE_ID/\
standard-datastores/datastore/entries/entry?datastoreName=PlayerData&entryKey=Player_12345"
```

### MessagingService API

```
POST https://apis.roblox.com/cloud/v2/universes/{universeId}:publishMessage
```

Publishes a message to a topic. Running servers subscribed via `MessagingService:SubscribeAsync` receive it within ~1 second.

Rate limit: `50 + (5 x current_player_count)` requests/min. Message max: 1,024 characters. Topic name max: 80 characters.

```bash
curl -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"topic":"LiveOps","message":"Flip flag FeatureX off"}' \
  "https://apis.roblox.com/cloud/v2/universes/$UNIVERSE_ID:publishMessage"
```

### Assets API

```
POST https://apis.roblox.com/assets/v1/assets
Content-Type: multipart/form-data
```

Uploads assets (audio, images, models, video). Returns an operation ID; poll `GET .../operations/{id}` until `done == true`. Check `moderationResult.moderationState` (`APPROVED`, `PENDING`, `REJECTED`).

File size cap: **20 MB**. Audio: max 7 min, 100/month (ID-verified) or 10/month. Video: max 5 min, 20/day.

### Luau Execution API

```
POST https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution-sessions
```

Posts a Luau script to a universe+place pair, executes it server-side, and returns stdout/stderr as structured JSON. Used for running automated tests in CI.

Concurrency limit: **2 concurrent requests per universe**. Use GitHub Actions `concurrency:` groups to serialize.

## rbxcloud CLI

The `rbxcloud` CLI (by Sleitnick) wraps these APIs:

```bash
# Publish a place
rbxcloud experience publish -f build.rbxl -p $PLACE_ID -u $UNIVERSE_ID \
    -t published -a "$ROBLOX_API_KEY"

# Read a DataStore key
rbxcloud datastore entry get --api-key "$ROBLOX_API_KEY" \
    --universe-id "$UNIVERSE_ID" --datastore-name PlayerData --key Player_1234

# Publish a message
rbxcloud messaging publish --api-key "$ROBLOX_API_KEY" \
    --universe-id "$UNIVERSE_ID" --topic liveops:flags \
    --message '{"feature":"doubleXP","on":true}'
```

## Field Constraints (DataStore API)

| Field | Limit |
|---|---|
| `datastoreName` | <= 50 bytes |
| `scope` | <= 50 bytes (default: `global`) |
| `entryKey` | <= 50 bytes |
| Body content | <= 4 MB |
| `roblox-entry-attributes` | <= 300 bytes JSON |
| `roblox-entry-userids` | <= 4 entries |

## Pitfalls

- **Instance types that block API publishing.** `EditableImage`, `EditableMesh`, `PartOperation`, `SurfaceAppearance`, `BaseWrap` cannot be uploaded via the API. Publish from Studio when these change.
- **Luau Execution concurrency.** Only 2 concurrent sessions per universe. Without `concurrency:` groups in CI, parallel PRs will 429.
- **Separate quotas.** Open Cloud DataStore rate limits are separate from in-game DataStore quotas. Both pools can be exhausted independently.
- **content-md5 required for writes.** The DataStore Set Entry endpoint requires a base64-encoded MD5 hash of the body in the `content-md5` header.

## Related

- [[DataStoreService]]
- [[MessagingService]]
- [[rojo-mapping]]
- [[github-actions-cicd]]

## Sources

- [DataStore API v1 reference](../raw/community/monetization/open-cloud/datastore-api-v1-reference.md)
- [Place Publishing CI/CD](../raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md)
- [Assets API](../raw/community/monetization/open-cloud/assets-api-upload.md)
- [MessagingService API](../raw/community/monetization/open-cloud/messaging-service-api.md)
- [OAuth 2.0 Authentication](../raw/community/monetization/open-cloud/oauth2-authentication.md)
- [GitHub Actions CI/CD](../raw/community/articles/tooling/github-actions-roblox-cicd.md)
- Official docs: https://create.roblox.com/docs/cloud
