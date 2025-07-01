
local DiscoveryData = ZO_Object:Subclass()
TrueExplor = TrueExplor or {}
TrueExplor.DiscoveryData = DiscoveryData

local BITS = 7

function DiscoveryData:Load(data)
	setmetatable(data, self)
	return data
end

function DiscoveryData:New( ... )
	local result = ZO_Object.New(self)
	result:Initialize( ... )
	return result
end

function DiscoveryData:Initialize()
	
end

function DiscoveryData:UndiscoverInRadius(x, y, radius)
	assert(not self.discovered)
	local hasChanged = false
	
	local unit
	local num, bit
	for i = x - radius, x + radius do
		for j = y - radius, y + radius do
			if self:IsDiscovered(i, j) then
				hasChanged = true
				unit = i + j * TrueExplor.total_units
				num = zo_floor(unit / TrueExplor.unitsPerNumber)
				bit = zo_mod(unit, TrueExplor.unitsPerNumber)
				self[num] = self[num] - (2^bit)
			end
		end
	end
	return hasChanged
end

function DiscoveryData:Discover(x, y)
	local hasChanged = false
	
	if not self:IsDiscovered(x, y) then
		hasChanged = true
		local unitId = (y * TrueExplor.total_units + x)
		local num = zo_floor(unitId / TrueExplor.unitsPerNumber)
		local bit = zo_mod(unitId, TrueExplor.unitsPerNumber)
		self[y] = (self[y] or 0) + (2^bit)
	end
	return hasChanged
end

function DiscoveryData:IsDiscovered(x, y)
	if self.discovered then return true end
	local unit = x + y * TrueExplor.total_units
	local i = zo_floor(unit / TrueExplor.unitsPerNumber)
	local j = zo_mod(unit, TrueExplor.unitsPerNumber)
	local save = self[i]
	if save then
		return ((save / (2^j)) % 2 >= 1)
	end
	return false
end

function DiscoveryData:IsAnyDiscoveredInRadius(centerX, centerY, radius)
	local x = centerX
	for y = centerY - radius, centerY + radius do
		local unit = x + y * TrueExplor.total_units
		local i = unit % BITS
		local j = zo_floor(unit / BITS)
		byte1, byte2 = self.byteString:byte((unit - radius) % BITS, (unit + radius) % BITS)
		
end
