---
title: GamePass Setup, Verification, and Benefits Handling
type: raw-source
source_url: https://devforum.roblox.com/t/what-is-the-best-way-to-process-gamepasses/3453711
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: gamepass
tags: [gamepass, marketplaceservice, userowns, promptgamepass, verification]
---

# GamePass Setup, Verification, and Benefits Handling

GamePasses are persistent unlocks tied to a Roblox user id. Unlike
Developer Products, there is **no ProcessReceipt callback** for
GamePasses — you cannot grant rewards from a reliable server-side
event. Instead you use **UserOwnsGamePassAsync** as the source of truth
and **PromptGamePassPurchaseFinished** only for in-session UX.

## The two code paths

Every GamePass benefit must be wired on **both** paths:

1. **On player join** — check `UserOwnsGamePassAsync` for each
   pass id your game cares about, apply benefits if owned.
2. **On in-session purchase** — listen for
   `PromptGamePassPurchaseFinished`, apply benefits immediately
   without making the player rejoin.

If you skip (1), players who purchased on a previous day don't get
their perks. If you skip (2), players must rejoin after buying.

## Hard rules

- **Never use `ProcessReceipt` for GamePasses.** It only fires for
  Developer Products.
- **Never trust `PromptGamePassPurchaseFinished` alone.** The client
  can lose the event if they disconnect mid-dialog.
- **Cache ownership per session** to avoid hot-calling Roblox APIs on
  every ability use.
- **`UserOwnsGamePassAsync` is async** and can throw — always pcall.

## Code

### ModuleScript: GamePassService

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local GamePassService = {}
GamePassService.Passes = {
    VIP       = 111111111,
    DoubleXP  = 222222222,
    BigBag    = 333333333,
}

-- Cache: [userId][passId] = bool
local Ownership = setmetatable({}, { __mode = "k" })

local function getOwnershipTable(player)
    Ownership[player] = Ownership[player] or {}
    return Ownership[player]
end

-- Pcall wrapper around Roblox's async check.
local function checkOwnership(userId, passId)
    local ok, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
    end)
    if not ok then
        warn("UserOwnsGamePassAsync failed:", result)
        return false
    end
    return result == true
end

function GamePassService.Owns(player, passId)
    local cache = getOwnershipTable(player)
    if cache[passId] == nil then
        cache[passId] = checkOwnership(player.UserId, passId)
    end
    return cache[passId]
end

-- Apply benefits for every pass the player owns at join time.
function GamePassService.ApplyBenefitsOnJoin(player)
    for name, id in pairs(GamePassService.Passes) do
        if GamePassService.Owns(player, id) then
            GamePassService.Grant(player, id)
        end
    end
end

-- Apply the actual perk for a passId. Edit per your game.
function GamePassService.Grant(player, passId)
    if passId == GamePassService.Passes.VIP then
        player:SetAttribute("VIP", true)
    elseif passId == GamePassService.Passes.DoubleXP then
        player:SetAttribute("XPMultiplier", 2)
    elseif passId == GamePassService.Passes.BigBag then
        player:SetAttribute("InventorySize", 100)
    end
end

Players.PlayerAdded:Connect(function(player)
    GamePassService.ApplyBenefitsOnJoin(player)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(
    function(player, passId, wasPurchased)
        if wasPurchased then
            -- Invalidate cache so next Owns() call re-checks.
            Ownership[player] = Ownership[player] or {}
            Ownership[player][passId] = true
            GamePassService.Grant(player, passId)
        end
    end
)

return GamePassService
```

### Client-side purchase prompt

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local VIP_PASS = 111111111
local buyButton = script.Parent

buyButton.Activated:Connect(function()
    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, VIP_PASS)
end)
```

## GetGamePassProductInfo — pricing

Use `GetProductInfo(passId, Enum.InfoType.GamePass)` to fetch the
current price and name — lets you build a dynamic shop UI that stays
in sync with Roblox's pricing:

```lua
local MarketplaceService = game:GetService("MarketplaceService")

local ok, info = pcall(function()
    return MarketplaceService:GetProductInfo(111111111, Enum.InfoType.GamePass)
end)

if ok and info then
    -- info.PriceInRobux, info.Name, info.Description, info.IconImageAssetId
    print(info.Name, "costs", info.PriceInRobux, "R$")
end
```

## Concrete Numbers / Examples

- `MarketplaceService:UserOwnsGamePassAsync(userId, passId)` — always
  pcall, cache the result per session.
- `MarketplaceService.PromptGamePassPurchaseFinished` signature:
  `(player, passId, wasPurchased)`.
- `ProcessReceipt` does **NOT** fire for GamePasses. Never.
- `GetProductInfo(passId, Enum.InfoType.GamePass)` returns
  `PriceInRobux`, `Name`, `Description`, `IconImageAssetId`.

## Source

Original URL: https://devforum.roblox.com/t/what-is-the-best-way-to-process-gamepasses/3453711
Related: https://robloxapi.github.io/ref/class/MarketplaceService.html
Captured: 2026-04-16
