--==============================================================
-- ShopService  (ModuleScript - ServerScriptService)
--
-- Functional shop (etape 4.0). Reached at every 50 km REST milestone
-- (campfire + shop combined). Sells zone-appropriate weapon / armor for
-- GOLD, up to the zone the player is standing in (== the max zone reached,
-- since the milestone is walked to). Prices and item power are DERIVED from
-- GameConfig.Equipment (zone x rarity). No Robux, no loot rolls here.
--
-- Purchases are driven by CombatServer (it owns the combat state / gold):
--   CombatServer's combatEvent handler routes { type = "buyEquipment", ... }
--   to ShopService.handlePurchase(player, st, data).
-- ShopEvent stays as the client-UI notification channel (UI is a later lot).
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipmentConfig  = require(ReplicatedStorage:WaitForChild("EquipmentConfig"))
local GameConfig       = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ZoneConfig       = require(ReplicatedStorage:WaitForChild("ZoneConfig"))

-- Bag storage/mutation (Inventory Sprint Day 1). Still a stub - handlePurchase
-- pcall-wraps every call and refunds on failure instead of crashing.
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))

local ShopService = {}

-- RemoteEvent so the future client-side shop UI has something to bind to.
local shopEvent = ReplicatedStorage:FindFirstChild("ShopEvent")
if not shopEvent then
	shopEvent = Instance.new("RemoteEvent")
	shopEvent.Name = "ShopEvent"
	shopEvent.Parent = ReplicatedStorage
end
ShopService.Event = shopEvent

-- Fixed stock template. The per-item `base` numbers are irrelevant to the
-- etape 4.0 model - power is derived from (zone, rarity). Real content later.
local STOCK = {
	{ id = "epee_courte",       slot = "arme",      voie = "guerrier" },
	{ id = "baguette_simple",   slot = "arme",      voie = "mage" },
	{ id = "casque_toile_g",    slot = "casque",    voie = "guerrier" },
	{ id = "plastron_toile_g",  slot = "plastron",  voie = "guerrier" },
	{ id = "jambieres_toile_g", slot = "jambieres", voie = "guerrier" },
	{ id = "bottes_toile_g",    slot = "bottes",    voie = "guerrier" },
	{ id = "gants_toile_g",     slot = "gants",     voie = "guerrier" },
	{ id = "casque_toile_m",    slot = "casque",    voie = "mage" },
	{ id = "plastron_toile_m",  slot = "plastron",  voie = "mage" },
	{ id = "jambieres_toile_m", slot = "jambieres", voie = "mage" },
	{ id = "bottes_toile_m",    slot = "bottes",    voie = "mage" },
	{ id = "gants_toile_m",     slot = "gants",     voie = "mage" },
}
local OFFER_RARITIES = { "commun", "rare" }

local STOCK_BY_ID = {}
for _, entry in ipairs(STOCK) do
	STOCK_BY_ID[entry.id] = entry
end

-- [player] = { zone = <shop zone> } while a shop is open. Cleared on leave / release.
local session = {}

-- Gold price of one stock line at (zone, rarity).
local function priceFor(entry, zone, rarityMult)
	local base = (entry.slot == "arme")
		and GameConfig.Equipment.weaponPrice(zone)
		or  GameConfig.Equipment.armorPiecePrice(zone)
	return math.round(base * (rarityMult or 1))
end

-- The list of buyable items for a shop opened in `zone`.
function ShopService.getAvailableEquipment(player, zone)
	zone = math.max(1, math.floor(zone or 1))
	local out = {}
	for _, entry in ipairs(STOCK) do
		local itemDef = EquipmentConfig.getItem(entry.id)
		for _, rarete in ipairs(OFFER_RARITIES) do
			local r = EquipmentConfig.getRarity(rarete)
			if r and r.active then
				table.insert(out, {
					id     = entry.id,
					nom    = itemDef and itemDef.nom or entry.id,
					slot   = entry.slot,
					voie   = entry.voie,
					rarete = rarete,
					zone   = zone,
					price  = priceFor(entry, zone, r.mult),
				})
			end
		end
	end
	return out
end

-- Called by CombatServer when the player reaches a REST (campfire + shop) milestone.
function ShopService.openShop(player, context)
	local km = (context and context.km) or 0
	local zone = ZoneConfig.zoneIdFromKm(km)
	session[player] = { zone = zone }
	shopEvent:FireClient(player, {
		type = "open",
		km = km,
		zone = zone,
		equipment = ShopService.getAvailableEquipment(player, zone),
	})
end

-- Called by CombatServer when the player leaves the campfire (CONTINUER).
function ShopService.closeShop(player)
	session[player] = nil
end

function ShopService.release(player)
	session[player] = nil
end

-- Attempt a purchase. `st` is the CombatServer combat state (owns `st.gold`).
-- data = { itemId, rarete, slot }. The zone is taken from the OPEN shop
-- session, never from the client. Auto-equips on success.
-- Returns (ok: boolean, err: string?, receipt: table?).
function ShopService.handlePurchase(player, st, data)
	if type(data) ~= "table" then
		return false, "bad request"
	end
	local sess = session[player]
	if not sess then
		return false, "shop closed"
	end
	local zone = sess.zone

	local entry = STOCK_BY_ID[data.itemId]
	if not entry then
		return false, "item not in stock"
	end
	if data.slot ~= nil and data.slot ~= entry.slot then
		return false, "slot mismatch"
	end

	local offered = false
	for _, rr in ipairs(OFFER_RARITIES) do
		if rr == data.rarete then offered = true break end
	end
	if not offered then
		return false, "rarity not offered"
	end
	local r = EquipmentConfig.getRarity(data.rarete)
	if not r or not r.active then
		return false, "invalid rarity"
	end

	local price = priceFor(entry, zone, r.mult)
	if (st.gold or 0) < price then
		return false, "not enough gold"
	end

	st.gold = st.gold - price

	-- Inventory Sprint Day 1: InventoryService owns the bag directly now.
	-- Both calls are pcall-wrapped since InventoryService is still a stub
	-- (errors "not implemented") - refund on any failure so gold is never lost.
	local instance = {
		id = entry.id,
		itemType = entry.slot,   -- best-effort; InventoryService normalizes this (Day 2)
		rarity = data.rarete,
		voie = entry.voie,
		baseStats = {},
		forgeLevel = 0,
		droppedAtKm = zone,
		droppedAtTime = os.time(),
		setId = nil,
		locked = false,
		equippedSlot = nil,
	}
	local addOk, added, addErr = pcall(InventoryService.addItem, player, instance)
	if not addOk or not added then
		st.gold = st.gold + price
		return false, (addOk and addErr) or "shop unavailable"
	end

	-- Find the itemKey InventoryService.addItem actually minted for this
	-- purchase ("<id>_<epoch>_<seq4>", InventoryService.luau's mintItemKey -
	-- NOT the hardcoded "<id>_<os.time()>_shop" this used to guess, which
	-- never matched the real format and made every auto-equip fail with
	-- "item_not_found"). addItem doesn't hand the key back directly, so scan
	-- the just-updated inventory for the newest unequipped instance of this
	-- exact id/rarity - safe because this purchase is the only mutation that
	-- could have just added one.
	local listOk, inventory = pcall(InventoryService.getInventory, player)
	local itemKey: string? = nil
	if listOk and inventory and inventory.items then
		local newestTime = -1
		for key, inst in pairs(inventory.items) do
			if inst.id == entry.id and inst.rarity == data.rarete then
				-- Tie-break same-second purchases (droppedAtTime equal) by
				-- itemKey: mintItemKey increments the "<seq4>" suffix within
				-- the same "<id>_<epoch>_" prefix, so the lexicographically
				-- greatest key among ties is the most recently minted one.
				if inst.droppedAtTime > newestTime or (inst.droppedAtTime == newestTime and (not itemKey or key > itemKey)) then
					itemKey, newestTime = key, inst.droppedAtTime
				end
			end
		end
	end
	if not itemKey then
		st.gold = st.gold + price
		return false, "item not found after purchase"
	end

	local equipOk, equipped, equipErr = pcall(InventoryService.equipItem, player, itemKey)
	if not (equipOk and equipped) then
		st.gold = st.gold + price
		return false, (equipOk and equipErr) or "equip failed"
	end

	local receipt = { itemId = entry.id, rarete = data.rarete, zone = zone, slot = entry.slot, price = price, gold = st.gold }
	shopEvent:FireClient(player, { type = "purchased", receipt = receipt })
	return true, nil, receipt
end

-- ShopEvent is a server -> client notification channel only (shop open, purchase
-- confirmed). Purchases come in through CombatEvent { type = "buyEquipment" } ->
-- ShopService.handlePurchase, which is rate-limited and validated there. No
-- client -> server listener on ShopEvent by design.

return ShopService
