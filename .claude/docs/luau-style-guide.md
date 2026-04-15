# Luau Style Guide

The official coding style for FoG Roblox Studio Command projects.

## 1. Naming Conventions

| Scope | Convention | Example |
|-------|-----------|---------|
| Modules / Classes / Services | PascalCase | `PlayerDataService`, `CombatSystem`, `Trove` |
| Types | PascalCase | `type PlayerData = {...}` |
| Functions (public) | PascalCase or camelCase (pick one and stick with it) | `PlayerData.GetData` or `PlayerData.getData` |
| Functions (private / local) | camelCase | `local function computeDamage(...)` |
| Variables | camelCase | `local playerCount = 10` |
| Constants | UPPER_SNAKE_CASE | `local MAX_PLAYERS = 50` |
| Parameters | camelCase | `function foo(playerId: number)` |
| Files | PascalCase matching module | `PlayerDataService.lua` |

**Recommendation**: Use `PascalCase` for public module methods to mimic Roblox native services (e.g., `Players:GetPlayerByUserId`).

## 2. Type Annotations

All public function signatures get type annotations:

```lua
-- Good
function PlayerDataService.getData(player: Player): PlayerData?
    return playerDataCache[player]
end

-- Good (with multi-return)
function Inventory.addItem(player: Player, itemId: string, quantity: number): (boolean, string?)
    -- returns (success, errorMessage)
end

-- Bad
function PlayerDataService.getData(player)
    return playerDataCache[player]
end
```

Local functions should also use annotations when they're non-trivial:

```lua
local function computeDamage(base: number, weaponBonus: number, defense: number): number
    return math.max(0, base + weaponBonus - defense)
end
```

## 3. Module Structure

Every module follows this template:

```lua
-- ModuleName
--
-- Brief description of purpose.

-- 1. Service caching
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- 2. Dependencies
local Types = require(game.ReplicatedStorage.Shared.Types)
local Trove = require(game.ReplicatedStorage.Shared.Trove)

-- 3. Types (exported)
export type PlayerData = Types.PlayerData

-- 4. Constants
local AUTOSAVE_INTERVAL = 300  -- seconds
local MAX_RETRIES = 5

-- 5. Private state
local cache: {[Player]: PlayerData} = {}

-- 6. Private functions
local function computeHash(data: PlayerData): string
    -- ...
end

-- 7. Public module definition
local PlayerDataService = {}

-- 8. Public functions
function PlayerDataService.getData(player: Player): PlayerData?
    return cache[player]
end

function PlayerDataService.saveData(player: Player)
    -- ...
end

-- 9. Return
return PlayerDataService
```

## 4. Service Caching

Always cache services at the top of the module:

```lua
-- GOOD
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
```

```lua
-- BAD — repeated lookups
local function foo()
    return game:GetService("Players"):GetPlayerByUserId(123)
end
```

## 5. No Deprecated APIs

Never use:
- `wait(n)` → use `task.wait(n)`
- `spawn(f)` → use `task.spawn(f)`
- `delay(n, f)` → use `task.delay(n, f)`

`wait()` is not just slower — it throttles for performance reasons and can add up to 30ms to your timing.

## 6. Error Handling

Wrap every external call in pcall:

```lua
local success, result = pcall(function()
    return DataStore:GetAsync(key)
end)

if success then
    return result
else
    warn("DataStore call failed: " .. tostring(result))
    return nil
end
```

For operations that should retry:

```lua
local function retryDataStoreCall(fn, maxRetries: number): (boolean, any)
    for attempt = 1, maxRetries do
        local success, result = pcall(fn)
        if success then
            return true, result
        end
        task.wait(2 ^ attempt)  -- exponential backoff
    end
    return false, nil
end
```

## 7. Connection Cleanup

Every connection needs a cleanup path. Use Trove (or Maid):

```lua
local Trove = require(game.ReplicatedStorage.Shared.Trove)

local function createEnemy(position: Vector3)
    local trove = Trove.new()

    local part = Instance.new("Part")
    part.Position = position
    part.Parent = workspace
    trove:Add(part)

    trove:Add(part.Touched:Connect(function(hit)
        -- handle
    end))

    -- Cleanup function
    local function destroy()
        trove:Clean()
    end

    return destroy
end
```

## 8. Comments

Comments explain **why**, not **what**. The code shows what it does.

```lua
-- BAD: explains what
-- Loop through players
for _, player in ipairs(players) do
    -- ...
end

-- GOOD: explains why
-- Reverse order because we're removing items during iteration
for i = #items, 1, -1 do
    -- ...
end

-- GOOD: documents a workaround
-- Workaround for Roblox bug: Humanoid.WalkSpeed reset on respawn
humanoid.WalkSpeed = persistedSpeed
```

### Documentation Comments

For public module functions, use this style:

```lua
--[[
    Saves a player's data to DataStore with retry logic.

    @param player The player whose data to save
    @param data The data table to persist
    @return success True if save succeeded
    @return errorMessage Error details if save failed
]]
function PlayerDataService.saveData(player: Player, data: PlayerData): (boolean, string?)
    -- ...
end
```

## 9. Magic Numbers

No magic numbers in gameplay code. Every tunable value goes in config:

```lua
-- BAD
humanoid:TakeDamage(50)

-- GOOD
humanoid:TakeDamage(Config.BaseDamage)
```

## 10. Table Usage

### Prefer explicit over implicit

```lua
-- BAD — unclear what keys are
local data = {"PlayerName", 100, true}

-- GOOD — named keys
local data = {
    name = "PlayerName",
    level = 100,
    isAdmin = true,
}
```

### Use `ipairs` for arrays, `pairs` for maps

```lua
for i, item in ipairs(arrayOfItems) do
    -- i is 1, 2, 3, ...
end

for key, value in pairs(mapOfData) do
    -- key is unordered
end
```

### Preallocate tables in hot paths

```lua
-- In a hot loop, preallocate
local results = table.create(1000)
for i = 1, 1000 do
    results[i] = compute(i)
end
```

## 11. Indentation

- 4 spaces (not tabs)
- Consistent throughout the file

Most Luau linters and formatters use 4 spaces by default (Selene, StyLua).

## 12. Line Length

- Soft limit: 100 characters
- Hard limit: 120 characters

Break long function calls:

```lua
local result = ComplexFunction(
    argumentOne,
    argumentTwo,
    argumentThree,
    argumentFour
)
```

## 13. Git Commit Messages

Format: `type(scope): description`

Types:
- `feat` — new feature
- `fix` — bug fix
- `refactor` — code refactoring (no behavior change)
- `perf` — performance improvement
- `test` — adding / updating tests
- `docs` — documentation
- `style` — formatting (no semantic change)
- `chore` — maintenance

Examples:
- `feat(combat): add parry mechanic`
- `fix(datastore): resolve race condition in save logic`
- `perf(render): reduce particle overdraw on mobile`
- `docs(gdd): update combat GDD to match implementation`

## 14. Branches

Naming:
- `feature/<description>` — new features
- `fix/<description>` — bug fixes
- `refactor/<description>` — refactors
- `prototype/<description>` — experiments
- `hotfix/<description>` — emergency fixes

Merge strategy: prefer squash merge for PRs to keep history clean.

## 15. Tooling

- **Selene**: Luau linter. Run via `selene src/`.
- **StyLua**: Luau formatter. Run via `stylua src/`.
- **TestEZ** or **Jest-Lua**: Unit testing frameworks.
- **Rojo** or **Argon**: File-to-Roblox sync.
- **Wally**: Package manager.

Configure these via Aftman (`aftman.toml`) for reproducible installs.
