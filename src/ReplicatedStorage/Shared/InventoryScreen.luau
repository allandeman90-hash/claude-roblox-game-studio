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
    setEquipped: (equipped: { [string]: Types.ItemInstance }?) -> (),
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

local SLOT_LABELS_FR: { [string]: string } = {
    arme = "Arme", casque = "Casque", plastron = "Plastron",
    jambieres = "Jambières", bottes = "Bottes", gants = "Gants", pet = "Familier",
}
local EQUIP_SLOTS = { "arme", "casque", "plastron", "jambieres", "bottes", "gants", "pet" }

-- Human-readable stat lines for the detail panel (adapts to what an item carries).
local function itemStatLines(item: Types.ItemInstance): { string }
    local out = {}
    if item.itemType == "pet" then
        local def = EquipmentConfig.getItem(item.id)
        local roleFr = EquipmentConfig.RoleLabels[def and def.role or ""] or "?"
        local lvl = math.max(1, math.floor(item.petLevel or 1))
        out[#out + 1] = "Rôle       " .. roleFr
        out[#out + 1] = "Niveau     " .. tostring(lvl)
        -- XP only accrues while the pet is equipped (see EquipmentService.grantPetXp).
        out[#out + 1] = "XP         " .. tostring(math.floor(item.petXp or 0))
            .. " / " .. tostring(GameConfig.Pets.petXpToNext(lvl))
        out[#out + 1] = "Palier     " .. tostring(item.sourceLevel or 1) .. "  (source)"
        return out
    end
    local bs = item.baseStats or {}
    local function pct(v) return string.format("%d%%", math.floor((v or 0) * 100 + 0.5)) end
    if bs.weaponPct then out[#out + 1] = "Attaque   +" .. pct(bs.weaponPct) end
    if bs.def then out[#out + 1] = "Défense   +" .. tostring(math.floor(bs.def + 0.5)) end
    if bs.res then out[#out + 1] = "Résist.   +" .. tostring(math.floor(bs.res + 0.5)) end
    if bs.hp then out[#out + 1] = "PV        +" .. tostring(math.floor(bs.hp + 0.5)) end
    if (item.forgeLevel or 0) > 0 then out[#out + 1] = "Forge     +" .. tostring(item.forgeLevel) end
    out[#out + 1] = "Couche    " .. tostring(item.droppedAtKm or 1)
    if item.voie then
        out[#out + 1] = "Voie      " .. (item.voie == "mage" and "Mage" or "Guerrier")
    end
    return out
end

-- "#RRGGBB" for a Color3 (RichText <font color> wants hex).
local function hex(c: Color3): string
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function itemDescription(item: Types.ItemInstance): string
    local def = EquipmentConfig.getItem(item.id)
    if def and type(def.description) == "string" then return def.description end
    local rar = StyleConstants.rarityInfo(item.rarity)
    local kind = SLOT_LABELS_FR[(def and def.slot) or ""] or "Objet"
    return string.format("%s de rareté %s, trouvé Couche %d.", kind, string.lower(rar.label), item.droppedAtKm or 1)
end

function InventoryScreen.mount(rpgGui: ScreenGui, combatEvent: RemoteEvent, deps: InventoryScreenDeps): InventoryScreenApi
    local ZS = StyleConstants.ScreenZ.Inventory
    local background = rpgGui:FindFirstChild("Background") :: Instance?
    local parent: Instance = (background and background :: Instance) or (rpgGui :: Instance)

    --== Root window (two-panel: item grid | selected-item detail) ==============
    local COL = StyleConstants.BaseColors
    local LABEL_HEX = "#7a7a7e" -- dim grey for RichText <font> field labels
    local root = Instance.new("Frame")
    root.Name = "InventoryScreen"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.fromScale(0.88, 0.86)
    root.BackgroundColor3 = COL.Background
    root.BorderSizePixel = 0
    root.ZIndex = ZS
    root.Visible = false
    root.Parent = parent
    StyleConstants.addStroke(root, 1, COL.Border)
    do
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12) ; pad.PaddingBottom = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 14) ; pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = root
    end

    -- small local builders in the current flat palette --------------------------
    local function panel(name, parentFrame)
        local f = Instance.new("Frame")
        f.Name = name
        f.BackgroundColor3 = COL.Panel
        f.BorderSizePixel = 0
        f.ZIndex = ZS
        f.Parent = parentFrame
        StyleConstants.addStroke(f, 1, COL.Border)
        return f
    end
    local function textLabel(name, parentFrame, opts)
        opts = opts or {}
        local l = Instance.new("TextLabel")
        l.Name = name
        l.BackgroundTransparency = 1
        l.Font = StyleConstants.Fonts.Body
        l.RichText = true
        l.Text = opts.text or ""
        l.TextColor3 = opts.color or COL.TextPrimary
        l.TextXAlignment = opts.align or Enum.TextXAlignment.Left
        l.TextYAlignment = opts.yalign or Enum.TextYAlignment.Center
        l.TextWrapped = opts.wrap or false
        l.TextTruncate = opts.truncate or Enum.TextTruncate.None
        l.ZIndex = ZS
        l.Parent = parentFrame
        return l
    end

    --== Header ==--
    local title = textLabel("Title", root, { text = "INVENTAIRE", color = COL.Accent })
    title.Font = StyleConstants.Fonts.Heading
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, -50, 0, 26)
    StyleConstants.applyTypography(title, "Heading")

    local closeBtn = StyleConstants.makeButton("X", "Body")
    closeBtn.Name = "CloseBtn"
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, 0, 0, 0)
    closeBtn.Size = UDim2.fromOffset(30, 26)
    closeBtn.TextColor3 = COL.TextSecondary
    closeBtn.ZIndex = ZS
    closeBtn.Parent = root

    --== Left panel : tabs + filters + grid ==--
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.BackgroundTransparency = 1
    leftPanel.Position = UDim2.new(0, 0, 0, 36)
    leftPanel.Size = UDim2.new(0.62, -8, 1, -36)
    leftPanel.ZIndex = ZS
    leftPanel.Parent = root

    local tabsRow = Instance.new("Frame")
    tabsRow.Name = "SlotTabs"
    tabsRow.BackgroundTransparency = 1
    tabsRow.Position = UDim2.new(0, 0, 0, 0)
    tabsRow.Size = UDim2.new(1, 0, 0, 24)
    tabsRow.ZIndex = ZS
    tabsRow.Parent = leftPanel
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.Padding = UDim.new(0, 3)
    tabsLayout.Parent = tabsRow

    local filterRow = Instance.new("Frame")
    filterRow.Name = "FilterRow"
    filterRow.BackgroundTransparency = 1
    filterRow.Position = UDim2.new(0, 0, 0, 30)
    filterRow.Size = UDim2.new(1, 0, 0, 22)
    filterRow.ZIndex = ZS
    filterRow.Parent = leftPanel
    local filterLayout = Instance.new("UIListLayout")
    filterLayout.FillDirection = Enum.FillDirection.Horizontal
    filterLayout.Padding = UDim.new(0, 6)
    filterLayout.Parent = filterRow

    local rarityBtn = StyleConstants.makeButton("RAR: TOUT", "Label")
    rarityBtn.Size = UDim2.new(0, 150, 1, 0)
    rarityBtn.TextColor3 = COL.Accent
    rarityBtn.ZIndex = ZS
    rarityBtn.Parent = filterRow

    local voieBtn = StyleConstants.makeButton("VOIE: TOUS", "Label")
    voieBtn.Size = UDim2.new(0, 150, 1, 0)
    voieBtn.TextColor3 = COL.Accent
    voieBtn.ZIndex = ZS
    voieBtn.Parent = filterRow

    local sortBtn = StyleConstants.makeButton("TRIER: RARETÉ", "Label")
    sortBtn.Name = "SortBtn"
    sortBtn.Size = UDim2.new(0, 170, 1, 0)
    sortBtn.TextColor3 = COL.TextSecondary
    sortBtn.ZIndex = ZS
    sortBtn.Parent = filterRow

    local grid = Instance.new("ScrollingFrame")
    grid.Name = "Grid"
    grid.Position = UDim2.new(0, 0, 0, 60)
    grid.Size = UDim2.new(1, 0, 1, -60)
    grid.BackgroundColor3 = COL.Slot
    grid.BackgroundTransparency = 0.35
    grid.BorderSizePixel = 0
    grid.ScrollBarThickness = 5
    grid.ScrollBarImageColor3 = COL.Border
    grid.CanvasSize = UDim2.new(0, 0, 0, 0)
    grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
    grid.ZIndex = ZS
    grid.Parent = leftPanel
    do
        local gp = Instance.new("UIPadding")
        gp.PaddingTop = UDim.new(0, 6) ; gp.PaddingBottom = UDim.new(0, 6)
        gp.PaddingLeft = UDim.new(0, 6) ; gp.PaddingRight = UDim.new(0, 6)
        gp.Parent = grid
    end
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.CellSize = UDim2.new(1 / GameConfig.Ui.gridColumnsStandard, -6, 0, 88)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = grid

    local emptyLabel = textLabel("EmptyLabel", grid, {
        text = "(aucun objet)", color = COL.TextSecondary, align = Enum.TextXAlignment.Center,
    })
    emptyLabel.Size = UDim2.new(1, 0, 0, 36)
    emptyLabel.Visible = false
    StyleConstants.applyTypography(emptyLabel, "Body")

    --== Right panel : selected-item detail + equipped summary ==--
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.BackgroundTransparency = 1
    rightPanel.Position = UDim2.new(0.62, 8, 0, 36)
    rightPanel.Size = UDim2.new(0.38, -8, 1, -36)
    rightPanel.ZIndex = ZS
    rightPanel.Parent = root

    -- detail box
    local detailBox = panel("DetailBox", rightPanel)
    detailBox.Position = UDim2.new(0, 0, 0, 0)
    detailBox.Size = UDim2.new(1, 0, 0, 232)
    do
        local dp = Instance.new("UIPadding")
        dp.PaddingTop = UDim.new(0, 10) ; dp.PaddingBottom = UDim.new(0, 10)
        dp.PaddingLeft = UDim.new(0, 12) ; dp.PaddingRight = UDim.new(0, 12)
        dp.Parent = detailBox
    end

    -- icon placeholder (no art yet - a rarity-tinted box + symbol)
    local detailIcon = Instance.new("Frame")
    detailIcon.Name = "Icon"
    detailIcon.Position = UDim2.new(0, 0, 0, 0)
    detailIcon.Size = UDim2.fromOffset(56, 56)
    detailIcon.BackgroundColor3 = COL.Slot
    detailIcon.BorderSizePixel = 0
    detailIcon.ZIndex = ZS
    detailIcon.Parent = detailBox
    StyleConstants.addStroke(detailIcon, 1, COL.Border)
    local detailIconSym = textLabel("Sym", detailIcon, { align = Enum.TextXAlignment.Center })
    detailIconSym.Size = UDim2.fromScale(1, 1)
    detailIconSym.Font = StyleConstants.Fonts.Heading
    StyleConstants.applyTypography(detailIconSym, "Heading")

    -- the item name doubles as the "nothing selected" hint (selectionLabel var
    -- kept so the rest of the module's selection logic is untouched)
    local selectionLabel = textLabel("Name", detailBox, {
        text = "Sélectionne un objet", color = COL.TextSecondary, wrap = true,
        yalign = Enum.TextYAlignment.Top,
    })
    selectionLabel.Position = UDim2.new(0, 68, 0, 2)
    selectionLabel.Size = UDim2.new(1, -68, 0, 52)
    StyleConstants.applyTypography(selectionLabel, "Body")

    local detailStats = textLabel("Stats", detailBox, {
        color = COL.TextPrimary, wrap = true, yalign = Enum.TextYAlignment.Top,
    })
    detailStats.Position = UDim2.new(0, 0, 0, 66)
    detailStats.Size = UDim2.new(1, 0, 0, 96)
    StyleConstants.applyTypography(detailStats, "Label")

    local detailDesc = textLabel("Desc", detailBox, {
        color = COL.TextSecondary, wrap = true, yalign = Enum.TextYAlignment.Top,
    })
    detailDesc.Position = UDim2.new(0, 0, 0, 164)
    detailDesc.Size = UDim2.new(1, 0, 1, -164)
    StyleConstants.applyTypography(detailDesc, "Label")

    -- action buttons (stacked)
    local actionBar = Instance.new("Frame")
    actionBar.Name = "Actions"
    actionBar.BackgroundTransparency = 1
    actionBar.Position = UDim2.new(0, 0, 0, 242)
    actionBar.Size = UDim2.new(1, 0, 0, 108)
    actionBar.ZIndex = ZS
    actionBar.Parent = rightPanel
    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Vertical
    actionLayout.Padding = UDim.new(0, 6)
    actionLayout.Parent = actionBar

    local equipBtn = StyleConstants.makeButton("ÉQUIPER", "Label", "gold")
    equipBtn.Size = UDim2.new(1, 0, 0, 30)
    equipBtn.ZIndex = ZS
    equipBtn.Parent = actionBar
    local lockBtn = StyleConstants.makeButton("VERROUILLER", "Label", "gray")
    lockBtn.Size = UDim2.new(1, 0, 0, 30)
    lockBtn.ZIndex = ZS
    lockBtn.Parent = actionBar
    local removeBtn = StyleConstants.makeButton("SUPPRIMER", "Label", "red")
    removeBtn.Size = UDim2.new(1, 0, 0, 30)
    removeBtn.ZIndex = ZS
    removeBtn.Parent = actionBar

    -- equipped summary (paper-doll stand-in: slot -> item name)
    local equippedBox = panel("EquippedBox", rightPanel)
    equippedBox.Position = UDim2.new(0, 0, 0, 360)
    equippedBox.Size = UDim2.new(1, 0, 1, -390)
    do
        local ep = Instance.new("UIPadding")
        ep.PaddingTop = UDim.new(0, 8) ; ep.PaddingBottom = UDim.new(0, 8)
        ep.PaddingLeft = UDim.new(0, 12) ; ep.PaddingRight = UDim.new(0, 12)
        ep.Parent = equippedBox
        local el = Instance.new("UIListLayout")
        el.Padding = UDim.new(0, 3)
        el.Parent = equippedBox
    end
    local equippedTitle = textLabel("Head", equippedBox, { text = "ÉQUIPÉ", color = COL.Accent })
    equippedTitle.Size = UDim2.new(1, 0, 0, 18)
    equippedTitle.LayoutOrder = 0
    StyleConstants.applyTypography(equippedTitle, "Label")
    -- Each row is a button: click a filled slot to unequip it back to the bag
    -- (the only unequip path in the game - there is no hero-panel any more).
    local equippedRows: { [string]: TextButton } = {}
    local equippedHasItem: { [string]: boolean } = {}
    for i, slot in ipairs(EQUIP_SLOTS) do
        local row = Instance.new("TextButton")
        row.Name = "Row_" .. slot
        row.BackgroundTransparency = 1
        row.AutoButtonColor = false
        row.Font = StyleConstants.Fonts.Body
        row.RichText = true
        row.Text = string.format('<font color="%s">%s</font>  \u{2014}', LABEL_HEX, SLOT_LABELS_FR[slot])
        row.TextColor3 = COL.TextPrimary
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextYAlignment = Enum.TextYAlignment.Center
        row.Size = UDim2.new(1, 0, 0, 16)
        row.LayoutOrder = i
        row.ZIndex = ZS
        row.Active = false
        row.Parent = equippedBox
        StyleConstants.applyTypography(row, "Label")
        equippedRows[slot] = row
    end

    --== Footer capacity readout ==--
    local footer = textLabel("CapacityFooter", rightPanel, {
        text = "Inventaire : 0/100", color = COL.TextPrimary, align = Enum.TextXAlignment.Right,
    })
    footer.AnchorPoint = Vector2.new(0, 1)
    footer.Position = UDim2.new(0, 0, 1, 0)
    footer.Size = UDim2.new(1, 0, 0, 18)
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
    -- SUPPRIMER needs a confirming second click (destructive, irreversible).
    local REMOVE_CONFIRM_SECONDS = 3
    local removeArmed = false

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
        { closeBtn, "Body" }, { rarityBtn, "Label" }, { voieBtn, "Label" }, { sortBtn, "Label" },
        { equipBtn, "Label" }, { lockBtn, "Label" }, { removeBtn, "Label" },
        { detailStats, "Label" }, { detailDesc, "Label" },
    }) do
        trackLabel(entry[1], entry[2])
    end
    local sortMode = "rarity"

    local function requestRefreshDebounced()
        local now = os.clock()
        if now - lastRefreshRequestAt < 0.3 then return end
        lastRefreshRequestAt = now
        local ok = pcall(deps.requestRefresh)
        if not ok then warn("[InventoryScreen] requestRefresh callback failed") end
    end

    --== Responsive columns (grid lives in the left panel now) ==--
    local NARROW_BREAKPOINT_PX = 560
    local function updateColumns()
        local width = grid.AbsoluteSize.X
        local columns = (width > 0 and width < NARROW_BREAKPOINT_PX)
            and GameConfig.Ui.gridColumnsMinNarrow
            or GameConfig.Ui.gridColumnsStandard
        columns = math.max(3, math.min(6, columns))
        gridLayout.CellSize = UDim2.new(1 / columns, -6, 0, 88)
    end
    grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColumns)

    --== Selection -> right-hand detail panel ==--
    -- Kept the name `updateActionBar` so selectKey / init stay untouched.
    local function updateActionBar()
        removeArmed = false  -- any selection change / refresh cancels a pending delete
        local item = selectedKey and bagItems[selectedKey]
        if not item then
            detailIconSym.Text = ""
            detailIcon.BackgroundColor3 = StyleConstants.BaseColors.Slot
            selectionLabel.Text = "Sélectionne un objet dans la grille"
            selectionLabel.TextColor3 = StyleConstants.BaseColors.TextSecondary
            detailStats.Text = ""
            detailDesc.Text = ""
            for _, b in ipairs({ equipBtn, lockBtn, removeBtn }) do
                b.Active = false
                b.TextTransparency = 0.55
            end
            removeBtn.Text = "SUPPRIMER"  -- drop any leftover "CONFIRMER ?"
            return
        end
        local rar = StyleConstants.rarityInfo(item.rarity)
        detailIcon.BackgroundColor3 = rar.color
        detailIcon.BackgroundTransparency = 0.72
        detailIconSym.Text = rar.symbol ~= "" and rar.symbol or "\u{25A0}"
        detailIconSym.TextColor3 = rar.color
        selectionLabel.Text = string.format('%s\n<font color="%s">%s</font>',
            displayName(item), hex(rar.color), rar.label)
        selectionLabel.TextColor3 = StyleConstants.BaseColors.TextPrimary
        detailStats.Text = table.concat(itemStatLines(item), "\n")
        detailDesc.Text = itemDescription(item)

        equipBtn.Active = true
        equipBtn.TextTransparency = 0
        equipBtn.Text = "ÉQUIPER"
        lockBtn.Active = true
        lockBtn.TextTransparency = 0
        lockBtn.Text = item.locked and "DÉVERROUILLER" or "VERROUILLER"
        local canRemove = not item.locked and item.equippedSlot == nil
        removeBtn.Active = canRemove
        removeBtn.TextTransparency = canRemove and 0 or 0.55
        removeBtn.Text = item.locked and "VERROUILLÉ"
            or (item.equippedSlot ~= nil and "ÉQUIPÉ" or "SUPPRIMER")
    end

    --== Equipped summary (paper-doll stand-in). Filled rows are clickable to unequip. ==--
    local function renderEquipped(equipped: { [string]: Types.ItemInstance }?)
        equipped = equipped or {}
        for _, slot in ipairs(EQUIP_SLOTS) do
            local row = equippedRows[slot]
            if row then
                local inst = equipped[slot]
                equippedHasItem[slot] = inst ~= nil
                row.Active = inst ~= nil
                if inst then
                    row.Text = string.format(
                        '<font color="%s">%s</font>  <font color="%s">%s</font>  <font color="%s">\u{00B7} retirer</font>',
                        LABEL_HEX, SLOT_LABELS_FR[slot],
                        hex(StyleConstants.rarityInfo(inst.rarity).color), displayName(inst),
                        LABEL_HEX)
                else
                    row.Text = string.format('<font color="%s">%s</font>  \u{2014}', LABEL_HEX, SLOT_LABELS_FR[slot])
                end
            end
        end
    end

    -- Click a filled ÉQUIPÉ row -> unequip that slot (item returns to the bag).
    for slot, row in pairs(equippedRows) do
        row.MouseButton1Click:Connect(function()
            if not equippedHasItem[slot] then return end
            combatEvent:FireServer({ type = "unequipItem", slot = slot })
            combatEvent:FireServer({ type = "requestInventory" })
            requestRefreshDebounced()
        end)
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
            if sortMode == "recent" then
                return (ia.droppedAtTime or 0) > (ib.droppedAtTime or 0)
            elseif sortMode == "couche" then
                if (ia.droppedAtKm or 0) ~= (ib.droppedAtKm or 0) then
                    return (ia.droppedAtKm or 0) > (ib.droppedAtKm or 0)
                end
            end
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

    --== Sort toggle (client-side; server has no sort remote yet) ==--
    local SORT_CYCLE = { "rarity", "recent", "couche" }
    local SORT_LABEL: { [string]: string } = { rarity = "RARETÉ", recent = "RÉCENT", couche = "COUCHE" }
    sortBtn.MouseButton1Click:Connect(function()
        local idx = (table.find(SORT_CYCLE, sortMode) or 1) % #SORT_CYCLE + 1
        sortMode = SORT_CYCLE[idx]
        sortBtn.Text = "TRIER: " .. SORT_LABEL[sortMode]
        render()
    end)

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
        if not removeArmed then
            removeArmed = true
            removeBtn.Text = "CONFIRMER ?"
            local armedFor = selectedKey
            task.delay(REMOVE_CONFIRM_SECONDS, function()
                if removeArmed and selectedKey == armedFor then
                    removeArmed = false
                    updateActionBar()  -- restores the "SUPPRIMER" label
                end
            end)
            return
        end
        removeArmed = false
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

    local function setEquipped(equipped: { [string]: Types.ItemInstance }?)
        renderEquipped(equipped)
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
    updateActionBar() -- initialize the detail panel to its "nothing selected" state
    renderEquipped(nil)

    return {
        open = open,
        close = close,
        toggle = toggle,
        isOpen = isOpen,
        setInventoryData = setInventoryData,
        setEquipped = setEquipped,
        setFilters = setFilters,
        applyUiPrefs = applyUiPrefs,
        destroy = destroy,
    }
end

return InventoryScreen
