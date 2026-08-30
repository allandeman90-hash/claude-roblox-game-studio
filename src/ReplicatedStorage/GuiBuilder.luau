--==============================================================
-- GuiBuilder  (ModuleScript - ReplicatedStorage)
--
-- Rebuilds a GUI tree from a serialised snapshot table (the shape produced by
-- the scratchpad serialiser, stored as src/StarterGui/RpgGui.gui.json).
--
-- This is the version-controlled source of truth for RpgGui: the live GUI in
-- the .rbxl can always be regenerated from the JSON via GuiBuilder.build(data).
-- Load the JSON however you like (HttpService in Studio, or a generated
-- ModuleScript) and pass the decoded table.
--
--   local data = require(path.to.RpgGuiData)          -- or HttpService:JSONDecode(...)
--   local gui  = GuiBuilder.build(data)
--   gui.Parent = player.PlayerGui                      -- (or StarterGui in Studio)
--==============================================================

local GuiBuilder = {}

-- Decode one serialised value (tagged tables from the serialiser).
local function de(v)
	if type(v) ~= "table" then
		return v
	end
	local t = v.__t
	if t == "UDim2" then
		return UDim2.new(v[1], v[2], v[3], v[4])
	elseif t == "UDim" then
		return UDim.new(v[1], v[2])
	elseif t == "Vector2" then
		return Vector2.new(v[1], v[2])
	elseif t == "Color3" then
		return Color3.fromRGB(v[1], v[2], v[3])
	elseif t == "Rect" then
		return Rect.new(v[1], v[2], v[3], v[4])
	elseif t == "Enum" then
		local name = tostring(v[1]):gsub("^Enum%.", "")
		local ok, res = pcall(function()
			return Enum[name][v[2]]
		end)
		return ok and res or nil
	elseif t == "Font" then
		local ok, res = pcall(function()
			return Font.new(v[1], Enum.FontWeight[v[2]:gsub("^Enum%.FontWeight%.", "")], Enum.FontStyle[v[3]:gsub("^Enum%.FontStyle%.", "")])
		end)
		return ok and res or nil
	elseif t == "ColorSequence" then
		local kps = {}
		for _, k in ipairs(v[1]) do
			kps[#kps + 1] = ColorSequenceKeypoint.new(k[1], Color3.fromRGB(k[2], k[3], k[4]))
		end
		return ColorSequence.new(kps)
	elseif t == "NumberSequence" then
		local kps = {}
		for _, k in ipairs(v[1]) do
			kps[#kps + 1] = NumberSequenceKeypoint.new(k[1], k[2], k[3] or 0)
		end
		return NumberSequence.new(kps)
	end
	return nil -- unknown / unsupported ("?" tag) -> leave the default
end

local function buildNode(node, parent)
	local ok, inst = pcall(Instance.new, node.class)
	if not ok then
		warn("[GuiBuilder] cannot create " .. tostring(node.class))
		return nil
	end
	for prop, raw in pairs(node.props or {}) do
		local value = de(raw)
		if value ~= nil then
			pcall(function()
				inst[prop] = value
			end)
		end
	end
	for _, child in ipairs(node.children or {}) do
		buildNode(child, inst)
	end
	inst.Parent = parent
	return inst
end

-- Build the whole tree. Returns the root instance (unparented).
function GuiBuilder.build(data)
	assert(type(data) == "table" and data.class, "GuiBuilder.build expects a serialised node table")
	local root = buildNode({ class = data.class, props = data.props }, nil)
	for _, child in ipairs(data.children or {}) do
		buildNode(child, root)
	end
	return root
end

return GuiBuilder
