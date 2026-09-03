--!strict
--==============================================================
-- StyleConstants  (ModuleScript - ReplicatedStorage/Shared)
--
-- Central theme values: colors, spacing, typography, ZIndex layers. Every UI
-- screen module (BagFullPrompt, InventoryScreen, AccessibilityScreen, and
-- any future screen) reads from here instead of hardcoding values, per
-- design/gdd/ui-ux-gdd.md §2. Pure data + pure helper functions - no
-- gameplay state, no service calls beyond reading GameConfig.
--
-- THEME (2026-09-03 FoG HUD pass): soft charcoal panels, thin even
-- borders, monospace text, and yellow accent labels inspired by
-- Réference/mon ui final.png. Public API surface
-- (BaseColors keys, addStroke/addCorner/makeButton/applyTypography/
-- rarityInfo signatures) is UNCHANGED so existing screens keep working
-- without edits - only values (colors, fonts, bevel look) changed, plus a
-- few new additive keys (Panel/Slot/SlotBorder/BorderDark/Fonts/
-- ButtonVariants) that nothing depended on before.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local StyleConstants = {}

--========================================================
-- ZINDEX LAYERS  (ui-ux-gdd.md §2.2)
--========================================================
-- RpgGui uses ZIndexBehavior.Global (see CombatClient.client.luau), so these
-- raw numbers control draw order across the WHOLE tree regardless of parent.
StyleConstants.ZIndexLayers = {
    WORLD        = 0,
    HUD          = 2,
    POPUP        = 10,
    SCREEN       = 20,
    MODAL        = 90,
    FTUE_OVERLAY = 99,
    SYSTEM       = 100,
}

-- Per-screen SCREEN-layer offsets (ui-ux-gdd 2.2: "Inventaire 20s, Boutique
-- 25s, Feu de camp 30s, Codex 35s"). "Reglages" (accessibility settings) has
-- no assigned number in ui-ux-gdd.md yet; 22 is a placeholder between
-- Inventaire and Boutique - flagged for ux-designer to formalize in the GDD.
StyleConstants.ScreenZ = {
    Inventory = 20,
    Settings  = 22, -- [TODO ux-designer] not yet assigned in ui-ux-gdd.md §2.2
    Shop      = 25,
    Campfire  = 30,
    Codex     = 35,
}

-- BagFullPrompt spec: ZIndex 93 (MODAL layer 90-98, one modal visible at a time).
StyleConstants.ModalZ = 93
StyleConstants.ModalDimZ = StyleConstants.ModalZ - 1 -- the dimmed backdrop, just below

--========================================================
-- COLORS  (ui-ux-gdd.md §2.3) - La Descente final HUD theme
--========================================================
StyleConstants.BaseColors = {
    Background    = Color3.fromRGB(14, 15, 19),
    Panel         = Color3.fromRGB(18, 19, 24),
    Slot          = Color3.fromRGB(21, 22, 27),
    -- Thin dim borders (the old near-white 2px strokes read as a glow).
    SlotBorder    = Color3.fromRGB(96, 96, 101),
    Border        = Color3.fromRGB(96, 96, 101),
    BorderDark    = Color3.fromRGB(70, 70, 74),
    TextPrimary   = Color3.fromRGB(248, 246, 238),
    TextSecondary = Color3.fromRGB(162, 154, 132),
    Positive      = Color3.fromRGB(83, 190, 96),
    Alert         = Color3.fromRGB(224, 78, 70),
    -- Muted amber. The old (255,220,70) bloomed optically on the near-black HUD.
    Accent        = Color3.fromRGB(201, 168, 120),
}

-- Rarity id (EquipmentConfig.Rarities id, French: commun/rare/epique/
-- legendaire/mythique) -> { color, symbol, label }. "Regle d'or" (ui-ux-gdd
-- 2.3): no information is communicated by color alone - every rarity-tagged
-- element must ALSO render `symbol` and/or `label` text, unconditionally
-- (not gated on colorblindMode - see AccessibilityScreen.luau notes).
-- `commun` stays neutral; rare/epique/legendaire/mythique remain vivid so
-- item rarity stays readable on the restrained charcoal HUD.
StyleConstants.Rarities = {
    commun     = { color = Color3.fromRGB(176, 176, 176), symbol = "",                       label = "Commun" },
    rare       = { color = Color3.fromRGB(80, 160, 255),  symbol = "\u{25C6}",                label = "Rare" },
    epique     = { color = Color3.fromRGB(190, 110, 255), symbol = "\u{25C6}\u{25C6}",        label = "Épique" },
    legendaire = { color = Color3.fromRGB(255, 170, 60),  symbol = "\u{25C6}\u{25C6}\u{25C6}", label = "Légendaire" },
    mythique   = { color = Color3.fromRGB(230, 60, 60),   symbol = "\u{2605}",                label = "Mythique" },
}

function StyleConstants.rarityInfo(rarityId: string?)
    return StyleConstants.Rarities[rarityId or "commun"] or StyleConstants.Rarities.commun
end

--========================================================
-- SPACING  (ui-ux-gdd.md §2.5)
--========================================================
StyleConstants.SpacingScale = { 4, 8, 12, 16, 24, 32 }
StyleConstants.BaseSpacingPx = GameConfig.Ui.baseSpacingPx

--========================================================
-- TYPOGRAPHY  (ui-ux-gdd.md §2.4)
--========================================================
StyleConstants.Typography = {
    Display = { max = 30, min = 14 },
    Heading = { max = 22, min = 12 },
    Body    = { max = 18, min = 13 },
    Label   = { max = 14, min = 10 },
}

StyleConstants.Fonts = {
    Heading = Enum.Font.Code,
    Button  = Enum.Font.Code,
    Body    = Enum.Font.Code,
    Label   = Enum.Font.Code,
}

--[[
    Applies a UITextSizeConstraint to `label` for typography `level`
    ("Display"|"Heading"|"Body"|"Label"), scaled by `fontScale`
    (GameConfig.Ui.fontScaleMin..fontScaleMax, default 1.0). Idempotent:
    reuses an existing constraint on `label` so a live fontScale change can
    just call this again to rescale in place.
]]
function StyleConstants.applyTypography(label: TextLabel | TextButton, level: string, fontScale: number?)
    local t = StyleConstants.Typography[level] or StyleConstants.Typography.Body
    local scale = math.clamp(
        fontScale or GameConfig.Ui.fontScaleDefault,
        GameConfig.Ui.fontScaleMin,
        GameConfig.Ui.fontScaleMax
    )
    label.TextScaled = true
    local c = label:FindFirstChildOfClass("UITextSizeConstraint")
    if not c then
        c = Instance.new("UITextSizeConstraint")
        c.Parent = label
    end
    c.MinTextSize = math.max(1, math.floor(t.min * scale))
    c.MaxTextSize = math.max(c.MinTextSize, math.floor(t.max * scale))
end

--========================================================
-- ACCESSIBILITY / ANIMATION (GameConfig.Ui passthrough - single source)
--========================================================
StyleConstants.MinTouchTargetPx = GameConfig.Ui.minTouchTargetPx
StyleConstants.ButtonPressTweenSeconds = GameConfig.Ui.buttonPressTweenSeconds
StyleConstants.ModalTweenSeconds = GameConfig.Ui.modalTweenSeconds

--========================================================
-- LOW-LEVEL INSTANCE HELPERS  (shared across every UI screen module)
--========================================================
function StyleConstants.addStroke(parent: GuiObject, thickness: number?, color: Color3?): UIStroke
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or StyleConstants.BaseColors.Border
    s.Transparency = 0.15
    s.Parent = parent
    return s
end

function StyleConstants.addCorner(parent: GuiObject, radiusPx: number?): UICorner
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, math.clamp(radiusPx or 0, 0, 2))
    c.Parent = parent
    return c
end

local BUTTON_VARIANTS: { [string]: { fill: Color3, highlight: Color3, shadow: Color3, border: Color3, text: Color3 } } = {
    default = {
        fill      = Color3.fromRGB(11, 12, 16),
        highlight = Color3.fromRGB(11, 12, 16),
        shadow    = Color3.fromRGB(11, 12, 16),
        border    = Color3.fromRGB(218, 216, 208),
        text      = Color3.fromRGB(248, 246, 238),
    },
    green = {
        fill      = Color3.fromRGB(18, 38, 24),
        highlight = Color3.fromRGB(18, 38, 24),
        shadow    = Color3.fromRGB(18, 38, 24),
        border    = Color3.fromRGB(83, 190, 96),
        text      = Color3.fromRGB(244, 240, 224),
    },
    red = {
        fill      = Color3.fromRGB(42, 18, 18),
        highlight = Color3.fromRGB(42, 18, 18),
        shadow    = Color3.fromRGB(42, 18, 18),
        border    = Color3.fromRGB(224, 78, 70),
        text      = Color3.fromRGB(248, 236, 226),
    },
    gray = {
        fill      = Color3.fromRGB(22, 23, 27),
        highlight = Color3.fromRGB(22, 23, 27),
        shadow    = Color3.fromRGB(22, 23, 27),
        border    = Color3.fromRGB(130, 130, 135),
        text      = Color3.fromRGB(240, 238, 232),
    },
    gold = {
        fill      = Color3.fromRGB(11, 12, 16),
        highlight = Color3.fromRGB(11, 12, 16),
        shadow    = Color3.fromRGB(11, 12, 16),
        border    = Color3.fromRGB(201, 168, 120),
        text      = Color3.fromRGB(201, 168, 120),
    },
}
StyleConstants.ButtonVariants = BUTTON_VARIANTS

function StyleConstants.makeButton(text: string, level: string?, variant: string?): TextButton
    local palette = BUTTON_VARIANTS[variant or "default"] or BUTTON_VARIANTS.default

    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = palette.fill
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = StyleConstants.Fonts.Button
    btn.Text = text
    btn.TextColor3 = palette.text

    StyleConstants.addCorner(btn, 0)
    local stroke = StyleConstants.addStroke(btn, 1, palette.border)
    stroke.LineJoinMode = Enum.LineJoinMode.Miter

    StyleConstants.applyTypography(btn, level or "Body")
    return btn
end

return StyleConstants
