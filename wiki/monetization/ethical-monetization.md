---
title: ethical-monetization
type: monetization
category: monetization
subcategory: ethics
owner: monetization-lead
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/ethics/ethical-monetization-principles.md
  - wiki/raw/community/monetization/ethics/paid-random-items-policy.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/virtual-items.md
related:
  - "[[game-pass]]"
  - "[[dev-product]]"
  - "[[robux-price-tiers]]"
  - "[[premium-benefits]]"
tags: [monetization, ethics]
---

# Ethical Monetization

> Principles and platform rules for monetizing experiences responsibly, with specific attention to Roblox's young audience. Covers pay-to-win boundaries, lootbox regulations, FOMO limits, odds disclosure requirements, and age-appropriate guardrails.

## Summary

Roblox's player base skews young -- COPPA-protected under-13 users are a significant fraction of concurrent users. This makes ethical monetization not just a moral choice but a **business continuity requirement**: regulators, lawsuits, and platform rules all enforce it. The core principle is that **monetization saves time, not gates content**. Free players should be able to earn everything that paying players can access; purchases accelerate, they do not exclusively unlock.

## The Core Principle

**Pay-for-convenience, not pay-to-win.**

### Acceptable monetization

- Cosmetics (skins, particles, emotes, pets)
- Time savers (2x coins, auto-collect, bigger inventory)
- Convenience (teleport-to-boss, skip-cutscene, stack multipliers)
- Expression (name tags, emotes, nicknames)

### Red lines (avoid)

- Power increases **> 20-30%** over free alternatives
- Exclusive weapons/abilities that are **objectively superior** and not obtainable through gameplay
- Pay-to-continue in competitive modes
- Paywalled progression where F2P grind is tuned to be "unreasonably slow"

Pay-to-win alienates free players, damages reputation, **reduces the overall player base**, and in the long run **decreases total revenue**. A broad, engaged free base is what the Discover algorithm (qPTR, Deep-PTR, co-play metrics) rewards, and it is the population that whales need for their spending to feel meaningful.

## Paid Random Items Policy (Lootbox Rules)

Roblox has enforced a paid random items policy since **August 8, 2019**. It is still the basis for lootbox moderation.

### The platform rule

> "Developers must indicate the actual numerical odds (such as a 30% chance) of what users may receive when they are buying a random virtual item in-game using Robux or other currency."

### Direct and indirect payment

The rule covers **both** paths:

- **Direct**: paying Robux for a random result (e.g., 100 R$ -> random pet).
- **Indirect**: paying Robux for an intermediate currency or token that is then used for a random result (e.g., Robux -> gems -> gacha roll). Odds of the random step must still be disclosed.

### Exemptions

- **Gameplay-earned rewards**: if a player kills a monster and the drop is random, no disclosure is needed because no real currency was involved.
- **Cosmetic random packs with no Robux inflow**: same rationale.

The moment real-money flow touches the random step, odds must be disclosed.

### Visibility requirements

- Odds must be shown **before the transaction is committed** -- on the purchase UI, not buried in a tooltip.
- Each possible outcome should list its percentage:
  > Common 50%, Uncommon 25%, Rare 15%, Epic 8%, Legendary 2%
- Sub-tables (within a rarity bucket, which specific item you get) should also be disclosed if they involve randomness.

### Per-player policy enforcement

Use `PolicyService:GetPolicyInfoForPlayerAsync()` to check per-player restrictions:

- `ArePaidRandomItemsRestricted` -- when `true`, the player **cannot** interact with paid random item generators (via in-experience currency bought with Robux or Robux directly).
- `IsPaidItemTradingAllowed` -- when `true`, the player can trade virtual items purchased with in-experience currency or Robux.

## Regional Regulatory Landscape

| Region | Regulation |
|--------|------------|
| Belgium | **Paid loot boxes banned** as gambling |
| UK | Restricted for users under 18 |
| Netherlands | Hostile, case-by-case enforcement |
| EU | **Digital Fairness Act** targets gambling-like game features |

If shipping globally, the strictest region governs. Many studios default to "no paid random boxes at all" to avoid liability.

## Weighted Chance System (Luau)

```lua
local function rollWeighted(items)
    -- items: { { name = "Common", weight = 50, reward = ... }, ... }
    local total = 0
    for _, item in ipairs(items) do
        total += item.weight
    end

    local rng = math.random() * total
    local cumulative = 0
    for _, item in ipairs(items) do
        cumulative += item.weight
        if rng <= cumulative then
            return item
        end
    end
    return items[#items]  -- fallback
end
```

## Pity System Implementation

Guarantee rare drops after N opens to prevent frustration spirals:

```lua
local PITY_RARE = 50   -- Guarantee "Rare" every 50 paid rolls
local PITY_LEG  = 200  -- Guarantee "Legendary" every 200 paid rolls

local function rollWithPity(player, items)
    local pityRare = player:GetAttribute("PityRare") or 0
    local pityLeg  = player:GetAttribute("PityLegendary") or 0

    pityRare += 1
    pityLeg  += 1

    local forced
    if pityLeg >= PITY_LEG then
        forced = "Legendary"
        pityLeg = 0
        pityRare = 0
    elseif pityRare >= PITY_RARE then
        forced = "Rare"
        pityRare = 0
    end

    local result
    if forced then
        for _, it in ipairs(items) do
            if it.name == forced then result = it break end
        end
    else
        result = rollWeighted(items)
    end

    if result.name == "Legendary" then pityLeg = 0 end
    if result.name == "Rare" then pityRare = 0 end

    player:SetAttribute("PityRare", pityRare)
    player:SetAttribute("PityLegendary", pityLeg)
    return result
end
```

## Odds Display in UI

Show the rate table to the player before any paid random purchase:

```lua
local RATE_TABLE = {
    { name = "Common",    weight = 50, display = "50%" },
    { name = "Uncommon",  weight = 25, display = "25%" },
    { name = "Rare",      weight = 15, display = "15%" },
    { name = "Epic",      weight = 8,  display = "8%"  },
    { name = "Legendary", weight = 2,  display = "2%"  },
}

local function renderOddsLabel(parent)
    local frame = Instance.new("Frame", parent)
    for _, row in ipairs(RATE_TABLE) do
        local label = Instance.new("TextLabel", frame)
        label.Text = row.name .. ": " .. row.display
    end
end
```

## FOMO: Healthy vs Unhealthy

### Healthy limited-time content

- Seasonal cosmetics that **return annually** (e.g., Summer Bundle 2026 comes back in 2027)
- Effort-based event rewards (play 5 matches -> earn item)
- Rotating shops where items eventually cycle back
- Limited-time **modes** (not items) for unique experiences

### Unhealthy FOMO

- "One-time-only" items that never return
- Time-pressure + random mechanics + high cost combined
- Prompts at emotional peaks (after a loss, mid-fight)
- "Last chance!" countdowns designed to trigger impulse purchases
- Requiring excessive play during a short window

## Age-Appropriate Guardrails

Roblox's audience includes minors. Even games not explicitly targeting children should implement:

| Guardrail | Implementation |
|-----------|---------------|
| Cap maximum useful spend | After a ceiling, extra spending produces no meaningful benefit |
| Accessible entry prices | 25-99 R$ for first items |
| Cool-down periods | Delay between large purchases |
| Diminishing returns | Stacking excessive buys yields less value |
| Clear value communication | Describe exactly what the player gets before every purchase |
| No emotional-moment prompts | Do not trigger purchase UIs after deaths, losses, or mid-excitement |

## COPPA Context

Roblox has faced COPPA-related legal action (Texas AG case, class-action lawsuits). The platform positions parents as responsible for account settings, but courts and regulators have pushed back. Developer responsibilities:

- Do not design mechanics that **deliberately exploit** impulse control weaknesses of young players.
- Do not promote **gambling-like mechanics** even if Roblox permits them.
- Follow platform rules on **clear odds disclosure**.
- Expect regulatory tightening. Build under 2027 standards now, not 2024.

## Why Ethics Is Good Business

- **Regulators** punish predatory mechanics with bans and fines.
- **Platform algorithms derank** titles with high short-term monetization but low retention -- the Discover algorithm weighs 7-day retention heavily.
- **Parents** who see "safe" games let kids return.
- **Viral word-of-mouth** is easier for games with a good reputation.
- **Long-tail LTV** from loyal players exceeds burn-and-churn whale tactics.

## Ethical Design Checklist

For any paid random system:

- [ ] Publish actual server-side weights (not "up to X%")
- [ ] Implement pity systems -- guarantee a rare after N opens
- [ ] Offer direct-buy alternatives so players can just buy what they want
- [ ] Cap total useful spend -- after some point, extra rolls give zero marginal value
- [ ] Audit drops via `AnalyticsService` -- verify displayed odds match actual play
- [ ] Never combine timer pressure + random + high cost (textbook predatory pattern)
- [ ] Check `PolicyService:GetPolicyInfoForPlayerAsync()` for per-player restrictions

For all monetization:

- [ ] Power differential between paid and free is <= 20-30%
- [ ] Free players have a complete, enjoyable core experience
- [ ] Entry price tier is 25-99 R$ for onboarding accessibility
- [ ] No purchase prompts during emotional moments
- [ ] Seasonal/limited items return in future cycles
- [ ] Clear value descriptions before every purchase

## Concrete Numbers

| Parameter | Value |
|-----------|-------|
| Power differential cap | <= 20-30% above free alternatives |
| Mandatory odds disclosure | Before any purchase yielding random results |
| Typical pity system threshold | Rare every ~50 opens, Legendary every ~200 opens |
| Entry price tier | 25-99 R$ |
| FTUE target | Fun in < 5 minutes, core loop before complexity |
| Daily reward cycle | 7-14 days with escalating value |
| Streak protection | Allow 1 miss per cycle |

## Pitfalls

- Assuming "Roblox allows it" means it is ethical. Platform rules are the floor, not the ceiling.
- Hiding odds in settings menus instead of on the purchase UI.
- Combining scarcity + randomness + real-money cost. This is the exact pattern regulators target.
- Designing "unreasonably slow" F2P progression to push purchases. This backfires via retention loss and algorithm deranking.
- Not auditing actual drop rates against displayed odds. Mismatches invite regulatory action.

## Related

- [[game-pass]]
- [[dev-product]]
- [[robux-price-tiers]]
- [[premium-benefits]]

## Sources

- [Ethical Monetization Principles](../raw/community/monetization/ethics/ethical-monetization-principles.md) -- community guide on ethics, FOMO, and COPPA
- [Paid Random Items Policy](../raw/community/monetization/ethics/paid-random-items-policy.md) -- Roblox lootbox policy, weighted chance code, pity systems
- [Virtual Item Policies (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/virtual-items.md) -- official odds disclosure and per-player policy enforcement
