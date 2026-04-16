---
title: Paid Random Items Policy - Lootbox Rules
type: raw-source
source_url: https://devforum.roblox.com/t/guidelines-around-users-paying-for-random-virtual-items/307189
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: ethics
tags: [lootbox, odds, policy, compliance, random-items, pity, weighted-chance]
---

# Paid Random Items Policy — Lootbox Rules

Roblox has an enforced policy around paid random items. The policy has
been live since **August 8, 2019** and is still the basis for lootbox
moderation today.

## The rule (Roblox platform policy)

> "Developers must indicate the actual numerical odds (such as a 30%
> chance) of what users may receive when they are buying a random
> virtual item in-game using Robux or other currency."

## Direct and indirect payment

The rule covers **direct and indirect** payment paths:

- **Direct**: paying Robux for a random result (e.g. 100 R$ → random pet).
- **Indirect**: paying Robux for an intermediate currency or token
  that is then used for a random result (e.g. Robux → gems → gacha
  roll). You must still disclose the odds of the random step.

## Exemptions

- **Gameplay-earned rewards** — if a player kills a monster and the
  drop is random, you do NOT need to disclose odds because no real
  currency was paid.
- **Cosmetic random packs with no Robux inflow** — same rationale.

The moment real-money flow touches the random step, odds must be
disclosed.

## Visibility requirements

- Odds must be shown **before the transaction is committed** — i.e.
  on the purchase UI, not buried in a tooltip or menu deep in settings.
- Forum guidance: "before the user throws the virtual coin into the
  fountain."
- Each possible outcome should list its percentage. A list like:
  > Common 50%, Uncommon 25%, Rare 15%, Epic 8%, Legendary 2%
  is the format Roblox expects.
- Sub-tables (within the Uncommon bucket, which specific pet you get)
  should also be disclosed if they involve randomness.

## Regional regulatory context

Beyond Roblox's policy, regional laws also apply:

| Region | Rule |
|--------|------|
| Belgium | Paid lootboxes BANNED as gambling |
| UK | Restricted for users under 18 |
| Netherlands | Enforcement is active, case-by-case |
| EU | Digital Fairness Act targets gambling-like design |

If you ship globally, the strictest region governs. Many studios
default to "no paid random boxes at all" to avoid the liability.

## Code

### Weighted chance system (Luau)

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
    return items[#items]  -- fallback, should never trigger
end
```

### Pity-system wrapper

```lua
-- Every 50 paid rolls guarantees at least a "Rare" drop.
-- Every 200 paid rolls guarantees at least a "Legendary" drop.
local PITY_RARE = 50
local PITY_LEG  = 200

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

### UI display of odds (approximate)

```lua
-- Show the actual odds from the server-owned rate table.
local RARE_TABLE = {
    { name = "Common",    weight = 50, display = "50%" },
    { name = "Uncommon",  weight = 25, display = "25%" },
    { name = "Rare",      weight = 15, display = "15%" },
    { name = "Epic",      weight = 8,  display = "8%"  },
    { name = "Legendary", weight = 2,  display = "2%"  },
}

local function renderOddsLabel(parent)
    local frame = Instance.new("Frame", parent)
    for _, row in ipairs(RARE_TABLE) do
        local label = Instance.new("TextLabel", frame)
        label.Text = row.name .. ": " .. row.display
    end
end
```

## Ethical design considerations

Beyond compliance, best practices for paid randoms:

- **Publish the actual server-side weights**, not "up to X%".
- **Implement pity systems** — guarantee a rare after N opens.
- **Offer direct-buy alternatives** — let players just buy the thing
  they want. Random-only forces grind.
- **Cap the total useful spend** — after some point, extra rolls should
  give zero marginal value (e.g. you already have the Legendary, more
  rolls give duplicates that dust into nothing).
- **Audit drops** — log every roll to AnalyticsService so you can
  verify the displayed odds match actual play.
- **Do not combine** timer pressure + random + high cost. That is
  the textbook predatory pattern regulators ban.

## Source

Original URL: https://devforum.roblox.com/t/guidelines-around-users-paying-for-random-virtual-items/307189
Related: https://devforum.roblox.com/t/weighted-chance-system/1373953
Captured: 2026-04-16
