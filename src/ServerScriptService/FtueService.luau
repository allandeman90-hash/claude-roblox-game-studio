-- FtueService
--
-- Server-authoritative First-Time User Experience (onboarding-gdd.md).
--
-- Short tutorial, 4 beats:
--   1. "move"    - spawn coach-mark: hold </> to walk. Player acks it (or it
--                  auto-dismisses client-side) -> step advances to "kill".
--   2. "kill"    - server-detected: the first monster killed (bare-handed).
--                  Grants the "Épée en bois" into the bag, shows the "equip"
--                  coach-mark. -> step "equip".
--   3. "equip"   - server-detected: a weapon is now in the arme slot.
--                  Shows the "the game is hard" warning panel. -> step "warning".
--   4. "warning" - player acks the panel -> tutorial completes, the "Fée"
--                  starter pet is granted + equipped, gift window shown.
--
-- A coach-mark never blocks input. The client only renders what this service
-- tells it to; it never advances the flow on its own guess of the state.
--
-- Transport: multiplexed over the existing ReplicatedStorage.CombatEvent
-- RemoteEvent (same pattern as the Inventory Sprint), message shapes:
--   S->C  { type = "ftueState", ftue = <FtueState> }
--   S->C  { type = "ftueStep",  stepId = "move"|"equip"|"warning" }
--   S->C  { type = "ftueGift",  petId = "fee" }
--   C->S  { type = "ftueAck",   stepId = "move"|"warning" }   (dispatched by CombatServer)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerDataService = require(ServerScriptService:WaitForChild("PlayerDataService"))

local FtueService = {}

-- Steps the client is allowed to ACK. "kill" and "equip" are resolved by real
-- server events, never by a client message.
local ACKABLE: { [string]: boolean } = {
    move = true,
    pet = true,
    warning = true,
}

local function remote(): RemoteEvent?
    return ReplicatedStorage:FindFirstChild("CombatEvent") :: RemoteEvent?
end

local function push(player: Player, payload: any)
    local r = remote()
    if r then
        r:FireClient(player, payload)
    end
end

-- (profile, ftue) or (nil, nil) if the profile is not loaded yet.
local function ftueOf(player: Player)
    local profile = PlayerDataService.getProfile(player)
    if type(profile) ~= "table" or type(profile.ftue) ~= "table" then
        return nil, nil
    end
    return profile, profile.ftue
end

--[[
    Called from CombatServer.startCombat once the profile is loaded. Sends the
    current FTUE state and, if the tutorial is unfinished, (re)issues the
    coach-mark for the step the player is on - so a disconnect mid-tutorial
    resumes exactly where it left off (edge case: never restart the flow).
]]
function FtueService.onSpawn(player: Player)
    local _, ftue = ftueOf(player)
    if not ftue then
        return
    end
    push(player, { type = "ftueState", ftue = ftue })
    if ftue.completed then
        return
    end
    if ftue.step == "move" then
        push(player, { type = "ftueStep", stepId = "move" })
    elseif ftue.step == "equip" then
        push(player, { type = "ftueStep", stepId = "equip" })
    elseif ftue.step == "pet" then
        -- Only re-offer the egg choice if the player hasn't picked yet; once a
        -- pet is granted, a reconnect resumes straight at the closing panel.
        if ftue.petGranted then
            push(player, { type = "ftueStep", stepId = "warning" })
        else
            push(player, { type = "ftueGift" })
        end
    elseif ftue.step == "warning" then
        push(player, { type = "ftueStep", stepId = "warning" })
    end
end

--[[
    C->S ack, revalidated here. A stepId that is not ACKABLE, or does not match
    the step the player is actually on, is a silent no-op (never an error).
]]
function FtueService.ackStep(player: Player, stepId: any)
    local profile, ftue = ftueOf(player)
    if not ftue or ftue.completed then
        return
    end
    if type(stepId) ~= "string" or not ACKABLE[stepId] or stepId ~= ftue.step then
        return
    end

    if stepId == "move" then
        ftue.step = "kill"
        PlayerDataService.markDirty(player, profile)
    elseif stepId == "pet" then
        -- pet hatched + its briefing read -> show the closing "how to get stronger" panel
        ftue.step = "warning"
        PlayerDataService.markDirty(player, profile)
        push(player, { type = "ftueStep", stepId = "warning" })
    elseif stepId == "warning" then
        FtueService._complete(player, profile, ftue)
    end
end

--[[
    Server event: the player just scored their first kill. Advances past "move"
    (whether or not the coach-mark was acked) and "kill", grants the starter
    weapon into the bag (NOT auto-equipped - the point of the next beat is that
    the player equips it), then shows the "equip" coach-mark.
]]
function FtueService.onFirstKill(player: Player)
    local profile, ftue = ftueOf(player)
    if not ftue or ftue.completed then
        return
    end
    if ftue.step ~= "move" and ftue.step ~= "kill" then
        return
    end

    local InventoryService = require(ServerScriptService:WaitForChild("InventoryService"))
    pcall(InventoryService.grantStarterKit, player, false)

    ftue.step = "equip"
    PlayerDataService.markDirty(player, profile)
    push(player, { type = "ftueStep", stepId = "equip" })
end

--[[
    Server event: an equip just succeeded. If the tutorial is waiting on the
    "equip" beat AND a weapon is now in the arme slot, advance to the "the game
    is hard" warning.
]]
function FtueService.onEquip(player: Player)
    local profile, ftue = ftueOf(player)
    if not ftue or ftue.completed or ftue.step ~= "equip" then
        return
    end

    -- InventoryService.equipItem mirrors the equipped weapon into this
    -- denormalized index (spec §5.1), so it is the reliable "is a weapon on?"
    -- signal here.
    local hasWeapon = type(profile.inventory) == "table"
        and type(profile.inventory.equipped) == "table"
        and profile.inventory.equipped.arme ~= nil
    if not hasWeapon then
        return
    end

    -- The weapon is on: show the "choose your egg" screen. The pet is granted
    -- only once the player picks one (FtueService.choosePet). The closing
    -- "how to get stronger" panel comes after they ack the pet card.
    ftue.step = "pet"
    PlayerDataService.markDirty(player, profile)
    push(player, { type = "ftueGift" })
end

--[[
    C->S: the player picked one of the three FTUE eggs. Grants + equips a
    starter pet of that role. Idempotent, and only valid on the "pet" beat.
]]
function FtueService.choosePet(player: Player, role: any)
    local profile, ftue = ftueOf(player)
    if not ftue or ftue.completed or ftue.step ~= "pet" then
        return
    end
    if role ~= "dps" and role ~= "tank" and role ~= "heal" then
        role = "dps"
    end
    if not ftue.petGranted then
        local InventoryService = require(ServerScriptService:WaitForChild("InventoryService"))
        local ok = pcall(InventoryService.grantStarterPet, player, role)
        ftue.petGranted = ok == true
        ftue.chosenPetRole = role
        PlayerDataService.markDirty(player, profile)
    end
end

function FtueService._complete(player: Player, profile: any, ftue: any)
    if ftue.completed then
        return
    end

    -- Safety net: if the player somehow reached the end without picking an egg,
    -- grant the default (DPS) starter pet.
    if not ftue.petGranted then
        local InventoryService = require(ServerScriptService:WaitForChild("InventoryService"))
        local ok = pcall(InventoryService.grantStarterPet, player, "dps")
        ftue.petGranted = ok == true
    end

    ftue.step = "done"
    ftue.completed = true
    ftue.completedAt = os.time()
    PlayerDataService.markDirty(player, profile)

    push(player, { type = "ftueState", ftue = ftue })
end

-- Pure read: are monetization prompts suppressed for this player right now?
-- (onboarding-gdd §2.4 - the actual prompt code checks this.)
function FtueService.monetizationSuppressed(player: Player): boolean
    if not GameConfig.Ftue.suppressMonetizationUntilComplete then
        return false
    end
    local _, ftue = ftueOf(player)
    return ftue ~= nil and not ftue.completed
end

return FtueService
