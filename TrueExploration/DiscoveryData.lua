
local DiscoveryData = ZO_Object:Subclass()
TrueExplor = TrueExplor or {}
TrueExplor.discoveryData = DiscoveryData

local BITS = 7

function DiscoveryData:Load(data)
	setmetatable(data, self)
	return data
end

function DiscoveryData:New( ... )
	local result = {}
	setmetatable(result, self)
	result:Initialize( ... )
	return result
end

DiscoveryData.validPinTypes = {
	[MAP_PIN_TYPE_POI_SUGGESTED] = true,
	[MAP_PIN_TYPE_POI_SEEN] = true,
	[MAP_PIN_TYPE_POI_COMPLETE] = true,
	[MAP_PIN_TYPE_SKYSHARD_SEEN] = true,
	[MAP_PIN_TYPE_SKYSHARD_SUGGESTED] = true,
	[MAP_PIN_TYPE_SKYSHARD_COMPLETE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC] = true,
}

function DiscoveryData:Initialize(mapId)
	local currentMapId = GetCurrentMapId()
	SetMapToMapId(mapId)
	local units = TrueExplor.total_units
	local zoneIndex = GetCurrentMapZoneIndex()
	local numPOI = GetNumPOIs(zoneIndex)
	local POIsX = {}
	local POIsY = {}
	local POIdiscovered = {}
	local numValidPOI = 0
	for poiIndex = 1, numPOI do
		local x, y, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby = GetPOIMapInfo(zoneIndex, poiIndex)
		if isShownInCurrentMap and self.validPinTypes[poiPinType] then
			numValidPOI = numValidPOI + 1
			POIsX[numValidPOI] = x * units
			POIsY[numValidPOI] = y * units
			POIdiscovered[numValidPOI] = isDiscovered
		end
	end
	
	local smallestDist, dx, dy, dist, closestPOI
	for x = 0, units-1 do
		for y = 0, units-1 do
			smallestDist = math.huge
			for i = 1, numValidPOI do
				dx = x - POIsX[i]
				dy = y - POIsY[i]
				dist = dx * dx + dy * dy
				if dist < smallestDist then
					smallestDist = dist
					closestPOI = i
				end
			end
			if POIdiscovered[closestPOI] then
				self:Discover(x, y)
			end
		end
	end
	
	SetMapToMapId(currentMapId)
end

function DiscoveryData:IsCompletelyDiscovered()
	return self.discovered
end

function DiscoveryData:SetCompletelyDiscovered(isDicovered)
	isDiscover = not not isDiscover -- force boolean because this is serialized
	self.discovered = isDicovered
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
		self[num] = (self[num] or 0) + (2^bit)
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

function DiscoveryData:IsAnyDiscoveredInRadius(x, y, radius)
	local num, bit
	for i = x - radius, x + radius do
		for j = y - radius, y + radius do
			if self:IsDiscovered(i, j) then
				return true
			end
		end
	end
	return false
end
