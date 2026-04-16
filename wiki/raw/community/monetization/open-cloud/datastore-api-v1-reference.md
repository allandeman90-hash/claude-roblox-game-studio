---
title: Open Cloud DataStore API v1 Reference
type: raw-source
source_url: https://devforum.roblox.com/t/open-cloud-data-store-api-reference/1736533
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: open-cloud
subcategory: api
tags: [open-cloud, datastore, rest-api, api-key, external, automation]
---

# Open Cloud DataStore API v1 Reference

Roblox Open Cloud DataStore APIs are RESTful endpoints that let external
scripts and tools read, write, list, version, and delete datastore entries
without running a game server. Use cases:

- External leaderboards / websites with read-only access
- Customer support tools that can view/modify inventories and refund
- GDPR / data removal request automation
- Data migrations between key schemas
- Live-ops dashboards

## Base URL

```
https://apis.roblox.com/datastores/v1/universes/{universeId}
```

- `universeId` is the **game** (universe) id, NOT the place id.
- All requests require header `x-api-key: {api-key}`.
- API keys can be scoped: per-datastore, per-experience, and per-operation
  (read, write, list, delete, list-versions, etc.).

## Rate limits (per universe)

| Direction | Requests / min | Throughput / min |
|-----------|---------------:|-----------------:|
| Write     |            300 |            10 MB |
| Read      |            300 |            20 MB |

Over-limit returns `429 Too Many Requests`. The in-game Luau DataStore API
has its own separate quota, so external and in-game traffic do not share
a single pool.

## Endpoints

### List DataStores

```
GET /standard-datastores
? prefix= & limit= & cursor=
```

Returns `[{ name, createdTime }]`. Paginated via `nextPageCursor`.

### List Entries (keys in a datastore)

```
GET /standard-datastores/datastore/entries
? datastoreName=<name>&scope=<scope>&AllScopes=&prefix=&limit=&cursor=
```

Returns `[{ scope, key }]`.

### Get Entry

```
GET /standard-datastores/datastore/entries/entry
? datastoreName=<name>&scope=<scope>&entryKey=<key>
```

Response headers contain the metadata:
- `roblox-entry-version` — version id
- `roblox-entry-created-time`
- `last-modified`
- `roblox-entry-attributes` — up to 300 bytes JSON
- `roblox-entry-userids` — up to 4 user ids (for GDPR tracking)
- `content-md5` — base64-encoded MD5 of the body
- `content-length`

Status: `200 OK` normally; `204 No Content` on a soft-deleted tombstone.

### Set Entry

```
POST /standard-datastores/datastore/entries/entry
? datastoreName=<name>&scope=<scope>&entryKey=<key>
  &matchVersion=<vid>&exclusiveCreate=<bool>
```

Headers required:
- `content-md5: <base64 MD5 of body>` — Roblox verifies this on write.
Optional headers:
- `roblox-entry-userids: [ 123, 456 ]`
- `roblox-entry-attributes: { "foo": "bar" }`

Body: JSON content, max 4 MB.

`matchVersion` enables optimistic concurrency (the write fails if the
current version doesn't match). `exclusiveCreate=true` makes it a
create-only write (fails if any version exists).

### Increment Entry

```
POST /standard-datastores/datastore/entries/entry/increment
? datastoreName=<name>&scope=<scope>&entryKey=<key>&incrementBy=<int>
```

Atomic increment; matches in-Luau IncrementAsync semantics.

### Delete Entry

```
DELETE /standard-datastores/datastore/entries/entry
? datastoreName=<name>&scope=<scope>&entryKey=<key>
```

Returns 204. Entries are hard-deleted after 30 days.

### List Versions

```
GET /standard-datastores/datastore/entries/entry/versions
? datastoreName=<name>&scope=<scope>&entryKey=<key>
  &startTime=&endTime=&sortOrder=&limit=&cursor=
```

### Get Version

```
GET /standard-datastores/datastore/entries/entry/versions/version
? datastoreName=<name>&scope=<scope>&entryKey=<key>&versionId=<vid>
```

## Field constraints

| Field | Limit |
|-------|-------|
| datastoreName | ≤ 50 bytes, non-empty |
| scope | ≤ 50 bytes, default "global" |
| entryKey | ≤ 50 bytes, non-empty |
| body content | ≤ 4 MB |
| roblox-entry-attributes | ≤ 300 bytes JSON |
| roblox-entry-userids | ≤ 4 entries |

## Code

### curl — read a player's profile

```bash
curl -sS \
  -H "x-api-key: $ROBLOX_API_KEY" \
  "https://apis.roblox.com/datastores/v1/universes/$UNIVERSE_ID/\
standard-datastores/datastore/entries/entry?datastoreName=PlayerData\
&entryKey=Player_12345"
```

### curl — write with matchVersion (optimistic lock)

```bash
BODY='{"coins":1000,"level":5}'
MD5=$(printf %s "$BODY" | openssl dgst -md5 -binary | base64)

curl -sS -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "content-md5: $MD5" \
  -H "content-type: application/json" \
  --data-binary "$BODY" \
  "https://apis.roblox.com/datastores/v1/universes/$UNIVERSE_ID/\
standard-datastores/datastore/entries/entry?datastoreName=PlayerData\
&entryKey=Player_12345&matchVersion=$VERSION_ID"
```

### Python (via rblx-open-cloud)

```python
from rblxopencloud import Experience
exp = Experience(universe_id=12345, api_key=API_KEY)
ds = exp.get_data_store("PlayerData", scope="global")
value, info = ds.get_entry("Player_12345")
print(value, info.version)
```

## Error response format

```json
{
  "error": "InvalidArgument",
  "message": "human readable explanation",
  "errorDetails": [ { "datastoreErrorCode": "..." } ]
}
```

Common codes: `400` (bad parameter), `401` (bad key), `403` (insufficient
scope), `404` (no such entry), `429` (throttled), `500` (internal).

## Source

Original URL: https://devforum.roblox.com/t/open-cloud-data-store-api-reference/1736533
Official: https://create.roblox.com/docs/cloud/guides/data-stores
Captured: 2026-04-16
