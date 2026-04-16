---
title: Open Cloud Assets API - Upload and Update
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/guides/usage-assets.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: open-cloud
subcategory: api
tags: [assets-api, upload, open-cloud, moderation, api-key]
---

# Open Cloud Assets API — Upload and Update

The Assets API lets you upload and update assets via HTTPS rather than
manually importing via Studio. Use it for:

- CI/CD pipelines that ship audio / decals / animations with scripts
- Bulk re-upload after source regeneration
- Automated moderation resubmission
- Third-party tools (editor plugins, asset-management apps)

## Supported asset types

| Type | Accepted formats | Content-Type | Notes |
|------|------------------|--------------|-------|
| Animation | `.rbxm`, `.rbxmx` | `model/x-rbxm` | Studio-edited files only |
| Audio | `.mp3`, `.ogg`, `.wav`, `.flac` | `audio/*` | Max 7 min; **100/month** if ID-verified, **10/month** if not. Not updatable. |
| Decal / Image | `.png`, `.jpeg`, `.bmp`, `.tga` | `image/*` | Max 8000 × 8000 px. Not updatable. |
| Mesh | Roblox mesh format | `model/x-file-mesh-data` | Only from Roblox Asset Delivery API. Not updatable. |
| Model | `.fbx`, `.gltf`, `.glb`, `.rbxm`, `.rbxmx` | `model/*` | Imports as Model with MeshPart children. |
| Video | `.mp4`, `.mov` | `video/*` | Max 5 min, 4096×2160, 3.75 GB, **20/day** (13+ ID-verified). |

File size cap per request: **20 MB**.

## Authentication

### API key

```
x-api-key: <your-key>
```

Key must have **assets** permission with **Read** / **Write** on the
target creator scope (user or group).

### OAuth 2.0

Scopes: `asset:read`, `asset:write`.

```
Authorization: Bearer <access_token>
```

## Endpoints

### Create asset

```
POST https://apis.roblox.com/assets/v1/assets
Content-Type: multipart/form-data
```

Multipart form fields:
- `request` — JSON with `assetType`, `displayName`, `description`,
  `creationContext` (creator user or group id)
- `fileContent` — binary file contents

Returns an **operation id** (async). Poll `GET .../operations/{id}`
until done.

### Update asset (metadata or content)

```
PATCH https://apis.roblox.com/assets/v1/assets/{assetId}
```

Query param `updateMask` controls which fields are updated (comma-sep):
`displayName`, `description`, `previews`, `icon`.

Content update currently only supports **.fbx** updates.

### Get operation status

```
GET https://apis.roblox.com/assets/v1/operations/{operationId}
```

Response includes:
- `done` — boolean
- `response` → `assetId`, `revisionId`, `moderationResult.moderationState`
  (`APPROVED` / `PENDING` / `REJECTED`)

## Code

### curl — upload an audio file

```bash
ASSET_JSON='{
  "assetType": "Audio",
  "displayName": "Boss Theme",
  "description": "Main boss BGM",
  "creationContext": { "creator": { "userId": "12345" } }
}'

curl -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -F "request=$ASSET_JSON;type=application/json" \
  -F "fileContent=@./boss-theme.mp3;type=audio/mpeg" \
  "https://apis.roblox.com/assets/v1/assets"
```

### curl — poll operation

```bash
curl -sS -H "x-api-key: $ROBLOX_API_KEY" \
  "https://apis.roblox.com/assets/v1/operations/$OPERATION_ID"
```

### Python snippet (rblx-open-cloud)

```python
from rblxopencloud import User, AssetType

me = User(user_id=12345, api_key=API_KEY)
with open("banner.png", "rb") as f:
    asset = me.upload_asset(
        file=f,
        asset_type=AssetType.Decal,
        name="Winter Banner",
        description="Seasonal banner",
    ).wait()
    print(asset.id, asset.moderation_state)
```

## Upload quotas

| Asset type | Quota | Condition |
|------------|-------|-----------|
| Audio | **10/month** | Non-verified |
| Audio | **100/month** | ID-verified |
| Video | **20/day** | 13+, ID-verified |
| Other | Generally unlimited | Subject to platform moderation |

## Moderation

Every upload is moderated. Possible states:

- `APPROVED` — asset usable
- `PENDING` — still reviewing (assets are held until verdict)
- `REJECTED` — rejected, re-upload required

Your pipeline should poll the operation endpoint until `done == true`
and act on `moderationResult.moderationState`.

## Concrete Numbers / Examples

- File size limit: **20 MB**
- Decal/Image max: **8000 × 8000 px**
- Audio cap: **7 min** per clip
- Video cap: **5 min**, 3.75 GB
- Audio quota: **100/month verified**, 10/month otherwise
- Video quota: **20/day** (verified only)
- Endpoint: `POST /assets/v1/assets` (multipart)
- Operation polling: `GET /assets/v1/operations/{id}`

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/guides/usage-assets.md
Related: https://devforum.roblox.com/t/opencloud-assets-api/2298007
Captured: 2026-04-16
