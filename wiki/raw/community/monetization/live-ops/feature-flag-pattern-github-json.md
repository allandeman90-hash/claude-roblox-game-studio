---
title: Feature Flags via HttpService + GitHub JSON
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-make-a-fastflagdynamic-fastflag-system/1061151
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: live-ops
subcategory: feature-flags
tags: [feature-flags, fflag, dfflag, httpservice, github, remote-config]
---

# Feature Flags via HttpService + GitHub JSON

Before Roblox shipped first-party **Configs** (see
`configs-and-experiments.md`), the community pattern for remote feature
flags was to host a JSON file on a CDN (typically GitHub raw URLs) and
have servers poll it via `HttpService`.

This pattern is still useful when:

- You're already on Configs but want an emergency kill-switch
  independent of the Roblox backend
- Your config changes need to be diff-reviewable in git
- You want to flip flags from a CI/CD pipeline by pushing to a branch
- You want a developer-only override layer above Configs

## FFlag vs DFFlag (terminology borrowed from Roblox internals)

| Type | Update cadence | When it activates |
|------|----------------|-------------------|
| **FFlag** (static) | Reads once at server start | Change is picked up only when new servers spawn |
| **DFFlag** (dynamic) | Polls every ~5 minutes | Change propagates to running servers within 5 min |

## JSON file shape

```json
{
  "FeatureNewShop": true,
  "DoubleXPWeekend": false,
  "BossSpawnRateMultiplier": 1.0,
  "SeasonalTheme": "winter",
  "MaintenanceMode": false
}
```

Supported types from the tutorial: **booleans, strings, integers**.
You can also encode small nested objects.

## Code

### FFlag reader (server start, static)

```lua
local HttpService = game:GetService("HttpService")
local FFLAG_URL = "https://raw.githubusercontent.com/org/repo/main/fflags.json"

local FFlag = {}

local function load()
    local ok, raw = pcall(function()
        return HttpService:GetAsync(FFLAG_URL)
    end)
    if not ok then
        warn("FFlag fetch failed:", raw)
        return {}
    end
    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    return okDecode and data or {}
end

FFlag.values = load()

function FFlag.Is(name)
    return FFlag.values[name] == true
end

return FFlag
```

### DFFlag reader (polling loop, dynamic)

```lua
local HttpService = game:GetService("HttpService")

local DFFLAG_URL = "https://raw.githubusercontent.com/org/repo/main/dfflags.json"
local POLL_INTERVAL = 300  -- 5 minutes

local DFFlag = {}
DFFlag.values = {}

local function fetch()
    local ok, response = pcall(function()
        return HttpService:RequestAsync({
            Url = DFFLAG_URL,
            Method = "GET",
            Headers = {
                ["Cache-Control"] = "no-cache",
            },
        })
    end)
    if not ok or not response.Success then
        warn("DFFlag fetch failed")
        return
    end
    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)
    if okDecode and type(data) == "table" then
        DFFlag.values = data
        DFFlag:Fire("updated")
    end
end

-- Very simple event bus
local listeners = {}
function DFFlag:On(event, cb) listeners[event] = listeners[event] or {} table.insert(listeners[event], cb) end
function DFFlag:Fire(event, ...) for _, cb in ipairs(listeners[event] or {}) do task.spawn(cb, ...) end end

function DFFlag.Is(name)
    return DFFlag.values[name] == true
end

function DFFlag.Get(name, default)
    local v = DFFlag.values[name]
    if v == nil then return default end
    return v
end

task.spawn(function()
    while true do
        fetch()
        task.wait(POLL_INTERVAL)
    end
end)

return DFFlag
```

### Pairing with MessagingService for instant propagation

For instant updates (not waiting the 5-minute poll window), combine
with MessagingService: publish a `flags:invalidate` message from your
CI/CD pipeline via Open Cloud when you push a JSON change. Servers
refetch immediately on receipt.

```lua
local MessagingService = game:GetService("MessagingService")

MessagingService:SubscribeAsync("flags:invalidate", function()
    fetch()
end)
```

Publish from a GitHub Action using rbxcloud:

```bash
rbxcloud messaging publish \
    --api-key "$ROBLOX_API_KEY" \
    --universe-id "$UNIVERSE_ID" \
    --topic "flags:invalidate" \
    --message "$(git rev-parse HEAD)"
```

### Typed getters and defaults

```lua
function DFFlag.GetNumber(name, default)
    local v = DFFlag.values[name]
    return (type(v) == "number") and v or default
end

function DFFlag.GetString(name, default)
    local v = DFFlag.values[name]
    return (type(v) == "string") and v or default
end
```

## Design choices to understand

- **GitHub as a CDN**: no DataStore quota used, no engineering effort
  to spin up a backend. The flag file is static-served from GitHub's
  `raw.githubusercontent.com`.
- **Independent of Roblox backend**: if DataStore is degraded, flags
  still work. Useful as an emergency kill-switch channel.
- **Diff-reviewable**: changes go through PRs, not a dashboard. You
  get audit history for free.
- **Polling over push**: simple, robust, no connection state.

## Gotchas

- **HttpService must be enabled** (Game Settings → Security → Allow
  HTTP Requests). This is a per-game setting.
- **Rate limits**: Roblox caps HttpService to 500 requests/min per
  server. With a 5-minute poll, you consume 12 req/hr per server —
  well under the limit.
- **GitHub rate limits**: raw.githubusercontent.com is typically
  unlimited for unauthenticated GETs but is best-effort. For critical
  flags, mirror to a proper CDN.
- **Cache-Control**: always send `no-cache` on RequestAsync headers
  or you'll get stale responses from Roblox's HTTP proxy.
- **Errors must not break the game**. Fail-closed to last-known-good
  values; never crash on a bad fetch.

## When to use built-in Configs instead

Roblox's first-party Configs (see `configs-and-experiments.md`)
launched in 2025 and is now the recommended path for non-emergency
remote config. Use Configs when:

- You want A/B testing built in (Experiments)
- You want Studio integration for testing before publish
- You want 5-minute propagation without running your own infrastructure
- You want up to 1,000 active flags per universe

Use HttpService + GitHub JSON when:

- You need a kill-switch independent of the Roblox backend
- You want git-reviewable flag changes
- You want CI/CD to push flags as part of deploys
- You want to share flag config across multiple universes

## Source

Original URL: https://devforum.roblox.com/t/how-to-make-a-fastflagdynamic-fastflag-system/1061151
Related: https://devforum.roblox.com/t/fflagservice-dynamically-enable-and-disable-features-in-your-game/1554287
Captured: 2026-04-16
