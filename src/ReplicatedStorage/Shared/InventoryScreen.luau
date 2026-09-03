--!strict
--==============================================================
-- InventoryScreen  (ModuleScript - ReplicatedStorage/Shared)
--
-- Full-screen bag browser (design/gdd/ui-ux-gdd.md §6.2 SCREEN layer,
-- design/specs/inventory-implementation-spec.md §8). Renders the player's
-- BAG items (profile.inventory.items - unequipped only; see note below),
-- with rarity-colored cards, forge-level + lock badges, slot/rarity/voie
-- filters, and equip/lock/remove actions.
--
-- Data model note (InventoryService.luau): an item that is currently
-- EQUIPPED is moved OUT of `inv.items` entirely (EquipmentService owns the
-- equipped copy). So this screen only ever renders unequipped bag items;
-- there is no "unequip from the grid" action here by design - unequip is
-- driven from the existing hero-panel / EquipOverlay slot UI in
-- CombatClient.client.luau. `equippedSlot` is still checked defensively on
-- every card (should always be nil for anything reaching this screen).
--
-- Networking: everything funnels through the existing multiplexed
-- `CombatEvent` (see CombatServer.server.luau) - NOT the dedicated
-- `Remotes.Inventory.*` RemoteEvents described in
-- design/specs/inventory-implementation-spec.md §7 (those were never wired
-- up; ReplicatedStorage/Shared/Remotes.luau is still an empty stub). This
-- module never listens to CombatEvent directly - InventoryClient.client.luau
-- (the single dispatcher) calls setInventoryData/setFilters on server
-- pushes, matching the "requestInventory" / "inventory" message contract
-- CombatServer.server.luau already implements.
--
-- Sorting: the spec (§3.4) says the SERVER owns sort order, but
-- InventoryService has no dedicated sort remote/param yet (Day 2 stub gap) -
-- this screen sorts client-side (rarity desc, then most recent first) as a
-- reasonable default until that lands. Flagged, not a silent deviation.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local EquipmentConfig = require(ReplicatedStorage:WaitForChild("EquipmentConfig"))
local StyleConstants = require(script.Parent:WaitForChild("StyleConstants"))
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

export type UiPrefs = {
    fontScale: number,
    colorblindMode: string,
    reducedMotion: boolean,
    highContrast: boolean,
    hudHand: string,
}

export type InventoryScreenDeps = {
    getUiPrefs: () -> UiPrefs,
    requestRefresh: () -> (), -- debounced "please re-send inventory" (InventoryClient owns the rate limit)
}

export type InventoryScreenApi = {
    open: () -> (),
    close: () -> (),
    toggle: () -> (),
    isOpen: () -> boolean,
    setInventoryData: (items: { [string]: Types.ItemInstance }, capacity: number) -> (),
    setFilters: (filters: { rareteMin: string?, guerrier: boolean?, mage: boolean? }) -> (),
    applyUiPrefs: (prefs: UiPrefs) -> (),
    destroy: () -> (),
}

local InventoryScreen = {}

-- ItemInstance.itemType (English, Types.luau) -> the 7-value slot filter the
-- task spec calls "voie" (all/arme/casque/plastron/jambieres/bottes/gants) -
-- actually a SLOT filter, kept client-local since InventoryService.setFilters
-- only accepts a real voie (guerrier/mage/all), not slot names. See
-- InventoryClient.client.luau header comment for the full reconciliation.
local ITEM_TYPE_TO_SLOT_TAB: { [string]: string } = {
    weapon = "arme", head = "casque", chest = "plastron",
    hands = "gants", legs = "jambieres", feet = "bottes",
}
local SLOT_TABS = { "all", "arme", "casque", "plastron", "jambieres", "bottes", "gants" }
local SLOT_TAB_LABELS: { [string]: string } = {
    all = "TOUS", arme = "ARME", casque = "CASQUE", plastron = "PLASTRON",
    jambieres = "JAMBIERES", bottes = "BOTTES", gants = "GANTS",
}

local RARITY_ORDER = { "commun", "rare", "epique", "legendaire", "mythique" }
local RARITY_CYCLE = { "all", "commun", "rare", "epique", "legendaire", "mythique" }
local VOIE_CYCLE = { "all", "guerrier", "mage" }
local VOIE_LABELS: { [string]: string } = { all = "TOUS", guerrier = "GUERRIER", mage = "MAGE" }

local function rarityRank(id: string?): number
    for i, r in ipairs(RARITY_ORDER) do
        if r == id then return i end
    end
    return 0
end

local function displayName(item: Types.ItemInstance): string
    local def = EquipmentConfig.getItem(item.id)
    if def and type(def.nom) == "string" then
        return def.nom
    end
    return item.id
end

function InventoryScreen.mount(rpgGui: ScreenGui, combatEvent: RemoteEvent, deps: InventoryScreenDeps): InventoryScreenApi
    local ZS = StyleConstants.ScreenZ.Inventory
    local background = rpgGui:FindFirstChild("Background") :: Instance?
    local parent: Instance = (background and background :: Instance) or (rpgGui :: Instance)

    --== Root window (matches the existing EquipOverlay/ShopOverlay/ChateauOverlay convention) ==--
    local root = Instance.new("Frame")
    root.Name = "InventoryScreen"
    root.Position = UDim2.fromScale(0.05, 0.05)
    root.Size = UDim2.fromScale(0.9, 0.9)
    root.BackgroundColor3 = StyleConstants.BaseColors.Background
    root.BorderSizePixel = 0
    root.ZIndex = ZS
    root.Visible = false
    root.Parent = parent
    -- Strong outer frame matching the La Descente HUD style.
    StyleConstants.addStroke(root, 6)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 6)
    title.Size = UDim2.new(1, -60, 0, 34)
    title.Font = StyleConstants.Fonts.Heading
    title.Text = "INVENTAIRE"
    title.TextColor3 = StyleConstants.BaseColors.Accent
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = ZS
    title.Parent = root
    StyleConstants.applyTypography(title, "Heading")

    local closeBtn = StyleConstants.makeButton("[X]", "Body", "red")
    closeBtn.Name = "CloseBtn"
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -8, 0, 8)
    closeBtn.Size = UDim2.new(0, 44, 0, 32)
    closeBtn.ZIndex = ZS
    closeBtn.Parent = root

    --== Slot tabs (client-local filter; see header comment) ==--
    local tabsRow = Instance.new("Frame")
    tabsRow.Name = "SlotTabs"
    tabsRow.BackgroundTransparency = 1
    tabsRow.Position = UDim2.new(0, 12, 0, 44)
    tabsRow.Size = UDim2.new(1, -24, 0, 28)
    tabsRow.ZIndex = ZS
    tabsRow.Parent = root
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.Padding = UDim.new(0, 4)
    tabsLayout.Parent = tabsRow

    --== Filter row (rarity + voie, synced to server via setFilters) ==--
    local filterRow = Instance.new("Frame")
    filterRow.Name = "FilterRow"
    filterRow.BackgroundTransparency = 1
    filterRow.Position = UDim2.new(0, 12, 0, 76)
    filterRow.Size = UDim2.new(1, -24, 0, 26)
    filterRow.ZIndex = ZS
    filterRow.Parent = root
    local filterLayout = Instance.new("UIListLayout")
    filterLayout.FillDirection = Enum.FillDirection.Horizontal
    filterLayout.Padding = UDim.new(0, 6)
    filterLayout.Parent = filterRow

    local rarityBtn = StyleConstants.makeButton("RAR: TOUT", "Label")
    rarityBtn.Size = UDim2.new(0, 150, 1, 0)
    rarityBtn.TextColor3 = StyleConstants.BaseColors.Accent
    rarityBtn.ZIndex = ZS
    rarityBtn.Parent = filterRow

    local voieBtn = StyleConstants.makeButton("VOIE: TOUS", "Label")
    voieBtn.Size = UDim2.new(0, 150, 1, 0)
    voieBtn.TextColor3 = StyleConstants.BaseColors.Accent
    voieBtn.ZIndex = ZS
    voieBtn.Parent = filterRow

    --== Grid ==--
    local grid = Instance.new("ScrollingFrame")
    grid.Name = "Grid"
    grid.Position = UDim2.new(0, 12, 0, 110)
    grid.Size = UDim2.new(1, -24, 1, -172)
    grid.BackgroundTransparency = 1
    grid.BorderSizePixel = 0
    grid.ScrollBarThickness = 6
    grid.ScrollBarImageColor3 = StyleConstants.BaseColors.Border
    grid.CanvasSize = UDim2.new(0, 0, 0, 0)
    grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
    grid.ZIndex = ZS
    grid.Parent = root
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.CellSize = UDim2.new(1 / GameConfig.Ui.gridColumnsStandard, -6, 0, 92)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = grid

    local emptyLabel = Instance.new("TextLabel")
    emptyLabel.Name = "EmptyLabel"
    emptyLabel.BackgroundTransparency = 1
    emptyLabel.Size = UDim2.new(1, 0, 0, 40)
    emptyLabel.Font = StyleConstants.Fonts.Body
    emptyLabel.Text = "(Aucun objet)"
    emptyLabel.TextColor3 = StyleConstants.BaseColors.TextSecondary
    emptyLabel.Visible = false
    emptyLabel.ZIndex = ZS
    emptyLabel.Parent = grid
    StyleConstants.applyTypography(emptyLabel, "Body")

    --== Selection action bar ==--
    local actionBar = Instance.new("Frame")
    actionBar.Name = "ActionBar"
    actionBar.BackgroundColor3 = StyleConstants.BaseColors.Panel
    actionBar.Position = UDim2.new(0, 12, 1, -60)
    actionBar.Size = UDim2.new(1, -24, 0, 34)
    actionBar.BorderSizePixel = 0
    actionBar.ZIndex = ZS
    actionBar.Parent = root
    StyleConstants.addStroke(actionBar, 2)

    local selectionLabel = Instance.new("TextLabel")
    selectionLabel.Name = "SelectionLabel"
    selectionLabel.BackgroundTransparency = 1
    selectionLabel.Position = UDim2.new(0, 8, 0, 0)
    selectionLabel.Size = UDim2.new(0.36, -8, 1, 0)
    selectionLabel.Font = StyleConstants.Fonts.Body
    selectionLabel.Text = "Sélectionnez un objet"
    selectionLabel.TextColor3 = StyleConstants.BaseColors.TextSecondary
    selectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectionLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectionLabel.ZIndex = ZS
    selectionLabel.Parent = actionBar
    StyleConstants.applyTypography(selectionLabel, "Label")

    local actionButtonsFrame = Instance.new("Frame")
    actionButtonsFrame.Name = "Buttons"
    actionButtonsFrame.BackgroundTransparency = 1
    actionButtonsFrame.Position = UDim2.new(0.36, 0, 0, 0)
    actionButtonsFrame.Size = UDim2.new(0.64, -8, 1, 0)
    actionButtonsFrame.ZIndex = ZS
    actionButtonsFrame.Parent = actionBar
    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 4)
    actionLayout.Parent = actionButtonsFrame

    -- Retro button colors per Reference/ui.jpg's action row (gold = primary
    -- equip action, gray = neutral toggle, red = destructive).
    local equipBtn = StyleConstants.makeButton("[ ÉQUIPER ]", "Label", "gold")
    equipBtn.Size = UDim2.new(0.34, 0, 1, 0)
    equipBtn.ZIndex = ZS
    equipBtn.Parent = actionButtonsFrame

    local lockBtn = StyleConstants.makeButton("[ VERROUILLER ]", "Label", "gray")
    lockBtn.Size = UDim2.new(0.34, 0, 1, 0)
    lockBtn.ZIndex = ZS
    lockBtn.Parent = actionButtonsFrame

    local removeBtn = StyleConstants.makeButton("[ SUPPRIMER ]", "Label", "red")
    removeBtn.Size = UDim2.new(0.32, 0, 1, 0)
    removeBtn.ZIndex = ZS
    removeBtn.Parent = actionButtonsFrame

    --== Footer capacity readout ==--
    local footer = Instance.new("TextLabel")
    footer.Name = "CapacityFooter"
    footer.BackgroundTransparency = 1
    footer.Position = UDim2.new(0, 12, 1, -22)
    footer.Size = UDim2.new(1, -24, 0, 18)
    footer.Font = StyleConstants.Fonts.Body
    footer.Text = "Inventaire : 0/100"
    footer.TextColor3 = StyleConstants.BaseColors.TextPrimary
    footer.TextXAlignment = Enum.TextXAlignment.Right
    footer.ZIndex = ZS
    footer.Parent = root
    StyleConstants.applyTypography(footer, "Label")

    --== State ==--
    local isOpenFlag = false
    local bagItems: { [string]: Types.ItemInstance } = {}
    local bagCapacity = GameConfig.Inventory.baseCapacity
    local slotFilter = "all"
    local serverFilters = { rareteMin = "all", voie = "all", guerrier = true, mage = true }
    local selectedKey: string? = nil
    local orderedKeys: { string } = {}
    local cardByKey: { [string]: Frame } = {}
    local typedLabels: { { label: TextLabel | TextButton, level: string } } = {}
    local lastRefreshRequestAt = 0

    local function prefs(): UiPrefs
        local ok, p = pcall(deps.getUiPrefs)
        if ok and p then return p end
        return {
            fontScale = GameConfig.Ui.fontScaleDefault,
            colorblindMode = "off",
            reducedMotion = false,
            highContrast = false,
            hudHand = "right",
        }
    end

    local function trackLabel(label: TextLabel | TextButton, level: string)
        typedLabels[#typedLabels + 1] = { label = label, level = level }
        StyleConstants.applyTypography(label, level, prefs().fontScale)
    end

    for _, entry in ipairs({
        { title, "Heading" }, { closeBtn, "Body" }, { rarityBtn, "Label" }, { voieBtn, "Label" },
        { emptyLabel, "Body" }, { selectionLabel, "Label" }, { equipBtn, "Label" },
        { lockBtn, "Label" }, { removeBtn, "Label" }, { footer, "Label" },
    }) do
        trackLabel(entry[1], entry[2])
    end

    local function requestRefreshDebounced()
        local now = os.clock()
        if now - lastRefreshRequestAt < 0.3 then return end
        lastRefreshRequestAt = now
        local ok = pcall(deps.requestRefresh)
        if not ok then warn("[InventoryScreen] requestRefresh callback failed") end
    end

    --== Responsive columns (ui-ux-gdd 7.1: 7 -> 5 columns on a narrow screen) ==--
    local NARROW_BREAKPOINT_PX = 640
    local function updateColumns()
        local width = root.AbsoluteSize.X
        local columns = (width > 0 and width < NARROW_BREAKPOINT_PX)
            and GameConfig.Ui.gridColumnsMinNarrow
            or GameConfig.Ui.gridColumnsStandard
        gridLayout.CellSize = UDim2.new(1 / columns, -6, 0, 92)
    end
    root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColumns)

    --== Selection ==--
    local function updateActionBar()
        local item = selectedKey and bagItems[selectedKey]
        if not item then
            selectionLabel.Text = "Sélectionnez un objet"
            selectionLabel.TextColor3 = StyleConstants.BaseColors.TextSecondary
            for _, b in ipairs({ equipBtn, lockBtn, removeBtn }) do
                b.Active = false
                b.TextTransparency = 0.55
            end
            return
        end
        selectionLabel.Text = displayName(item)
        selectionLabel.TextColor3 = StyleConstants.rarityInfo(item.rarity).color
        equipBtn.Active = true
        equipBtn.TextTransparency = 0
        lockBtn.Active = true
        lockBtn.TextTransparency = 0
        lockBtn.Text = item.locked and "[ DÉVERROUILLER ]" or "[ VERROUILLER ]"
        -- Removal is refused server-side for locked OR equipped items
        -- (InventoryService.removeItem) - grey it out proactively so the
        -- player isn't sent on a guaranteed-fail round trip.
        local canRemove = not item.locked and item.equippedSlot == nil
        removeBtn.Active = canRemove
        removeBtn.TextTransparency = canRemove and 0 or 0.55
        removeBtn.Text = item.locked and "[ VERROUILLÉ ]"
            or (item.equippedSlot ~= nil and "[ ÉQUIPÉ ]" or "[ SUPPRIMER ]")
    end

    local function selectKey(key: string?)
        if selectedKey and cardByKey[selectedKey] then
            local s = cardByKey[selectedKey]:FindFirstChildOfClass("UIStroke")
            if s then s.Thickness = 2 end
        end
        selectedKey = key
        if selectedKey and cardByKey[selectedKey] then
            local s = cardByKey[selectedKey]:FindFirstChildOfClass("UIStroke")
            if s then s.Thickness = 4 end
        end
        updateActionBar()
    end

    --== Card builder ==--
    local function buildCard(key: string, item: Types.ItemInstance, order: number): Frame
        local rar = StyleConstants.rarityInfo(item.rarity)
        local card = Instance.new("TextButton")
        card.Name = "Card_" .. key
        card.AutoButtonColor = false
        card.BackgroundColor3 = StyleConstants.BaseColors.Slot
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Text = ""
        card.ZIndex = ZS
        StyleConstants.addStroke(card, 2, rar.color)
        StyleConstants.addCorner(card, 4)

        local icon = Instance.new("Frame")
        icon.Name = "Icon"
        icon.Position = UDim2.new(0.5, 0, 0.06, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0)
        icon.Size = UDim2.new(0.7, 0, 0.5, 0)
        icon.BackgroundColor3 = rar.color
        icon.BackgroundTransparency = 0.75
        icon.BorderSizePixel = 0
        icon.ZIndex = ZS
        icon.Parent = card
        StyleConstants.addCorner(icon, 3)
        local symbol = Instance.new("TextLabel")
        symbol.BackgroundTransparency = 1
        symbol.Size = UDim2.fromScale(1, 1)
        symbol.Font = StyleConstants.Fonts.Body
        symbol.Text = rar.symbol ~= "" and rar.symbol or "?"
        symbol.TextColor3 = rar.color
        symbol.ZIndex = ZS
        symbol.Parent = icon
        trackLabel(symbol, "Heading")

        if (item.forgeLevel or 0) > 0 then
            local forgeTag = Instance.new("TextLabel")
            forgeTag.Name = "ForgeTag"
            forgeTag.AnchorPoint = Vector2.new(0, 0)
            forgeTag.Position = UDim2.new(0, 2, 0, 2)
            forgeTag.Size = UDim2.new(0, 28, 0, 14)
            forgeTag.BackgroundColor3 = StyleConstants.BaseColors.Accent
            forgeTag.BackgroundTransparency = 0.15
            forgeTag.BorderSizePixel = 0
            forgeTag.Font = StyleConstants.Fonts.Body
            forgeTag.Text = "+" .. tostring(item.forgeLevel)
            forgeTag.TextColor3 = Color3.new(0, 0, 0)
            forgeTag.ZIndex = ZS
            forgeTag.Parent = card
            trackLabel(forgeTag, "Label")
        end

        if item.locked then
            local lockTag = Instance.new("TextLabel")
            lockTag.Name = "LockTag"
            lockTag.AnchorPoint = Vector2.new(1, 0)
            lockTag.Position = UDim2.new(1, -2, 0, 2)
            lockTag.Size = UDim2.new(0, 20, 0, 14)
            lockTag.BackgroundTransparency = 1
            lockTag.Font = StyleConstants.Fonts.Body
            lockTag.Text = "[V]"
            lockTag.TextColor3 = StyleConstants.BaseColors.TextPrimary
            lockTag.ZIndex = ZS
            lockTag.Parent = card
            trackLabel(lockTag, "Label")
        end

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Position = UDim2.new(0.04, 0, 0.60, 0)
        nameLabel.Size = UDim2.new(0.92, 0, 0.22, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = StyleConstants.Fonts.Body
        nameLabel.Text = displayName(item)
        nameLabel.TextColor3 = StyleConstants.BaseColors.TextPrimary
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.TextWrapped = false
        nameLabel.ZIndex = ZS
        nameLabel.Parent = card
        trackLabel(nameLabel, "Label")

        local rarLabel = Instance.new("TextLabel")
        rarLabel.Name = "RarityLabel"
        rarLabel.Position = UDim2.new(0.04, 0, 0.80, 0)
        rarLabel.Size = UDim2.new(0.92, 0, 0.18, 0)
        rarLabel.BackgroundTransparency = 1
        rarLabel.Font = StyleConstants.Fonts.Body
        rarLabel.Text = rar.label
        rarLabel.TextColor3 = rar.color
        rarLabel.ZIndex = ZS
        rarLabel.Parent = card
        trackLabel(rarLabel, "Label")

        card.MouseButton1Click:Connect(function()
            selectKey(key)
        end)

        return card
    end

    --== Render ==--
    -- InventoryService.getInventory / CombatServer's requestInventory branch
    -- return the bag UNFILTERED - `profile.filtres` (written by setFilters)
    -- is stored but never actually consumed server-side (a Day-2
    -- InventoryService gap, out of ui-programmer's domain to fix). Rather
    -- than ship rarity/voie filter buttons that visibly do nothing, this
    -- screen also applies `serverFilters` client-side so the feature works
    -- end-to-end today; drop this once InventoryService applies filters
    -- itself (grep GameConfig.Inventory / profile.filtres for the follow-up).
    local function passesFilters(item: Types.ItemInstance): boolean
        if slotFilter ~= "all" and ITEM_TYPE_TO_SLOT_TAB[item.itemType] ~= slotFilter then
            return false
        end
        local floor = serverFilters.rareteMin
        if floor and floor ~= "all" and floor ~= "commun" then
            if rarityRank(item.rarity) < rarityRank(floor) then
                return false
            end
        end
        if item.voie and serverFilters.voie and serverFilters.voie ~= "all" and item.voie ~= serverFilters.voie then
            return false
        end
        return true
    end

    local function render()
        for _, c in pairs(cardByKey) do c:Destroy() end
        cardByKey = {}
        orderedKeys = {}

        local keys = {}
        for k, item in pairs(bagItems) do
            if passesFilters(item) then
                keys[#keys + 1] = k
            end
        end
        table.sort(keys, function(a, b)
            local ia, ib = bagItems[a], bagItems[b]
            local ra, rb = rarityRank(ia.rarity), rarityRank(ib.rarity)
            if ra ~= rb then return ra > rb end
            return (ia.droppedAtTime or 0) > (ib.droppedAtTime or 0)
        end)
        orderedKeys = keys

        emptyLabel.Visible = (#keys == 0)
        for i, key in ipairs(keys) do
            local card = buildCard(key, bagItems[key], i)
            card.Parent = grid
            cardByKey[key] = card
        end

        if selectedKey and not cardByKey[selectedKey] then
            selectedKey = nil
        end
        updateActionBar()

        local count = 0
        for _ in pairs(bagItems) do count += 1 end
        local ratio = (bagCapacity > 0) and (count / bagCapacity) or 0
        footer.Text = string.format("Inventaire : %d/%d", count, bagCapacity)
        footer.TextColor3 = (ratio >= 1)
            and StyleConstants.BaseColors.Alert
            or (ratio >= 0.9)
                and Color3.fromRGB(255, 170, 60)
                or StyleConstants.BaseColors.TextPrimary
    end

    --== Slot tabs ==--
    local tabButtons: { [string]: TextButton } = {}
    for _, tabId in ipairs(SLOT_TABS) do
        local btn = StyleConstants.makeButton(SLOT_TAB_LABELS[tabId], "Label")
        btn.Size = UDim2.new(0, 84, 1, 0)
        btn.ZIndex = ZS
        btn.Parent = tabsRow
        trackLabel(btn, "Label")
        tabButtons[tabId] = btn
        btn.MouseButton1Click:Connect(function()
            slotFilter = tabId
            for id, b in pairs(tabButtons) do
                b.TextColor3 = (id == slotFilter) and StyleConstants.BaseColors.Accent or StyleConstants.BaseColors.TextPrimary
            end
            render()
        end)
    end
    tabButtons.all.TextColor3 = StyleConstants.BaseColors.Accent

    --== Server-synced filters ==--
    -- InventoryService.setFilters(player, rarity, voie) takes BOTH params in
    -- ONE call (not two independent partial updates) and rejects the call
    -- entirely if either is missing/malformed - so every fire below always
    -- sends the FULL current filter pair, not just the one being changed.
    -- `guerrier`/`mage` are also included (redundant with `voie` for the
    -- server, which only reads `data.voie`) purely so CombatServer's echo
    -- (`{ rareteMin = data.rareteMin, guerrier = data.guerrier, mage = data.mage }`)
    -- carries back a value this screen can render without a second round trip.
    local function fireSetFilters(nextRarity: string, nextVoie: string)
        combatEvent:FireServer({
            type = "setFilters",
            rareteMin = nextRarity,
            voie = nextVoie,
            guerrier = (nextVoie == "all" or nextVoie == "tous" or nextVoie == "guerrier"),
            mage = (nextVoie == "all" or nextVoie == "tous" or nextVoie == "mage"),
        })
    end

    rarityBtn.MouseButton1Click:Connect(function()
        local cur = serverFilters.rareteMin or "all"
        local idx = (table.find(RARITY_CYCLE, cur) or 1) % #RARITY_CYCLE + 1
        fireSetFilters(RARITY_CYCLE[idx], serverFilters.voie or "all")
    end)
    voieBtn.MouseButton1Click:Connect(function()
        local cur = serverFilters.voie or "all"
        local idx = (table.find(VOIE_CYCLE, cur) or 1) % #VOIE_CYCLE + 1
        fireSetFilters(serverFilters.rareteMin or "all", VOIE_CYCLE[idx])
    end)

    --== Action bar buttons ==--
    equipBtn.MouseButton1Click:Connect(function()
        if not (selectedKey and equipBtn.Active) then return end
        combatEvent:FireServer({ type = "equipItem", itemKey = selectedKey })
        requestRefreshDebounced()
    end)
    lockBtn.MouseButton1Click:Connect(function()
        if not (selectedKey and lockBtn.Active) then return end
        combatEvent:FireServer({ type = "toggleLock", itemKey = selectedKey })
        requestRefreshDebounced()
    end)
    removeBtn.MouseButton1Click:Connect(function()
        if not (selectedKey and removeBtn.Active) then return end
        combatEvent:FireServer({ type = "removeItem", itemKey = selectedKey })
        requestRefreshDebounced()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        root.Visible = false
        isOpenFlag = false
    end)

    --== Keyboard / gamepad navigation (ui-ux-gdd 7.9) ==--
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not isOpenFlag or gameProcessed then return end
        local columns = math.floor(1 / gridLayout.CellSize.X.Scale + 0.5)
        columns = math.max(1, columns)
        local curIndex = selectedKey and table.find(orderedKeys, selectedKey) or 0

        if input.KeyCode == Enum.KeyCode.Right then
            curIndex = math.min(#orderedKeys, curIndex + 1)
        elseif input.KeyCode == Enum.KeyCode.Left then
            curIndex = math.max(1, curIndex - 1)
        elseif input.KeyCode == Enum.KeyCode.Down then
            curIndex = math.min(#orderedKeys, curIndex + columns)
        elseif input.KeyCode == Enum.KeyCode.Up then
            curIndex = math.max(1, curIndex - columns)
        elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
            if selectedKey and equipBtn.Active then
                combatEvent:FireServer({ type = "equipItem", itemKey = selectedKey })
                requestRefreshDebounced()
            end
            return
        elseif input.KeyCode == Enum.KeyCode.R then
            if selectedKey and lockBtn.Active then
                combatEvent:FireServer({ type = "toggleLock", itemKey = selectedKey })
                requestRefreshDebounced()
            end
            return
        elseif input.KeyCode == Enum.KeyCode.Escape then
            root.Visible = false
            isOpenFlag = false
            return
        else
            return
        end

        if curIndex >= 1 and curIndex <= #orderedKeys then
            selectKey(orderedKeys[curIndex])
        end
    end)

    --== Public API ==--
    local function open()
        isOpenFlag = true
        root.Visible = true
        requestRefreshDebounced()
    end
    local function close()
        isOpenFlag = false
        root.Visible = false
    end
    local function toggle()
        if isOpenFlag then close() else open() end
    end
    local function isOpen(): boolean
        return isOpenFlag
    end

    local function setInventoryData(items: { [string]: Types.ItemInstance }, capacity: number)
        bagItems = items or {}
        bagCapacity = capacity or bagCapacity
        render()
    end

    local function setFilters(filters: { rareteMin: string?, guerrier: boolean?, mage: boolean? })
        if filters.rareteMin ~= nil then serverFilters.rareteMin = filters.rareteMin end
        -- The server never echoes `voie` directly (CombatServer's setFilters
        -- reply only carries rareteMin/guerrier/mage - see fireSetFilters'
        -- comment above), so re-derive it from the guerrier/mage pair we
        -- ourselves sent, rather than trusting a `filters.voie` that will
        -- never actually be present.
        if filters.guerrier ~= nil then serverFilters.guerrier = filters.guerrier end
        if filters.mage ~= nil then serverFilters.mage = filters.mage end
        if serverFilters.guerrier and serverFilters.mage then
            serverFilters.voie = "all"
        elseif serverFilters.guerrier then
            serverFilters.voie = "guerrier"
        elseif serverFilters.mage then
            serverFilters.voie = "mage"
        else
            serverFilters.voie = "all"
        end

        local rarLabel: string
        if serverFilters.rareteMin == "all" or serverFilters.rareteMin == "commun" then
            rarLabel = "TOUT"
        elseif EquipmentConfig.getRarity(serverFilters.rareteMin) then
            rarLabel = StyleConstants.rarityInfo(serverFilters.rareteMin).label
        else
            rarLabel = "TOUT"
        end
        rarityBtn.Text = "RAR: " .. string.upper(rarLabel)

        local voieText: string
        if serverFilters.voie == "guerrier" then
            voieText = "GUERRIER"
        elseif serverFilters.voie == "mage" then
            voieText = "MAGE"
        else
            voieText = "TOUS"
        end
        voieBtn.Text = "VOIE: " .. voieText

        render() -- serverFilters changed - re-apply the client-side filter mirror (see passesFilters)
    end

    local function applyUiPrefs(p: UiPrefs)
        for _, entry in ipairs(typedLabels) do
            StyleConstants.applyTypography(entry.label, entry.level, p.fontScale)
        end
    end

    local function destroy()
        inputConn:Disconnect()
        root:Destroy()
    end

    updateColumns()
    updateActionBar() -- initialize the action bar to its "nothing selected" disabled state

    return {
        open = open,
        close = close,
        toggle = toggle,
        isOpen = isOpen,
        setInventoryData = setInventoryData,
        setFilters = setFilters,
        applyUiPrefs = applyUiPrefs,
        destroy = destroy,
    }
end

return InventoryScreen
