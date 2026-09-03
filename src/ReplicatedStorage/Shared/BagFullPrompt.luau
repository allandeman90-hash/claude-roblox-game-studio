--!strict
--==============================================================
-- BagFullPrompt  (ModuleScript - ReplicatedStorage/Shared)
--
-- Full-bag confirmation modal (design/specs/inventory-implementation-spec.md
-- §10.1 / §7 "BagFullPrompt"). Shown when a loot/purchase drop would exceed
-- capacity. Lets the player pick an existing bag item to sacrifice, then
-- resolves via the SAME multiplexed CombatEvent every other remote in this
-- project uses (see integration note below) - never a dedicated remote.
--
-- Server contract actually implemented today (InventoryService.luau +
-- CombatServer.server.luau), used as the source of truth for this module:
--   - There is NO separate "bag_full" message type. CombatServer's loot
--     handler already reuses the "loot" message for this: when
--     InventoryService.addItem hits capacity it returns (false, "bag_full")
--     and CombatServer fires
--       { type = "loot", item = <new item draft>, kept = false, reason = "bag_full" }.
--     InventoryClient.client.luau treats that as the open-modal trigger and
--     calls BagFullPrompt.show(item) - see that file for the dispatcher.
--   - The player does NOT pick "the new item" (it has no itemKey yet - it
--     was never inserted). They pick an EXISTING bag item (`targetItemKey`)
--     to free a slot, matching InventoryService.confirmFullBagAction's
--     three choices:
--       "keep_new"  - remove targetItemKey, then insert the new item
--       "keep_old"  - discard the new item, bag untouched (no target needed)
--       "drop_both" - remove targetItemKey AND discard the new item
--   - Resolution fires:
--       CombatEvent:FireServer({ type = "confirmFullBagAction", choice = ..., targetItemKey = ... })
--     and the server always replies:
--       { type = "bagActionConfirmed", ok = boolean, reason = string? }
--     BagFullPrompt never listens to CombatEvent directly - InventoryClient
--     (the single dispatcher, per design/specs/inventory-implementation-spec.md
--     integration notes) calls BagFullPrompt.handleConfirmed(ok, reason).
--   - The server's own 30s auto-discard timer (GameConfig.Inventory.
--     bagFullTimeoutSeconds) is independent of this UI: if the player never
--     answers, the server silently resolves it. This module's countdown is
--     COSMETIC ONLY - on reaching 0 it just closes the modal; it does not
--     fire anything (there is nothing left to confirm).
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

export type BagFullPromptDeps = {
    getBagItems: () -> { [string]: Types.ItemInstance },
    getUiPrefs: () -> UiPrefs,
}

export type BagFullPromptApi = {
    show: (newItem: { [string]: any }) -> (),
    hide: () -> (),
    handleConfirmed: (ok: boolean, reason: string?) -> (),
    isPending: () -> boolean,
    destroy: () -> (),
}

local BagFullPrompt = {}

-- Resolves a display name for either a loot draft (`.nom` present, per
-- CombatServer's loot payload) or a bag ItemInstance (`.nom` absent - only
-- `.id`, per Types.ItemInstance §5.1).
local function displayName(item: { [string]: any }): string
    if type(item.nom) == "string" and item.nom ~= "" then
        return item.nom
    end
    local def = EquipmentConfig.getItem(item.id)
    if def and type(def.nom) == "string" then
        return def.nom
    end
    return tostring(item.id or "?")
end

local function rarityOf(item: { [string]: any }): string
    return item.rarete or item.rarity or "commun"
end

function BagFullPrompt.mount(rpgGui: ScreenGui, combatEvent: RemoteEvent, deps: BagFullPromptDeps): BagFullPromptApi
    local ZM = StyleConstants.ModalZ

    --== Dim backdrop (blocks input to whatever is behind, focuses attention) ==--
    local backdrop = Instance.new("Frame")
    backdrop.Name = "BagFullBackdrop"
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
    backdrop.BackgroundTransparency = 1
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = StyleConstants.ModalDimZ
    backdrop.Active = true
    backdrop.Visible = false
    backdrop.Parent = rpgGui

    --== Root modal frame ==--
    local root = Instance.new("Frame")
    root.Name = "BagFullPrompt"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.fromScale(0.62, 0.66)
    root.BackgroundColor3 = StyleConstants.BaseColors.Background
    root.BorderSizePixel = 0
    root.ZIndex = ZM
    root.Visible = false
    root.Active = true
    root.Parent = rpgGui
    -- Alert-red frame - this is a
    -- destructive/warning modal ("SAC PLEIN"), keep it visually distinct.
    StyleConstants.addStroke(root, 4, StyleConstants.BaseColors.Alert)
    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(340, 300)
    sizeConstraint.Parent = root

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Size = UDim2.new(1, -24, 0, 30)
    title.Font = StyleConstants.Fonts.Heading
    title.Text = "SAC PLEIN"
    title.TextColor3 = StyleConstants.BaseColors.Alert
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = ZM
    title.Parent = root
    StyleConstants.applyTypography(title, "Heading")

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 12, 0, 40)
    subtitle.Size = UDim2.new(1, -24, 0, 44)
    subtitle.Font = StyleConstants.Fonts.Body
    subtitle.Text = ""
    subtitle.TextColor3 = StyleConstants.BaseColors.TextPrimary
    subtitle.TextWrapped = true
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Top
    subtitle.ZIndex = ZM
    subtitle.Parent = root
    StyleConstants.applyTypography(subtitle, "Body")

    local hint = Instance.new("TextLabel")
    hint.Name = "Hint"
    hint.BackgroundTransparency = 1
    hint.Position = UDim2.new(0, 12, 0, 86)
    hint.Size = UDim2.new(1, -24, 0, 20)
    hint.Font = StyleConstants.Fonts.Body
    hint.Text = "Sélectionnez un objet à retirer du sac ci-dessous."
    hint.TextColor3 = StyleConstants.BaseColors.TextSecondary
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.ZIndex = ZM
    hint.Parent = root
    StyleConstants.applyTypography(hint, "Label")

    --== Scrollable list of current bag items (selection target) ==--
    local list = Instance.new("ScrollingFrame")
    list.Name = "TargetList"
    list.Position = UDim2.new(0, 12, 0, 110)
    list.Size = UDim2.new(1, -24, 1, -172)
    list.BackgroundColor3 = StyleConstants.BaseColors.Panel
    list.BackgroundTransparency = 0.1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 6
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ZIndex = ZM
    list.Parent = root
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = list

    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "ErrorLabel"
    errorLabel.BackgroundTransparency = 1
    errorLabel.Position = UDim2.new(0, 12, 1, -62)
    errorLabel.Size = UDim2.new(1, -24, 0, 18)
    errorLabel.Font = StyleConstants.Fonts.Body
    errorLabel.Text = ""
    errorLabel.TextColor3 = StyleConstants.BaseColors.Alert
    errorLabel.TextXAlignment = Enum.TextXAlignment.Left
    errorLabel.ZIndex = ZM
    errorLabel.Parent = root
    StyleConstants.applyTypography(errorLabel, "Label")

    --== Action row: KEEP NEW / KEEP OLD / DROP BOTH ==--
    local actionRow = Instance.new("Frame")
    actionRow.Name = "Actions"
    actionRow.BackgroundTransparency = 1
    actionRow.Position = UDim2.new(0, 12, 1, -44)
    actionRow.Size = UDim2.new(1, -24, 0, 40)
    actionRow.ZIndex = ZM
    actionRow.Parent = root
    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, 6)
    rowLayout.Parent = actionRow

    local function actionButton(text: string, width: number, variant: string?): TextButton
        local b = StyleConstants.makeButton(text, "Label", variant)
        b.Size = UDim2.new(width, -4, 1, 0)
        b.ZIndex = ZM
        b.Parent = actionRow
        return b
    end

    -- Gold = primary confirm, gray = neutral no-op, red = destructive - same
    -- three-color mapping as InventoryScreen's action bar.
    local btnKeepNew = actionButton("[ GARDER LE NOUVEL OBJET ]", 0.40, "gold")
    local btnKeepOld = actionButton("[ GARDER L'ANCIEN ]", 0.30, "gray")
    local btnDropBoth = actionButton("[ JETER LES DEUX ]", 0.30, "red")

    --== Internal state ==--
    local pendingNewItem: { [string]: any }? = nil
    local selectedTargetKey: string? = nil
    local rowButtons: { [string]: Frame } = {}
    local countdownThread: thread? = nil
    local lastActionAt = 0
    local ACTION_DEBOUNCE = 0.35 -- rate-limit UI feedback: ignore mashed clicks

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

    local function setButtonsEnabled(enabled: boolean)
        for _, b in ipairs({ btnKeepNew, btnKeepOld, btnDropBoth }) do
            b.AutoButtonColor = false
            b.Active = enabled
            b.TextTransparency = enabled and 0 or 0.55
        end
        -- keep/new + drop/both additionally require a selection
        local hasTarget = selectedTargetKey ~= nil
        btnKeepNew.Active = enabled and hasTarget
        btnDropBoth.Active = enabled and hasTarget
        btnKeepNew.TextTransparency = (enabled and hasTarget) and 0 or 0.55
        btnDropBoth.TextTransparency = (enabled and hasTarget) and 0 or 0.55
    end

    local function refreshRowHighlights()
        for key, row in pairs(rowButtons) do
            local stroke = row:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = (key == selectedTargetKey) and StyleConstants.BaseColors.Accent or StyleConstants.BaseColors.Border
                stroke.Thickness = (key == selectedTargetKey) and 3 or 1
            end
        end
    end

    local function selectTarget(key: string?)
        selectedTargetKey = key
        refreshRowHighlights()
        setButtonsEnabled(true)
    end

    local function populateList()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        rowButtons = {}
        selectedTargetKey = nil

        local ok, items = pcall(deps.getBagItems)
        items = (ok and items) or {}

        local keys = {}
        for k in pairs(items) do keys[#keys + 1] = k end
        table.sort(keys, function(a, b)
            return (items[a].droppedAtTime or 0) > (items[b].droppedAtTime or 0)
        end)

        if #keys == 0 then
            local empty = Instance.new("TextLabel")
            empty.BackgroundTransparency = 1
            empty.Size = UDim2.new(1, 0, 0, 28)
            empty.Font = StyleConstants.Fonts.Body
            empty.Text = "  (sac vide - ceci ne devrait pas arriver)"
            empty.TextColor3 = StyleConstants.BaseColors.TextSecondary
            empty.TextXAlignment = Enum.TextXAlignment.Left
            empty.ZIndex = ZM
            empty.Parent = list
            StyleConstants.applyTypography(empty, "Label")
            return
        end

        for _, key in ipairs(keys) do
            local item = items[key]
            local rar = StyleConstants.rarityInfo(item.rarity)
            local row = Instance.new("TextButton")
            row.Name = "Row_" .. key
            row.AutoButtonColor = false
            row.BackgroundColor3 = StyleConstants.BaseColors.Slot
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, 32)
            row.Font = StyleConstants.Fonts.Body
            row.TextXAlignment = Enum.TextXAlignment.Left
            local lockTag = item.locked and "  [V]" or ""
            local forgeTag = (item.forgeLevel or 0) > 0 and ("  +" .. tostring(item.forgeLevel)) or ""
            row.Text = string.format("  %s %s%s%s  (%s)", rar.symbol, displayName(item), forgeTag, lockTag, rar.label)
            row.TextColor3 = rar.color
            row.ZIndex = ZM
            row.Parent = list
            StyleConstants.addStroke(row, 1, StyleConstants.BaseColors.Border)
            StyleConstants.applyTypography(row, "Label")
            rowButtons[key] = row

            row.MouseButton1Click:Connect(function()
                if item.locked then
                    errorLabel.Text = "Objet verrouillé - déverrouillez-le d'abord pour le jeter."
                    return
                end
                errorLabel.Text = ""
                selectTarget(key)
            end)
        end
    end

    local function setVisible(visible: boolean)
        local p = prefs()
        if p.reducedMotion then
            root.Visible = visible
            backdrop.Visible = visible
            root.BackgroundTransparency = visible and 0 or 1
            backdrop.BackgroundTransparency = visible and 0.45 or 1
            return
        end
        if visible then
            root.Visible = true
            backdrop.Visible = true
            root.Size = UDim2.fromScale(0.56, 0.60)
            local tw = TweenService:Create(root, TweenInfo.new(StyleConstants.ModalTweenSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromScale(0.62, 0.66),
            })
            tw:Play()
            TweenService:Create(backdrop, TweenInfo.new(StyleConstants.ModalTweenSeconds), { BackgroundTransparency = 0.45 }):Play()
        else
            local tw = TweenService:Create(backdrop, TweenInfo.new(StyleConstants.ModalTweenSeconds), { BackgroundTransparency = 1 })
            tw.Completed:Connect(function()
                root.Visible = false
                backdrop.Visible = false
            end)
            tw:Play()
        end
    end

    local function stopCountdown()
        if countdownThread then
            task.cancel(countdownThread)
            countdownThread = nil
        end
    end

    local function hide()
        stopCountdown()
        pendingNewItem = nil
        selectedTargetKey = nil
        errorLabel.Text = ""
        setVisible(false)
    end

    local function startCountdown()
        stopCountdown()
        local timeoutSec = GameConfig.Inventory.bagFullTimeoutSeconds or 30
        local deadline = os.clock() + timeoutSec
        countdownThread = task.spawn(function()
            while pendingNewItem and os.clock() < deadline do
                local remaining = math.max(0, math.ceil(deadline - os.clock()))
                local item = pendingNewItem
                if item then
                    local rar = StyleConstants.rarityInfo(rarityOf(item))
                    subtitle.Text = string.format(
                        "Nouvel objet : %s %s (%s).\nLe sac est plein (délai : %ds).",
                        rar.symbol, displayName(item), rar.label, remaining
                    )
                end
                task.wait(0.5)
            end
            -- Cosmetic timeout: the server already auto-discarded server-side
            -- (InventoryService.startFullBagTimer) - nothing to fire here.
            if pendingNewItem then
                hide()
            end
        end)
    end

    local function show(newItem: { [string]: any })
        if root.Visible then
            -- InventoryService only tracks ONE pending prompt per player and
            -- silently drops a second arrival - mirror that here (spec §6).
            return
        end
        pendingNewItem = newItem
        errorLabel.Text = ""
        populateList()
        setButtonsEnabled(true)
        setVisible(true)
        startCountdown()
    end

    local function fireChoice(choice: string)
        local now = os.clock()
        if now - lastActionAt < ACTION_DEBOUNCE then
            return -- rate-limit UI feedback: ignore mashed clicks
        end
        lastActionAt = now
        if (choice == "keep_new" or choice == "drop_both") and not selectedTargetKey then
            errorLabel.Text = "Choisissez d'abord un objet à retirer."
            return
        end
        errorLabel.Text = ""
        setButtonsEnabled(false)
        combatEvent:FireServer({
            type = "confirmFullBagAction",
            choice = choice,
            targetItemKey = selectedTargetKey,
        })
    end

    btnKeepNew.MouseButton1Click:Connect(function() fireChoice("keep_new") end)
    btnKeepOld.MouseButton1Click:Connect(function() fireChoice("keep_old") end)
    btnDropBoth.MouseButton1Click:Connect(function() fireChoice("drop_both") end)

    local function handleConfirmed(ok: boolean, reason: string?)
        if not root.Visible and not pendingNewItem then
            return
        end
        if reason == "no_pending_action" or reason == "unavailable" then
            -- Window already closed/expired server-side - close silently,
            -- no error surfaced (spec: "on failure (no pending action),
            -- silently ignores").
            hide()
            return
        end
        if ok then
            hide()
            return
        end
        -- Recoverable failure (bad target, locked item, etc.) - keep the
        -- modal open so the player can pick a different target.
        setButtonsEnabled(true)
        errorLabel.Text = "Action refusée : " .. tostring(reason or "erreur inconnue")
    end

    local function isPending(): boolean
        return pendingNewItem ~= nil
    end

    local function destroy()
        stopCountdown()
        root:Destroy()
        backdrop:Destroy()
    end

    return {
        show = show,
        hide = hide,
        handleConfirmed = handleConfirmed,
        isPending = isPending,
        destroy = destroy,
    }
end

return BagFullPrompt
