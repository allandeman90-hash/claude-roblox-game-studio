--!strict
--==============================================================
-- InventoryClient  (LocalScript)
--
-- Central hub for all inventory-related UI: mounts InventoryScreen,
-- BagFullPrompt and AccessibilityScreen, owns the (session-local) uiPrefs
-- table, and is the SINGLE dispatcher for every inventory-shaped message on
-- the multiplexed CombatEvent (design/specs/inventory-implementation-spec.md
-- integration notes / this task's deliverable #2).
--
-- Deliberate deviations from the literal task brief, kept here instead of
-- CombatServer.server.luau / CombatClient.client.luau per the task's own
-- "Do NOT touch CombatServer" / "no new remotes" constraints - both were
-- required to match the REAL, already-implemented server contract:
--
--   1. No "bag_full" message type exists. CombatServer's loot handler
--      already reuses "loot" for this: a rejected drop arrives as
--        { type = "loot", item = <draft>, kept = false, reason = "bag_full" }.
--      This script treats that combination as the BagFullPrompt trigger.
--      See BagFullPrompt.luau's header comment for the full contract.
--   2. No "inventoryUpdated" message type exists either. The real push/pull
--      contract is `{ type = "inventory", items?, capacity?, filters? }`
--      (CombatServer.server.luau's requestInventory / setFilters / toggleLock
--      branches). This script normalizes all three shapes.
--   3. CombatClient.client.luau was left UNTOUCHED (task deliverable #4 asked
--      for edits there). Routing "itemRemoved" / "equipError" /
--      "bagActionConfirmed" through a second independent listener here is
--      equivalent (Roblox RemoteEvents support multiple OnClientEvent
--      listeners) and avoids further bloating an already ~2000-line file
--      that owns an unrelated concern (the combat HUD). Flagged for
--      lead-programmer/ui-programmer review.
--
-- uiPrefs persistence gap: design/gdd/ui-ux-gdd.md §5 specifies
-- `Ui_SetPrefs`/`Ui_PrefsLoaded` remotes and server-side persistence.
-- Neither exists yet (Remotes.luau is an empty stub; no server script sets a
-- `uiPrefs` attribute). This script opportunistically reads
-- `player:GetAttribute("uiPrefs")` (a JSON string, if a future server sets
-- one) and listens for live changes, but otherwise keeps prefs SESSION-LOCAL
-- via GameConfig.Ui defaults. Not a silent gap - flagged for
-- remotes-networking-specialist / datastore-architect.
--==============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local StyleConstants = require(Shared:WaitForChild("StyleConstants"))
local BagFullPrompt = require(Shared:WaitForChild("BagFullPrompt"))
local InventoryScreen = require(Shared:WaitForChild("InventoryScreen"))
local AccessibilityScreen = require(Shared:WaitForChild("AccessibilityScreen"))
local Types = require(Shared:WaitForChild("Types"))

local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end
local rpgGui = playerGui:WaitForChild("RpgGui", 10) :: ScreenGui?
if not rpgGui then return end
local background = rpgGui:FindFirstChild("Background")

local combatEvent = ReplicatedStorage:WaitForChild("CombatEvent", 10) :: RemoteEvent?
if not combatEvent then return end

--===== uiPrefs (session-local; see header comment) =====
export type UiPrefs = {
    fontScale: number,
    colorblindMode: string,
    reducedMotion: boolean,
    highContrast: boolean,
    hudHand: string,
}

local uiPrefs: UiPrefs = {
    fontScale = GameConfig.Ui.fontScaleDefault,
    colorblindMode = "off",
    reducedMotion = false,
    highContrast = false,
    hudHand = "right",
}

local function getUiPrefs(): UiPrefs
    return uiPrefs
end

--===== Bag state cache =====
local bagItems: { [string]: Types.ItemInstance } = {}
local bagCapacity = GameConfig.Inventory.baseCapacity

local function getBagItems(): { [string]: Types.ItemInstance }
    return bagItems
end

--===== requestInventory debounce (shared budget: GameConfig.Security.remotePerType.requestInventory = 2/window) =====
local lastInventoryRequestAt = 0
local INVENTORY_REQUEST_DEBOUNCE = 0.3

local function requestInventoryRefresh()
    local now = os.clock()
    if now - lastInventoryRequestAt < INVENTORY_REQUEST_DEBOUNCE then return end
    lastInventoryRequestAt = now
    combatEvent:FireServer({ type = "requestInventory" })
end

--===== Mount the two bag-facing screens =====
local bagFullPrompt = BagFullPrompt.mount(rpgGui, combatEvent, {
    getBagItems = getBagItems,
    getUiPrefs = getUiPrefs,
})

local inventoryScreen = InventoryScreen.mount(rpgGui, combatEvent, {
    getUiPrefs = getUiPrefs,
    requestRefresh = requestInventoryRefresh,
})

--===== HUD inventory button =====
-- The main combat HUD owns the visual button so it can line up with MENU.
-- This script only adds an invisible hit target that opens the inventory.
local staleFloatingButtons = rpgGui:FindFirstChild("InventoryHudButtons")
if staleFloatingButtons then
    staleFloatingButtons:Destroy()
end

local function findOrCreateInventoryHudButton(): TextButton
    local visual: GuiObject? = nil
    local deadline = os.clock() + 5
    while os.clock() < deadline and not visual do
        local root = background
        local bottom = root and root:FindFirstChild("BottomPanel")
        local right = bottom and bottom:FindFirstChild("DescenteRight")
        local candidate = right and right:FindFirstChild("Inventory")
        if candidate and candidate:IsA("GuiObject") then
            visual = candidate
        else
            task.wait()
        end
    end

    if not visual then
        warn("[InventoryClient] Inventory HUD button was not found.")
        local inert = Instance.new("TextButton")
        inert.Name = "InventoryUnavailable"
        inert.Size = UDim2.fromOffset(0, 0)
        inert.BackgroundTransparency = 1
        inert.Text = ""
        inert.Visible = false
        inert.Parent = rpgGui
        return inert
    end

    local click = visual:FindFirstChild("Click")
    if click and click:IsA("TextButton") then
        return click
    end

    local button = Instance.new("TextButton")
    button.Name = "Click"
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Active = true
    button.AutoButtonColor = false
    button.ZIndex = visual.ZIndex + 1
    button.Parent = visual
    return button
end

local invHudBtn = findOrCreateInventoryHudButton()

--===== AccessibilityScreen (forward-declared: setPrefs/applyPrefsEverywhere =====
--===== close over this local and are only ever CALLED after it's assigned) =====
local accessibilityScreen: AccessibilityScreen.AccessibilityScreenApi? = nil

local function applyPrefsEverywhere()
    inventoryScreen.applyUiPrefs(uiPrefs)
    if accessibilityScreen then
        accessibilityScreen.refresh()
    end
end

local function setPrefs(partial: { [string]: any })
    for k, v in pairs(partial) do
        (uiPrefs :: any)[k] = v
    end
    applyPrefsEverywhere()
end

accessibilityScreen = AccessibilityScreen.mount(rpgGui, {
    getPrefs = getUiPrefs,
    setPrefs = setPrefs,
})

--===== Opportunistic server-set uiPrefs attribute (forward-compatible; see header) =====
local function tryLoadAttributePrefs()
    local raw = player:GetAttribute("uiPrefs")
    if type(raw) ~= "string" or raw == "" then return end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if ok and type(decoded) == "table" then
        setPrefs(decoded)
    end
end
tryLoadAttributePrefs()
player:GetAttributeChangedSignal("uiPrefs"):Connect(tryLoadAttributePrefs)

--===== Mutual exclusion with legacy overlays (EquipOverlay/ShopOverlay/ChateauOverlay) =====
local function closeLegacyOverlays()
    if not background then return end
    for _, name in ipairs({ "EquipOverlay", "ShopOverlay", "ChateauOverlay" }) do
        local overlay = background:FindFirstChild(name)
        if overlay and overlay:IsA("GuiObject") then
            overlay.Visible = false
        end
    end
end

invHudBtn.MouseButton1Click:Connect(function()
    if inventoryScreen.isOpen() then
        inventoryScreen.close()
        return
    end
    if accessibilityScreen then accessibilityScreen.close() end
    closeLegacyOverlays()
    inventoryScreen.open()
end)

--===== Tab key toggles the inventory screen (deliverable: "Tab key") =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Tab then
        if inventoryScreen.isOpen() then
            inventoryScreen.close()
        else
            if accessibilityScreen then accessibilityScreen.close() end
            closeLegacyOverlays()
            inventoryScreen.open()
        end
    end
end)

--===== Server message dispatcher (single connection, per header note #3) =====
combatEvent.OnClientEvent:Connect(function(data)
    if type(data) ~= "table" then return end

    if data.type == "inventory" then
        -- Three real shapes share this type (see header note #2):
        --   requestInventory reply : { items, capacity }
        --   setFilters reply       : { filters = {...} }
        --   toggleLock reply       : {} (bare nudge, no payload)
        if type(data.items) == "table" then
            bagItems = data.items
            bagCapacity = data.capacity or bagCapacity
            inventoryScreen.setInventoryData(bagItems, bagCapacity)
        end
        if type(data.filters) == "table" then
            inventoryScreen.setFilters(data.filters)
        end
        if data.items == nil and inventoryScreen.isOpen() then
            -- toggleLock / setFilters didn't include a fresh item list -
            -- pull one so the grid reflects the change (see header note #2).
            requestInventoryRefresh()
        end

    elseif data.type == "loot" and data.item and data.kept == false and data.reason == "bag_full" then
        -- See header note #1: this IS the bag-full trigger in the real
        -- contract. Deliberately does NOT show a loot toast here -
        -- CombatClient.client.luau's showLootToast already renders one for
        -- every "loot" message on the same RemoteEvent; duplicating it here
        -- would double the toast on screen.
        bagFullPrompt.show(data.item)

    elseif data.type == "itemRemoved" then
        if data.ok then
            requestInventoryRefresh()
        end
        -- Silent on failure beyond that (the InventoryScreen action bar
        -- already greys out SUPPRIMER for locked/equipped items so a
        -- legitimate player rarely hits this path).

    elseif data.type == "equipError" then
        -- Equip failed (in-combat weapon change, stale key, etc.) - refresh
        -- so a stale/removed card doesn't linger selected.
        if inventoryScreen.isOpen() then
            requestInventoryRefresh()
        end

    elseif data.type == "bagActionConfirmed" then
        bagFullPrompt.handleConfirmed(data.ok == true, data.reason)
        if data.ok then
            requestInventoryRefresh()
        end
    end
end)
