---
title: "Roblox Studio Plugin Development — Official Docs + DevForum Tutorial"
type: raw-source
source_url: https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/studio/plugins.md
source_type: official-docs
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: studio-features
tags: [plugin, DockWidgetPluginGui, PluginToolbar, PluginMenu, studio-extension]
---

# Roblox Studio Plugin Development

## What is a Plugin?

A plugin extends Studio's functionality through custom features. Developers can install community plugins from the Creator Store or create and publish their own to the Toolbox.

## Creating Plugins

### Setup Requirements

Enable Plugin Debugging Enabled in Studio settings to access PluginDebugService, which provides real-time debugging and easier plugin reloading.

### Basic Plugin Structure

1. Insert a Script in ServerStorage and rename it appropriately
2. Write plugin logic using Lua
3. Select "Save as Local Plugin" from the Plugins menu
4. The plugin appears in PluginDebugService and runs immediately

Delete the original script in ServerStorage and work only from the PluginDebugService version.

## Plugin Class API Reference

### Properties
- CollisionEnabled (boolean, ReadOnly): Whether user has enabled Collisions in Studio toolbar
- GridSize (float, ReadOnly): Grid snapping size the user has set
- IsDebuggable (boolean, Read/Write): Debuggability flag
- DisableUIDragDetectorDrags (boolean, Read/Write): UI drag detector control

### Key Methods

**CreateToolbar(name: string) -> PluginToolbar**
Creates a new toolbar with the given name for organizing plugin buttons.

**CreateDockWidgetPluginGuiAsync(pluginGuiId: string, info: DockWidgetPluginGuiInfo) -> DockWidgetPluginGui**
Yields. Generates a dockable widget panel from a DockWidgetPluginGuiInfo object.

**CreatePluginMenu(id: string, title: string, icon: string) -> PluginMenu**
Creates a new plugin menu that displays PluginAction items and submenus as context menus.

**CreatePluginAction(actionId: string, text: string, statusTip: string, iconName: string, allowBinding: boolean) -> PluginAction**
Generates a performable action without direct toolbar button association.

**Activate(exclusiveMouse: boolean) -> void**
Sets the state of the calling plugin to activated. Only one plugin activates at a time.

**Deactivate() -> void**
Disengages the plugin and associated PluginMouse functionality.

**GetSetting(key: string) -> Variant**
Retrieves a previously stored value, or nil if key doesn't exist.

**SetSetting(key: string, value: Variant) -> void**
Stores a value that persists even after Studio is closed. Value stored in JSON format.

### Events
- Deactivation: Fired when the Plugin is deactivated
- Unloading: Fires immediately before the Plugin stops running (enables cleanup)

## DockWidgetPluginGui Creation

```lua
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,  -- Initial dock state
    false,                         -- Initially enabled
    false,                         -- Override previous enabled state
    200,                           -- Default width
    200,                           -- Default height
    150,                           -- Minimum width
    150                            -- Minimum height
)
local widget = plugin:CreateDockWidgetPluginGui("PluginName", widgetInfo)
```

## Toolbar & Button Integration

```lua
local toolbar = plugin:CreateToolbar("PluginName")
local toggle = toolbar:CreateButton("Toggle", "Tooltip text", "")
toggle.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)
```

## ChangeHistoryService Integration

Call TryBeginRecording() before modifications and FinishRecording() afterward to enable undo/redo. Only one active recording per plugin is permitted.

## Publishing Plugins

1. Select the plugin script in Explorer
2. Choose "Publish as Plugin" from the Plugins menu
3. Upload optional 512x512 thumbnail
4. Complete required fields: Name, Description, Creator attribution
5. Submit to make the plugin available in Toolbox

### Monetization
Plugins can be distributed freely or sold for USD. Developers receive 100% of net proceeds on transactions, bypassing platform fees and DevEx rates.

## Workflow Tips
- Use Save and Reload Plugin (right-click) for targeted updates
- Use Reload Plugin to test without saving
- Ctrl+Shift+L to reload all plugins simultaneously

## Studio Theme Integration
- GuiUtilities.syncGuiElementBackgroundColor(): auto-syncs frame colors to studio theme
- CustomTextButton: styled buttons matching studio aesthetics
- StudioWidgets API (archived GitHub repo) for theme-consistent interfaces
