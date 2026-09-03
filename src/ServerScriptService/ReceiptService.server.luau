--==============================================================
-- ReceiptService  (Server Script - ServerScriptService)
--
-- The single owner of MarketplaceService.ProcessReceipt (B4). Only one script
-- may set it; CombatServer's B1 stub was removed in favour of this.
--
-- Idempotency has two guards:
--   1. a dedicated DataStore key  "receipt_<PurchaseId>"  (cross-server / player-absent)
--   2. profile.processedReceipts[<PurchaseId>]            (via PlayerDataService.grantPurchase)
--
-- Flow (no unconditional return; pcall around every external call):
--   player absent          -> NotProcessedYet
--   receipt key lookup fails-> NotProcessedYet   (never grant unverified)
--   receipt key present     -> PurchaseGranted   (idempotent)
--   unknown ProductId       -> NotProcessedYet + warn  (config drift; never eat money)
--   grant no_session/failed -> NotProcessedYet
--   grant ok / already      -> write receipt key (retry) then PurchaseGranted
--   receipt key write fails -> NotProcessedYet   (guards above keep it single-credit)
--
-- Source: design/economy/monetization.md 2, 3.3
--==============================================================

local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProductConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProductConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local RECEIPT_STORE = nil
local receiptStoreOk, receiptStoreOrError = pcall(function()
    return DataStoreService:GetDataStore("FoG_Receipts_v1")
end)
if receiptStoreOk then
    RECEIPT_STORE = receiptStoreOrError
else
    warn("[ReceiptService] receipt DataStore unavailable at startup: " .. tostring(receiptStoreOrError))
end
local RECEIPT_WRITE_RETRIES = 5

local function receiptKey(purchaseId: string): string
    return "receipt_" .. purchaseId
end

-- Returns (seen: boolean, lookupOk: boolean).
local function receiptSeen(purchaseId: string): (boolean, boolean)
    if not RECEIPT_STORE then return false, false end
    local ok, value = pcall(function()
        return RECEIPT_STORE:GetAsync(receiptKey(purchaseId))
    end)
    if not ok then
        warn(("[ReceiptService] GetAsync failed for %s: %s"):format(purchaseId, tostring(value)))
        return false, false
    end
    return value ~= nil, true
end

local function writeReceipt(purchaseId: string, receiptInfo): boolean
    if not RECEIPT_STORE then return false end
    for attempt = 1, RECEIPT_WRITE_RETRIES do
        local ok, err = pcall(function()
            RECEIPT_STORE:SetAsync(receiptKey(purchaseId), {
                userId = receiptInfo.PlayerId,
                productId = receiptInfo.ProductId,
                grantedAt = os.time(),
            })
        end)
        if ok then
            return true
        end
        warn(("[ReceiptService] SetAsync attempt %d failed for %s: %s")
            :format(attempt, purchaseId, tostring(err)))
        task.wait(math.min(8, 2 ^ attempt))
    end
    return false
end

-- Pure mutation of the profile for a resolved product effect.
local function applyEffect(profile, effect)
    local kind = effect.kind
    if kind == "gems" then
        profile.gemmes = (profile.gemmes or 0) + (effect.gems or 0)
    elseif kind == "fusionTokens" then
        profile.fusionTokens = (profile.fusionTokens or 0) + (effect.tokens or 0)
    elseif kind == "passTier" then
        profile.passTierCredits = (profile.passTierCredits or 0) + (effect.tiers or 0)
    elseif kind == "rename" then
        profile.renameCredits = (profile.renameCredits or 0) + 1
    elseif kind == "boost" then
        local b = effect.boost
        if b then
            profile.boosts = profile.boosts or {}
            local expiresAt = os.time() + b.durationSec
            for _, category in ipairs(b.categories) do
                local current = profile.boosts[category]
                -- Keep the better of an existing boost and this one (never stack).
                if not current or current.mult < b.mult or (current.expiresAt or 0) < expiresAt then
                    profile.boosts[category] = { mult = b.mult, expiresAt = expiresAt }
                end
            end
        end
    elseif kind == "cosmeticChest" or kind == "supporterPack" then
        profile.unclaimedProducts = profile.unclaimedProducts or {}
        table.insert(profile.unclaimedProducts, {
            kind = kind, chests = effect.chests, gems = effect.gems,
        })
        if effect.gems and kind == "supporterPack" then
            profile.gemmes = (profile.gemmes or 0) + effect.gems
        end
    else
        warn("[ReceiptService] unhandled effect kind: " .. tostring(kind))
    end
end

local function notifyClient(player: Player, entry)
    local combatEvent = ReplicatedStorage:FindFirstChild("CombatEvent")
    if not combatEvent then return end
    pcall(function()
        combatEvent:FireClient(player, {
            type = "purchaseGranted",
            product = entry.key,
            name = entry.name,
        })
    end)
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local purchaseId = tostring(receiptInfo.PurchaseId)

    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local seen, lookupOk = receiptSeen(purchaseId)
    if seen then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    if not lookupOk then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local entry = ProductConfig.byId[receiptInfo.ProductId]
    if not entry then
        warn(("[ReceiptService] unknown ProductId %s (purchase %s) - deferring")
            :format(tostring(receiptInfo.ProductId), purchaseId))
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local status = PlayerDataService.grantPurchase(player, purchaseId, function(profile)
        applyEffect(profile, entry.effect)
    end)
    if status == "no_session" or status == "save_failed" then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if not writeReceipt(purchaseId, receiptInfo) then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if status == "granted" then
        notifyClient(player, entry)
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end
