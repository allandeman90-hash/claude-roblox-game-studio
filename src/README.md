# `src/` — game source

The **live authority for the game right now is the Roblox Studio place file** (edited
via the Studio MCP, not Rojo-synced back yet). This folder is a **version-controlled
snapshot** so the work can never be lost.

## What's here

| Path | What |
|---|---|
| `ReplicatedStorage/GameConfig.luau` | all tuning constants + formulas |
| `ReplicatedStorage/ZoneConfig.luau` | per-zone decor + enemy roster (only zone 1 developed) |
| `ReplicatedStorage/EquipmentConfig.luau` | item / rarity / set definitions |
| `ReplicatedStorage/GuiBuilder.luau` | rebuilds a GUI from a `.gui.json` snapshot |
| `ServerScriptService/CombatServer.server.luau` | the orchestrator (world loop, combat, save) |
| `ServerScriptService/*.luau` | 8 services (Stats, Damage, Enemy, Loot, Zone, Shop, Equipment, PlayerData) |
| `StarterPlayer/StarterPlayerScripts/CombatClient.client.luau` | the whole client (HUD, scene, portals, overlays) |
| `StarterGui/RpgGui.gui.json` | serialised snapshot of the `RpgGui` ScreenGui (305 nodes) |

## Restoring the GUI

```lua
local HttpService = game:GetService("HttpService")
local data = HttpService:JSONDecode(<contents of RpgGui.gui.json>)
local gui  = require(game.ReplicatedStorage.GuiBuilder).build(data)
gui.Parent = game.StarterGui
```

Round-trip verified: 305 rebuilt nodes == 305 live nodes, 0 property failures.

## Keeping it in sync

For now the flow is: edit in Studio → re-dump to `src/` before committing. Chantier 3
(cleanup) will move to a proper Rojo two-way sync — at that point either commit
`StarterGui/RpgGui.rbxmx` (right-click the ScreenGui → *Save to File*) or wire
`GuiBuilder` to build it at runtime.
