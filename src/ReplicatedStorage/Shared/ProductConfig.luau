--==============================================================
-- ProductConfig  (ModuleScript - ReplicatedStorage/Shared)
--
-- Developer Product registry: product ids + the effect each one grants.
-- Not secret (the client needs this to render the shop later), so it lives
-- in Shared. The SERVER is the only place effects are applied
-- (ReceiptService -> PlayerDataService.grantPurchase).
--
-- The Roblox account was just un-banned; NONE of these products exist in the
-- Creator Dashboard yet, so every `ids` entry is 0. Track I fills them in.
-- `byId` is built from `ids` + `catalogue`, skipping id 0, so an unset product
-- simply isn't resolvable and ProcessReceipt returns NotProcessedYet + warns.
--
-- Source: design/economy/monetization.md 3.3
--==============================================================

export type EffectKind =
    "gems" | "boost" | "fusionTokens" | "passTier" | "rename"
    | "cosmeticChest" | "supporterPack"

export type ProductEffect = {
    kind: EffectKind,
    gems: number?,
    tokens: number?,
    tiers: number?,
    chests: number?,
    boost: { mult: number, categories: { string }, durationSec: number }?,
}

export type CatalogueEntry = {
    name: string,
    effect: ProductEffect,
}

local WEEKEND_BOOST_SECONDS = 48 * 3600

-- key -> definition. Balance-neutral product data (gem counts, boost length)
-- comes straight from monetization.md 3.3, not from Track D's tuning curves.
local catalogue: { [string]: CatalogueEntry } = {
    gemBagS  = { name = "Sac de gemmes S",  effect = { kind = "gems", gems = 90 } },
    gemBagM  = { name = "Sac de gemmes M",  effect = { kind = "gems", gems = 520 } },
    gemBagL  = { name = "Sac de gemmes L",  effect = { kind = "gems", gems = 1150 } },
    gemBagXL = { name = "Sac de gemmes XL", effect = { kind = "gems", gems = 2650 } },

    boostWeekend = {
        name = "Boost Week-end x2 48 h",
        effect = {
            kind = "boost",
            boost = { mult = 2, categories = { "xp", "gold", "loot" }, durationSec = WEEKEND_BOOST_SECONDS },
        },
    },

    fusionTokens5 = { name = "Jetons de Fusion x5", effect = { kind = "fusionTokens", tokens = 5 } },
    rename        = { name = "Renommage / Titre custom", effect = { kind = "rename" } },

    passTier1 = { name = "Palier de Pass x1", effect = { kind = "passTier", tiers = 1 } },
    passTier5 = { name = "Palier de Pass x5", effect = { kind = "passTier", tiers = 5 } },

    cosmeticChest1 = { name = "Coffre Cosmetique x1", effect = { kind = "cosmeticChest", chests = 1 } },
    cosmeticChest6 = { name = "Coffre Cosmetique 5+1", effect = { kind = "cosmeticChest", chests = 6 } },

    supporterPack = {
        name = "Supporter Pack saisonnier",
        effect = { kind = "supporterPack", chests = 1, gems = 500 },
    },
}

-- key -> Roblox Developer Product id. Track I fills these from the dashboard.
local ids: { [string]: number } = {
    gemBagS = 0, gemBagM = 0, gemBagL = 0, gemBagXL = 0,
    boostWeekend = 0,
    fusionTokens5 = 0,
    rename = 0,
    passTier1 = 0, passTier5 = 0,
    cosmeticChest1 = 0, cosmeticChest6 = 0,
    supporterPack = 0,
}

local ProductConfig = {}

ProductConfig.catalogue = catalogue
ProductConfig.ids = ids

-- productId -> { key, name, effect }. Only contains products with a real id.
ProductConfig.byId = {} :: { [number]: { key: string, name: string, effect: ProductEffect } }
for key, productId in pairs(ids) do
    if productId ~= 0 then
        local entry = catalogue[key]
        if entry then
            ProductConfig.byId[productId] = { key = key, name = entry.name, effect = entry.effect }
        end
    end
end

return ProductConfig
