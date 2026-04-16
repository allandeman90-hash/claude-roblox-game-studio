---
title: Plugin Development
type: studio
category: studio
subcategory: extensibility
owner: roblox-studio-specialist
status: draft
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/studio-features/plugin-development-guide.md
related:
  - "[[packages]]"
  - "[[collection-service-tags]]"
tags: [studio, plugin, DockWidgetPluginGui, PluginToolbar, PluginMenu, extensibility]
---

# Plugin Development

> Extending Roblox Studio with custom tools, widgets, and toolbar buttons via the Plugin API.

## Summary

Studio plugins are scripts that run inside the editor (not in-game) to add custom functionality: tag editors, asset importers, debug visualizers, level design aids, and more. The Plugin API provides access to toolbars, dockable widget panels, context menus, persistent settings, and the user's selection. Plugins can be used locally during development or published to the Creator Store for distribution.

## Plugin API Surface

### The `plugin` Global

Every plugin script has access to the `plugin` global, an instance of the `Plugin` class.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `CollisionEnabled` | boolean (ReadOnly) | Whether user has Collisions enabled in toolbar |
| `GridSize` | float (ReadOnly) | Current grid snap size |
| `IsDebuggable` | boolean | Whether the plugin can be debugged |

### Key Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `CreateToolbar(name)` | `PluginToolbar` | Creates a named toolbar section in the Plugins tab |
| `CreateDockWidgetPluginGuiAsync(id, info)` | `DockWidgetPluginGui` | Creates a dockable widget panel (yields) |
| `CreatePluginMenu(id, title, icon)` | `PluginMenu` | Creates a context menu |
| `CreatePluginAction(id, text, tip, icon, bind)` | `PluginAction` | Creates a bindable action |
| `Activate(exclusiveMouse)` | void | Activates plugin (deactivates others) |
| `Deactivate()` | void | Deactivates plugin |
| `GetSetting(key)` | Variant | Reads a persistent setting |
| `SetSetting(key, value)` | void | Writes a persistent setting (survives Studio restart) |
| `GetMouse()` | `PluginMouse` | Gets mouse for custom viewport interaction |

### Events

| Event | When |
|-------|------|
| `Deactivation` | Plugin is deactivated (another plugin activates or user deactivates) |
| `Unloading` | Plugin is about to stop running (cleanup opportunity) |

## Common Patterns

### Toolbar Button + Dock Widget

```lua
-- Create toolbar and button
local toolbar = plugin:CreateToolbar("My Plugin")
local button = toolbar:CreateButton(
    "Toggle Widget",
    "Opens the plugin panel",
    "rbxassetid://123456"  -- icon
)

-- Create dock widget
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,  -- dock state
    false,  -- initially enabled
    false,  -- override previous state
    300,    -- default width
    400,    -- default height
    200,    -- minimum width
    150     -- minimum height
)
local widget = plugin:CreateDockWidgetPluginGui("MyPlugin", widgetInfo)
widget.Title = "My Plugin"

-- Toggle visibility on button click
button.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)
```

### Undo/Redo with ChangeHistoryService

```lua
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local function performEdit()
    local recording = ChangeHistoryService:TryBeginRecording("MyEdit")
    if not recording then return end

    -- Make changes to the DataModel here
    local part = Instance.new("Part")
    part.Parent = workspace

    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end
```

Only one active recording per plugin at a time. Always call `FinishRecording` even on failure (use `Cancel` operation).

### Context Menu

```lua
local menu = plugin:CreatePluginMenu("MyContextMenu", "Options", "")
local action1 = menu:AddNewAction("action1", "Delete Selected", "")
local action2 = menu:AddNewAction("action2", "Duplicate Selected", "")

local selected = menu:ShowAsync()  -- blocks until user picks
if selected == action1 then
    -- handle delete
elseif selected == action2 then
    -- handle duplicate
end
menu:Destroy()
```

### Persistent Settings

```lua
-- Save a preference
plugin:SetSetting("theme", "dark")
plugin:SetSetting("lastUsedColor", {R = 255, G = 0, B = 128})

-- Load it back (survives Studio restart)
local theme = plugin:GetSetting("theme") or "light"
```

### Studio Theme Integration

```lua
local studioTheme = settings().Studio.Theme

-- Read theme colors for consistent UI
local bgColor = studioTheme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
local textColor = studioTheme:GetColor(Enum.StudioStyleGuideColor.MainText)

-- Listen for theme changes
settings().Studio.ThemeChanged:Connect(function()
    -- re-read colors and update UI
end)
```

## Publishing

1. Select the plugin script in Explorer.
2. Plugins menu > **Publish as Plugin**.
3. Upload optional 512x512 thumbnail.
4. Fill Name, Description, Creator.
5. Submit.

Plugins can be sold for USD on the Creator Store. Developers receive 100% of net proceeds, bypassing platform fees and DevEx rates.

## Development Workflow

- Enable **Plugin Debugging Enabled** in Studio settings for access to `PluginDebugService`.
- Right-click plugin > **Save and Reload Plugin** for targeted updates.
- `Ctrl+Shift+L` to reload all plugins.
- Delete original script in ServerStorage after saving as local plugin; work from PluginDebugService copy.

## Pitfalls

- Only one plugin can be `Activate()`d at a time; others receive `Deactivation`.
- `CreateDockWidgetPluginGuiAsync` yields; widget ID must be unique and persistent (determines dock state restoration).
- `GridSize` may have floating-point rounding errors.
- Plugin scripts run in a special security context (`PluginSecurity`); not all APIs available.
- Cleanup on `Unloading` is essential to avoid leaked connections and UI elements.

## Related

- [[packages]] -- Plugins can automate package workflows.
- [[collection-service-tags]] -- Tag Editor is a popular community plugin built on this API.

## Sources

- [Roblox Creator Docs: Plugins](wiki/raw/community/articles/studio-features/plugin-development-guide.md)
- [DevForum: Make Your First Dock Widget Plugin](https://devforum.roblox.com/t/make-your-first-dock-widget-plugin/355951)
- [Roblox Plugin class API](https://create.roblox.com/docs/reference/engine/classes/Plugin)
- [DockWidgetPluginGui API](https://create.roblox.com/docs/reference/engine/classes/DockWidgetPluginGui)
