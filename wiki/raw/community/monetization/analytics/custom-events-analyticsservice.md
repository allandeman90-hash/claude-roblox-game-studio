---
title: AnalyticsService - Custom Events and Telemetry
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/custom-events.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: analytics
subcategory: telemetry
tags: [analyticsservice, custom-events, telemetry, funnel, segmentation]
---

# AnalyticsService — Custom Events and Telemetry

`AnalyticsService` is Roblox's first-party event telemetry. You log
events from the server, and the Creator Hub dashboard aggregates them
into charts and lets you segment by custom fields. Use it for funnel
analysis, feature adoption, balance tuning, and retention digging.

## Hard limits

- **Server-only.** Not available on the client or in Studio.
- **Published games only.** Studio Play doesn't log.
- **100 distinct event names** per experience.
- **24-hour aggregation delay** — charts take up to a day to populate.

## Code

### Counter event (no value)

```lua
local AnalyticsService = game:GetService("AnalyticsService")

local function onMissionStart(player, missionId)
    AnalyticsService:LogCustomEvent(player, "MissionStarted")
end
```

### Value event (for averages / sums)

```lua
local function onMissionComplete(player, durationSeconds)
    AnalyticsService:LogCustomEvent(player, "MissionCompletedDuration",
                                     durationSeconds)
end
```

### Event with custom fields (preferred over name proliferation)

```lua
-- Log "PlantSeed" ONCE with the seed type as a field,
-- instead of PlantCabbage / PlantTurnip / PlantPepper.
local function onPlantSeed(player, seedType, zone, usedFertilizer)
    AnalyticsService:LogCustomEvent(
        player,
        "PlantSeed",
        1,                              -- value (count)
        {                               -- custom fields
            SeedType = seedType,
            Zone = zone,
            Fertilizer = usedFertilizer and "yes" or "no",
        }
    )
end
```

### Funnel tracking

```lua
-- Log each step of your funnel for breakdown analysis.
local function logFunnelStep(player, stepName, extra)
    AnalyticsService:LogCustomEvent(player, "Funnel_" .. stepName, 1, extra)
end

-- Example: onboarding funnel
logFunnelStep(player, "Join")
logFunnelStep(player, "TutorialStarted")
logFunnelStep(player, "TutorialSkipped")
logFunnelStep(player, "FirstMissionComplete")
logFunnelStep(player, "FirstPurchase", { productId = 123 })
```

## Dashboard aggregations

The Custom Events dashboard provides seven metric types per event:

1. **Count** — total fires
2. **Unique user count** — how many distinct users fired the event
3. **Average value** — mean of logged values
4. **Sum value** — total logged value
5. **Minimum value** — smallest value seen
6. **Maximum value** — largest value seen
7. **Average value per user** — sum / unique users

All seven can be sliced by any custom field for segment comparison.

## Design principles for custom events

- **Prefer custom fields over event-name variants.** Log `PlantSeed`
  with `SeedType = "cabbage"` rather than logging three separate events
  `PlantCabbage`, `PlantTurnip`, `PlantPepper`. You'll quickly hit the
  100-event cap otherwise.
- **Stick to stable event names.** Roblox aggregates by name; renaming
  fragments your time series.
- **Log minimal data.** Avoid PII, avoid high-cardinality fields like
  raw timestamps or session IDs.
- **Wrap event logging in pcall** in case the service is throttled.
- **Batch where reasonable** — if you're about to log 100 events in a
  single frame, aggregate them into one with a count value first.

## Use-case catalog

| Event | Purpose |
|-------|---------|
| `LoginBonusClaimed` | Daily reward engagement |
| `FirstMissionComplete` | FTUE health check |
| `ShopOpened` | Shop impression counter |
| `ShopPurchaseAttempt` | Prompt-to-purchase conversion |
| `GachaRoll` | Drop rate audit, pity tracking |
| `BossDefeated` | PvE progression funnel |
| `GuildJoin` | Social-feature adoption |
| `FeatureFlag_Used` | Adoption for live-config rollouts |

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/custom-events.md
Related: https://create.roblox.com/docs/reference/engine/classes/AnalyticsService
Captured: 2026-04-16
