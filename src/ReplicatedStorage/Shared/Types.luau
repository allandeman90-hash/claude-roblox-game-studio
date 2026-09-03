--!strict

export type PlayerData = {
    version: number,
    gold: number,
    level: number,
    xp: number,
    inventory: {[string]: number},
    settings: {
        musicVolume: number,
        sfxVolume: number,
    },
}

--==============================================================
-- Inventory Sprint (2026-09-02) - design/specs/inventory-implementation-spec.md §5.1
-- Unique-instance bag model: every dropped/purchased item is its own itemKey,
-- never stacked. Consumed by PlayerDataService (profile.inventory),
-- InventoryService (owns mutation), EquipmentService (equip/unequip bridge).
--==============================================================

-- One owned equipment instance. `itemType` is "weapon" for weapons, or the
-- armor piece's body location ("head"|"chest"|"hands"|"legs"|"feet") for
-- armor - open string, extensible (e.g. "pet" for the pet slot).
export type ItemInstance = {
    id: string,             -- item definition id, FK into EquipmentConfig
    itemType: string,       -- "weapon" | "head" | "chest" | "hands" | "legs" | "feet" | "pet"
    rarity: string,         -- "commun" | "rare" | "epique" | "legendaire" | "mythique"
    voie: string?,          -- "guerrier" | "mage" (nil for non-voie items, e.g. pets)
    baseStats: {[string]: number},  -- derived power at drop time (zone + rarity), e.g. weaponPct/def/res
    forgeLevel: number,     -- integer >= 0, default 0. Written only by EconomyService.forgeItem.
    droppedAtKm: number,    -- integer >= 0, origin zone (legacy "zone" index, not literal km)
    droppedAtTime: number,  -- os.time() at drop / migration
    setId: string?,         -- e.g. "roi_gobelin", nil for non-set items
    locked: boolean,        -- default false; blocks quick-sell, never blocks Forge
    equippedSlot: string?,  -- nil, or "arme"|"casque"|"plastron"|"gants"|"jambieres"|"bottes" when equipped
}

export type PlayerInventory = {
    version: number,        -- schema version, currently 1
    capacity: number,       -- 100 base, up to 200 with the bonus capacity pack
    items: {[string]: ItemInstance},  -- keyed by itemKey
    equipped: {              -- denormalized slot -> itemKey index, for O(1) equip lookups
        arme: string?, casque: string?, plastron: string?,
        gants: string?, jambieres: string?, bottes: string?,
    },
}

return {}
