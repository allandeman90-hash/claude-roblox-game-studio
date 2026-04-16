---
title: feature-flags
type: concept
category: concepts
subcategory: live-ops
owner: live-ops-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/configs-and-experiments.md
  - wiki/raw/community/monetization/live-ops/feature-flag-pattern-github-json.md
related:
  - "[[cross-server-events]]"
  - "[[code-redemption]]"
  - "[[MessagingService]]"
tags: [concept, live-ops, feature-flags, remote-config, ab-testing]
---

# Feature Flags

> Remote-configurable toggles that enable or disable features without a code deploy, using either Roblox first-party Configs or a community HttpService+GitHub JSON pattern.

## What It Is

Feature flags are boolean or value-based switches that control feature availability at runtime. On Roblox, two approaches coexist:

1. **Roblox Configs and Experiments** (first-party, launched 2025) -- built into Creator Hub with A/B testing, Studio integration, and 5-minute propagation.
2. **HttpService + GitHub JSON** (community pattern) -- a JSON file hosted on a CDN (typically `raw.githubusercontent.com`), polled by game servers via `HttpService`. Independent of the Roblox backend.

Both serve the same purpose: change game behavior without pushing a new version.

## When to Use It

- **Kill-switches.** Disable a broken feature instantly while a fix ships.
- **Live balance tuning.** Adjust weapon damage, reward values, spawn rates in real time.
- **Gradual rollouts.** Ship a feature to 5% of players, monitor, ramp to 100%.
- **A/B testing.** Run experiments on onboarding flows, UI layouts, or economy values.
- **Seasonal toggles.** Flip holiday themes on/off on schedule.

## Implementation

### Approach 1: Roblox Configs (Recommended Default)

Configs are managed in Creator Hub or Studio (File menu > Configs).

**Authoring:**
1. Create a config entry: key, type (string / number / boolean / JSON), default value.
2. Test in Studio before publishing.
3. Publish. Changes propagate within ~5 minutes, with optional 15-minute gradual rollout.

**Hard limits:**

| Limit | Value |
|-------|-------|
| Active configs per universe | 1,000 |
| Concurrent in-experience experiments | 10 |
| Concurrent matchmaking experiments | 1 |
| Supported types | string, number, boolean, JSON |

**Reading in Luau:**

Configs are read via the server-side configs API. Delay reading until the feature is actually exercised so players are not enrolled into experiments prematurely.

### Approach 2: HttpService + GitHub JSON

For an emergency kill-switch independent of Roblox, or for git-reviewable flag changes:

**Static flags (FFlag) -- read once at server start:**

```lua
local HttpService = game:GetService("HttpService")
local FFLAG_URL = "https://raw.githubusercontent.com/org/repo/main/fflags.json"

local FFlag = {}

local function load()
    local ok, raw = pcall(function()
        return HttpService:GetAsync(FFLAG_URL)
    end)
    if not ok then warn("FFlag fetch failed:", raw); return {} end
    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    return okDecode and data or {}
end

FFlag.values = load()

function FFlag.Is(name: string): boolean
    return FFlag.values[name] == true
end

return FFlag
```

**Dynamic flags (DFFlag) -- polling loop, updates running servers:**

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
            Headers = { ["Cache-Control"] = "no-cache" },
        })
    end)
    if not ok or not response.Success then return end
    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)
    if okDecode and type(data) == "table" then
        DFFlag.values = data
    end
end

function DFFlag.Is(name: string): boolean
    return DFFlag.values[name] == true
end

function DFFlag.Get(name: string, default: any): any
    local v = DFFlag.values[name]
    return if v ~= nil then v else default
end

task.spawn(function()
    while true do
        fetch()
        task.wait(POLL_INTERVAL)
    end
end)

return DFFlag
```

**Instant propagation via MessagingService:**

Combine with [[MessagingService]] to trigger an immediate refetch when flags change, rather than waiting for the next poll:

```lua
local MessagingService = game:GetService("MessagingService")

MessagingService:SubscribeAsync("flags:invalidate", function()
    fetch()
end)
```

Publish from a GitHub Action via Open Cloud:

```bash
rbxcloud messaging publish \
    --api-key "$ROBLOX_API_KEY" \
    --universe-id "$UNIVERSE_ID" \
    --topic "flags:invalidate" \
    --message "$(git rev-parse HEAD)"
```

### A/B Testing (Experiments)

Experiments sit on top of Roblox Configs:

1. Create a config (the thing being tested).
2. Create an experiment in Creator Hub with 2-8 groups.
3. Assign traffic percentages (must sum to 100%).
4. Start the experiment; results populate in 24-48 hours.
5. Ramp the winning variant to 100%.

**Statistical guidance:**
- Do not decide before the full duration expires -- early swings are novelty effects.
- Watch the Minimum Detectable Effect (MDE). Very high MDE = no statistical power.
- Run one change per experiment. Overlapping experiments produce interaction effects.
- Document every experiment: hypothesis, variant design, result, decision.

## Variants

| Approach | Pros | Cons | When to use |
|----------|------|------|-------------|
| **Roblox Configs** | Built-in A/B testing, Studio integration, no infra | 5-min propagation, Roblox-dependent | Default for most flag use cases |
| **GitHub JSON (FFlag)** | Git-reviewable, Roblox-independent | Static, new servers only | Emergency kill-switch layer |
| **GitHub JSON (DFFlag)** | Git-reviewable, updates running servers | Requires HttpService enabled, GitHub CDN dependency | CI/CD-driven flag pushes |
| **DataStore-backed** | Persistent, no external dependency | Slow, consumes budget | Rarely needed; Configs supersede |

## Pitfalls

- **HttpService must be enabled.** Game Settings > Security > Allow HTTP Requests. This is a per-game setting; it is off by default.
- **Cache-Control header required.** Always send `Cache-Control: no-cache` on `RequestAsync` headers or Roblox's HTTP proxy returns stale JSON.
- **Fail-closed to last-known-good.** If a fetch fails, keep the previous flag values. Never crash or zero-out on a bad fetch.
- **HttpService rate limit.** Roblox caps at 500 requests/min per server. With a 5-minute poll, you consume 12 req/hr -- well under the limit. But do not poll faster than 60 seconds.
- **Flag lifecycle.** Flags accumulate over time. Retire old flags aggressively -- a flag that has been 100% enabled for 3 months should be removed from the codebase and the JSON.

## Related

- [[cross-server-events]] -- MessagingService for instant flag propagation
- [[code-redemption]] -- another live-ops tool often controlled by flags
- [[MessagingService]] -- pub/sub for flag invalidation broadcasts

## Sources

- [wiki/raw/community/monetization/live-ops/configs-and-experiments.md](../raw/community/monetization/live-ops/configs-and-experiments.md)
- [wiki/raw/community/monetization/live-ops/feature-flag-pattern-github-json.md](../raw/community/monetization/live-ops/feature-flag-pattern-github-json.md)
