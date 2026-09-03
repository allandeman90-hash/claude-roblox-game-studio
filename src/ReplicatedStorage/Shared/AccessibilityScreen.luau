--!strict
--==============================================================
-- AccessibilityScreen  (ModuleScript - ReplicatedStorage/Shared)
--
-- Single accessibility/settings screen (design/gdd/ui-ux-gdd.md §6.3: "Un
-- écran unique : sliders fontScale, sélecteur colorblindMode, toggles
-- reducedMotion/highContrast/hudHand. Application immédiate."). Uses stepper
-- buttons instead of a drag-slider for fontScale (same information, far
-- simpler input handling, still >= 44px touch targets).
--
-- Persistence gap (flagged, not fixed here - out of this task's scope):
-- ui-ux-gdd.md §5 specifies `Ui_SetPrefs` (C->S) / `Ui_PrefsLoaded` (S->C)
-- remotes and server-side persistence of `uiPrefs`. Neither exists yet -
-- ReplicatedStorage/Shared/Remotes.luau is still an empty stub and no server
-- script sets a `uiPrefs` attribute on the Player. This screen is therefore
-- SESSION-LOCAL ONLY for now: changes apply immediately client-side (via
-- InventoryClient.client.luau's applyUiPrefs propagation) but do not survive
-- a rejoin. remotes-networking-specialist / datastore-architect own wiring
-- the real persistence path later.
--
-- Colorblind remap: ui-ux-gdd.md §9 lists "art-director valide/étend palette
-- daltonienne" as still-open work. Per this task's own recommendation, this
-- build satisfies the "never color alone" rule via ALWAYS-ON symbols/labels
-- (StyleConstants.Rarities) rather than a conditional per-mode color remap -
-- so cycling colorblindMode here does not change any color today; it only
-- records the preference for when a real remap table lands.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local StyleConstants = require(script.Parent:WaitForChild("StyleConstants"))

export type UiPrefs = {
    fontScale: number,
    colorblindMode: string,
    reducedMotion: boolean,
    highContrast: boolean,
    hudHand: string,
}

export type AccessibilityScreenDeps = {
    getPrefs: () -> UiPrefs,
    setPrefs: (partial: { [string]: any }) -> (),
}

export type AccessibilityScreenApi = {
    open: () -> (),
    close: () -> (),
    toggle: () -> (),
    isOpen: () -> boolean,
    refresh: () -> (), -- re-render displayed values from deps.getPrefs()
    destroy: () -> (),
}

local AccessibilityScreen = {}

local COLORBLIND_CYCLE = { "off", "protanopia", "deuteranopia", "tritanopia" }
local COLORBLIND_LABELS: { [string]: string } = {
    off = "Désactivé", protanopia = "Protanopie", deuteranopia = "Deutéranopie", tritanopia = "Tritanopie",
}

function AccessibilityScreen.mount(rpgGui: ScreenGui, deps: AccessibilityScreenDeps): AccessibilityScreenApi
    local ZS = StyleConstants.ScreenZ.Settings
    local background = rpgGui:FindFirstChild("Background") :: Instance?
    local parent: Instance = (background and background :: Instance) or (rpgGui :: Instance)

    local root = Instance.new("Frame")
    root.Name = "AccessibilityScreen"
    root.Position = UDim2.fromScale(0.15, 0.12)
    root.Size = UDim2.fromScale(0.7, 0.76)
    root.BackgroundColor3 = StyleConstants.BaseColors.Background
    root.BorderSizePixel = 0
    root.ZIndex = ZS
    root.Visible = false
    root.Parent = parent
    StyleConstants.addStroke(root, 4)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 6)
    title.Size = UDim2.new(1, -60, 0, 34)
    title.Font = Enum.Font.Code
    title.Text = "RÉGLAGES D'ACCESSIBILITÉ"
    title.TextColor3 = StyleConstants.BaseColors.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = ZS
    title.Parent = root
    StyleConstants.applyTypography(title, "Heading")

    local closeBtn = StyleConstants.makeButton("[X]", "Body")
    closeBtn.TextColor3 = StyleConstants.BaseColors.Alert
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -8, 0, 8)
    closeBtn.Size = UDim2.new(0, 44, 0, 32)
    closeBtn.ZIndex = ZS
    closeBtn.Parent = root

    local rowsFrame = Instance.new("Frame")
    rowsFrame.BackgroundTransparency = 1
    rowsFrame.Position = UDim2.new(0, 12, 0, 50)
    rowsFrame.Size = UDim2.new(1, -24, 1, -100)
    rowsFrame.ZIndex = ZS
    rowsFrame.Parent = root
    local rowsLayout = Instance.new("UIListLayout")
    rowsLayout.Padding = UDim.new(0, 8)
    rowsLayout.Parent = rowsFrame

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Position = UDim2.new(0, 12, 1, -40)
    note.Size = UDim2.new(1, -24, 0, 30)
    note.Font = Enum.Font.Code
    note.Text = "Ces réglages s'appliquent immédiatement (non sauvegardés entre les sessions pour l'instant)."
    note.TextColor3 = StyleConstants.BaseColors.TextSecondary
    note.TextWrapped = true
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.ZIndex = ZS
    note.Parent = root
    StyleConstants.applyTypography(note, "Label")

    local typedLabels: { { label: TextLabel | TextButton, level: string } } = {}
    local function track(label: TextLabel | TextButton, level: string)
        typedLabels[#typedLabels + 1] = { label = label, level = level }
        StyleConstants.applyTypography(label, level)
    end
    track(title, "Heading")
    track(closeBtn, "Body")
    track(note, "Label")

    local function makeRow(labelText: string): (Frame, TextLabel)
        local row = Instance.new("Frame")
        row.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, 0, 0, 44)
        row.ZIndex = ZS
        row.Parent = rowsFrame
        StyleConstants.addStroke(row, 1)

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Font = Enum.Font.Code
        label.Text = labelText
        label.TextColor3 = StyleConstants.BaseColors.TextPrimary
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = ZS
        label.Parent = row
        track(label, "Body")
        return row, label
    end

    --== fontScale stepper ==--
    local fsRow = makeRow("Taille du texte")
    local fsMinus = StyleConstants.makeButton("[-]", "Body")
    fsMinus.AnchorPoint = Vector2.new(1, 0.5)
    fsMinus.Position = UDim2.new(1, -100, 0.5, 0)
    fsMinus.Size = UDim2.new(0, 44, 0, 36)
    fsMinus.ZIndex = ZS
    fsMinus.Parent = fsRow
    local fsValue = Instance.new("TextLabel")
    fsValue.BackgroundTransparency = 1
    fsValue.AnchorPoint = Vector2.new(1, 0.5)
    fsValue.Position = UDim2.new(1, -54, 0.5, 0)
    fsValue.Size = UDim2.new(0, 50, 0, 36)
    fsValue.Font = Enum.Font.Code
    fsValue.Text = "100%"
    fsValue.TextColor3 = StyleConstants.BaseColors.Accent
    fsValue.ZIndex = ZS
    fsValue.Parent = fsRow
    track(fsValue, "Body")
    local fsPlus = StyleConstants.makeButton("[+]", "Body")
    fsPlus.AnchorPoint = Vector2.new(1, 0.5)
    fsPlus.Position = UDim2.new(1, -8, 0.5, 0)
    fsPlus.Size = UDim2.new(0, 44, 0, 36)
    fsPlus.ZIndex = ZS
    fsPlus.Parent = fsRow

    --== colorblindMode cycle ==--
    local cbRow = makeRow("Mode daltonien")
    local cbBtn = StyleConstants.makeButton("Désactivé", "Body")
    cbBtn.AnchorPoint = Vector2.new(1, 0.5)
    cbBtn.Position = UDim2.new(1, -8, 0.5, 0)
    cbBtn.Size = UDim2.new(0, 180, 0, 36)
    cbBtn.ZIndex = ZS
    cbBtn.Parent = cbRow

    --== reducedMotion toggle ==--
    local rmRow = makeRow("Mouvement réduit")
    local rmBtn = StyleConstants.makeButton("OFF", "Body")
    rmBtn.AnchorPoint = Vector2.new(1, 0.5)
    rmBtn.Position = UDim2.new(1, -8, 0.5, 0)
    rmBtn.Size = UDim2.new(0, 90, 0, 36)
    rmBtn.ZIndex = ZS
    rmBtn.Parent = rmRow

    --== highContrast toggle ==--
    local hcRow = makeRow("Contraste élevé")
    local hcBtn = StyleConstants.makeButton("OFF", "Body")
    hcBtn.AnchorPoint = Vector2.new(1, 0.5)
    hcBtn.Position = UDim2.new(1, -8, 0.5, 0)
    hcBtn.Size = UDim2.new(0, 90, 0, 36)
    hcBtn.ZIndex = ZS
    hcBtn.Parent = hcRow

    --== hudHand toggle ==--
    local hhRow = makeRow("Main dominante (pouce)")
    local hhBtn = StyleConstants.makeButton("DROITE", "Body")
    hhBtn.AnchorPoint = Vector2.new(1, 0.5)
    hhBtn.Position = UDim2.new(1, -8, 0.5, 0)
    hhBtn.Size = UDim2.new(0, 110, 0, 36)
    hhBtn.ZIndex = ZS
    hhBtn.Parent = hhRow

    for _, b in ipairs({ fsMinus, fsPlus, cbBtn, rmBtn, hcBtn, hhBtn }) do
        track(b, "Body")
    end

    local isOpenFlag = false

    local function render()
        local p = deps.getPrefs()
        fsValue.Text = string.format("%d%%", math.floor(p.fontScale * 100 + 0.5))
        cbBtn.Text = COLORBLIND_LABELS[p.colorblindMode] or "Désactivé"
        rmBtn.Text = p.reducedMotion and "ON" or "OFF"
        rmBtn.TextColor3 = p.reducedMotion and StyleConstants.BaseColors.Positive or StyleConstants.BaseColors.TextSecondary
        hcBtn.Text = p.highContrast and "ON" or "OFF"
        hcBtn.TextColor3 = p.highContrast and StyleConstants.BaseColors.Positive or StyleConstants.BaseColors.TextSecondary
        hhBtn.Text = (p.hudHand == "left") and "GAUCHE" or "DROITE"
        for _, entry in ipairs(typedLabels) do
            StyleConstants.applyTypography(entry.label, entry.level, p.fontScale)
        end
    end

    fsMinus.MouseButton1Click:Connect(function()
        local p = deps.getPrefs()
        local nextVal = math.max(GameConfig.Ui.fontScaleMin, math.round((p.fontScale - 0.05) * 100) / 100)
        deps.setPrefs({ fontScale = nextVal })
        render()
    end)
    fsPlus.MouseButton1Click:Connect(function()
        local p = deps.getPrefs()
        local nextVal = math.min(GameConfig.Ui.fontScaleMax, math.round((p.fontScale + 0.05) * 100) / 100)
        deps.setPrefs({ fontScale = nextVal })
        render()
    end)
    cbBtn.MouseButton1Click:Connect(function()
        local p = deps.getPrefs()
        local idx = (table.find(COLORBLIND_CYCLE, p.colorblindMode) or 1) % #COLORBLIND_CYCLE + 1
        deps.setPrefs({ colorblindMode = COLORBLIND_CYCLE[idx] })
        render()
    end)
    rmBtn.MouseButton1Click:Connect(function()
        local p = deps.getPrefs()
        deps.setPrefs({ reducedMotion = not p.reducedMotion })
        render()
    end)
    hcBtn.MouseButton1Click:Connect(function()
        local p = deps.getPrefs()
        deps.setPrefs({ highContrast = not p.highContrast })
        render()
    end)
    hhBtn.MouseButton1Click:Connect(function()
        local p = deps.getPrefs()
        deps.setPrefs({ hudHand = (p.hudHand == "left") and "right" or "left" })
        render()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        root.Visible = false
        isOpenFlag = false
    end)

    local function open()
        isOpenFlag = true
        render()
        root.Visible = true
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
    local function destroy()
        root:Destroy()
    end

    return {
        open = open,
        close = close,
        toggle = toggle,
        isOpen = isOpen,
        refresh = render,
        destroy = destroy,
    }
end

return AccessibilityScreen
