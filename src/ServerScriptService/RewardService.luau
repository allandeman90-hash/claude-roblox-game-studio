--==============================================================
-- RewardService  (ModuleScript - ServerScriptService)
--
-- The SINGLE resolver for reward multipliers (B5, monetization.md 2).
-- Server-only. Called from exactly one place per reward flow
-- (CombatServer.resolvePlayerHit for xp / gold / loot / petLoot).
--
--   multiplier(player, cat, ctx) =
--       comfort(cat)  = min(cap, max( permanent pass, premium season,
--                                     temp boost, Roblox Premium ))
--       earned(cat)   = Nightmare.rewardMult(ctx.nightmareTier)
--                       * rebirthBonus[cat](ctx.rebirths)
--                       * CodexService.rewardMult(profile, cat)
--       -> comfort * earned
--
-- Comfort uses max(), NEVER a product: a x2 pass + a x2 boost + premium = x3,
-- not x8. Earned categories multiply on purpose (both are gained in-game).
--
-- Game-pass ownership is cached per player, refreshed on
-- PromptGamePassPurchaseFinished, cleared on PlayerRemoving. Never a client bool.
--==============================================================

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local CodexService = require(script.Parent:WaitForChild("CodexService"))

local RewardService = {}

local CATEGORIES = { xp = true, gold = true, loot = true, petLoot = true }

-- [player] = { [gamePassId] = boolean }
local ownershipCache = {}

--===== Game-pass ownership (cached) =====
local function ownsPass(player: Player, passId: number): boolean
    if not passId or passId == 0 then
        return false
    end
    local byPlayer = ownershipCache[player]
    if not byPlayer then
        byPlayer = {}
        ownershipCache[player] = byPlayer
    end
    if byPlayer[passId] ~= nil then
        return byPlayer[passId]
    end
    local ok, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    local result = ok and owns == true
    byPlayer[passId] = result
    return result
end

--===== Comfort sources (all use max(), capped) =====

-- Highest permanent game-pass multiplier the player owns for this category.
local function permanentPassMult(player: Player, category: string): number
    local best = 1
    for _, pass in pairs(GameConfig.Rewards.permanentPasses) do
        local m = pass.mult and pass.mult[category]
        if m and m > best and ownsPass(player, pass.id) then
            best = m
        end
    end
    return best
end

local function premiumSeasonMult(player: Player, category: string): number
    local profile = PlayerDataService.getProfile(player)
    if not profile or profile.premiumSeason ~= true then
        return 1
    end
    local m = GameConfig.Rewards.premiumSeason.mult
    return (m and m[category]) or 1
end

-- Temporary boost stored server-side as { mult, expiresAt }. Expired -> ignored
-- (and pruned).
local function tempBoostMult(player: Player, category: string): number
    local profile = PlayerDataService.getProfile(player)
    if not profile or type(profile.boosts) ~= "table" then
        return 1
    end
    local entry = profile.boosts[category]
    if type(entry) ~= "table" then
        return 1
    end
    if (entry.expiresAt or 0) <= os.time() then
        profile.boosts[category] = nil
        return 1
    end
    return entry.mult or 1
end

local function premiumMembershipMult(player: Player, category: string): number
    if player.MembershipType ~= Enum.MembershipType.Premium then
        return 1
    end
    return GameConfig.Rewards.premiumMembership[category] or 1
end

--===== Earned sources (deliberately multiply) =====
local function rebirthBonus(category: string, rebirths: number): number
    local fn = GameConfig.Rewards.rebirthBonus[category]
    if type(fn) == "function" then
        return fn(math.max(0, rebirths or 0))
    end
    return 1
end

-- Codex family-completion bonus (codex-gdd.md SS2.5), Or/XP only - see
-- GameConfig.Codex header. Permanent, so it belongs with rebirth in
-- "earned", not with the timed/comfort sources above.
local function codexBonus(player: Player, category: string): number
    local profile = PlayerDataService.getProfile(player)
    if not profile then return 1 end
    return CodexService.rewardMult(profile, category)
end

--===== Public =====
-- ctx (optional): { rebirths = number, nightmareTier = number }. Any missing
-- field is treated as 0.
function RewardService.multiplier(player: Player, category: string, ctx: any): number
    if not CATEGORIES[category] then
        warn("[RewardService] unknown reward category: " .. tostring(category))
        return 1
    end
    ctx = ctx or {}

    local comfort = 1
    comfort = math.max(comfort, permanentPassMult(player, category))
    comfort = math.max(comfort, premiumSeasonMult(player, category))
    comfort = math.max(comfort, tempBoostMult(player, category))
    comfort = math.max(comfort, premiumMembershipMult(player, category))
    comfort = math.min(comfort, GameConfig.Rewards.categoryCap)

    local tier = tonumber(ctx.nightmareTier) or 0
    local nm = GameConfig.Nightmare
    local nightmareMult = (nm and nm.rewardMult and nm.rewardMult(tier)) or 1
    local earned = nightmareMult * rebirthBonus(category, tonumber(ctx.rebirths) or 0) * codexBonus(player, category)

    return comfort * earned
end

--===== Cache lifecycle =====
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    local byPlayer = ownershipCache[player]
    if not byPlayer then
        byPlayer = {}
        ownershipCache[player] = byPlayer
    end
    if wasPurchased then
        byPlayer[gamePassId] = true
    else
        byPlayer[gamePassId] = nil  -- force a re-check next read
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ownershipCache[player] = nil
end)

return RewardService
